using StaticArrays
export IterControl, itercontrol, controldo, group_shift!, lmove

# NOTE: use SortedVector in Blocks would help benchmarks

"""
    IterControl{S}
    IterControl(n::Int, base::Int, masks, ks) -> IterControl

Iterator to iterate through controlled subspace. See also [`itercontrol`](@ref).
 `S` is the number of shifts,
 `n` is the size of Hilbert space,
 `base` is the base of counter,
 `masks` and `ks` are helpers for enumerating over the target Hilbert Space.
"""
struct IterControl{S}
    n::Int
    base::Int
    masks::NTuple{S,Int}
    ks::NTuple{S,Int}

    function IterControl(
        n::Int,
        base::Int,
        masks::NTuple{S,Int},
        ks::NTuple{S,Int},
    ) where {S}
        new{S}(n, base, masks, ks)
    end
end

"""
    itercontrol([T=Int], nbits, positions, bit_configs)

Returns an iterator which iterate through controlled subspace of bits.

# Example

To iterate through all the bits satisfy `0xx10x1` where `x` means an arbitrary bit.

```jldoctest
julia> for each in itercontrol(7, [1, 3, 4, 7], (1, 0, 1, 0))
           println(string(each, base=2, pad=7))
       end
0001001
0001011
0011001
0011011
0101001
0101011
0111001
0111011

```
"""
# NOTE: positions should be vector (MVector is the best), since it need to be sorted
#       do not use Tuple, or other immutables, it increases the sorting time.
function itercontrol(nbits::Int, positions::AbstractVector, bit_configs) where {T}
    base = bmask(Int, positions[i] for (i, u) in enumerate(bit_configs) if u != 0)
    masks, ks = group_shift!(nbits, positions)
    S = length(masks)
    return IterControl(1 << (nbits - length(positions)), base, Tuple(masks), Tuple(ks))
end

"""
    controldo(f, itr::IterControl)

Execute `f` while iterating `itr`.

!!! note

    this is faster but equivalent than using `itr` as an iterator.
    See also [`itercontrol`](@ref).
"""
function controldo(f::Base.Callable, ic::IterControl{S}) where {S}
    for i = 0:ic.n-1
        @simd for s = 1:S
            @inbounds i = lmove(i, ic.masks[s], ic.ks[s])
        end
        f(i + ic.base)
    end
    return nothing
end

Base.length(it::IterControl) = it.n
Base.eltype(it::IterControl) = Int

function Base.getindex(it::IterControl{S}, k::Int) where {S}
    out = k - 1
    @simd for s = 1:S
        @inbounds out = lmove(out, it.masks[s], it.ks[s])
    end
    return out + it.base
end

function Base.iterate(it::IterControl{S}, state = 1) where {S}
    if state > length(it)
        return nothing
    else
        return it[state], state + 1
    end
end

lmove(b::Int, mask::Int, k::Int)::Int = (b & ~mask) << k + (b & mask)

"""
    group_shift!(nbits, positions)

Shift bits on `positions` together.
"""
function group_shift!(nbits::Int, positions::AbstractVector{Int})
    sort!(positions)
    masks = Int[]
    ns = Int[]
    k_prv = -1
    for k in positions
        if k == k_prv + 1
            ns[end] += 1
        else
            push!(masks, bmask(0:k-1))
            push!(ns, 1)
        end
        k_prv = k
    end
    return masks, ns
end
