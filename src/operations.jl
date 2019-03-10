export bitarray, basis, packbits, bfloat, bfloat_r, bint, bint_r, flip
export anyone, allone, bmask, baddrs, readbit, setbit, controller
export swapbits, ismatch, neg, breflect, btruncate

"""
    bitarray(v::Vector, [num_bits::Int]) -> BitArray
    bitarray(v::Int, num_bits::Int) -> BitArray
    bitarray(num_bits::Int) -> Function

Construct BitArray from an integer vector, if num_bits not supplied, it is 64.
If an integer is supplied, it returns a function mapping a Vector/Int to bitarray.
"""
function bitarray(v::Vector{T}, num_bits::Int)::BitArray{2} where T<:Number
    ba = BitArray(undef, 0, 0)
    ba.len = 64*length(v)
    ba.chunks = UInt64.(v)
    ba.dims = (64, length(v))
    view(ba, 1:num_bits, :)
end

function bitarray(v::Vector{T})::BitArray{2} where T<:Union{UInt64, Int64}
    ba = BitArray(undef, 0, 0)
    ba.len = 64*length(v)
    ba.chunks = reinterpret(UInt64, v)
    ba.dims = (64, length(v))
    ba
end

bitarray(v::Number, num_bits::Int)::BitArray{1} = vec(bitarray([v], num_bits))
bitarray(nbit::Int) = x->bitarray(x, nbit)

"""
    basis([IntType], num_bits::Int) -> UnitRange{IntType}
    basis([IntType], state::AbstractArray) -> UnitRange{IntType}

Returns the UnitRange for basis in Hilbert Space of num_bits qubits.
If an array is supplied, it will return a basis having the same size
with the first diemension of array.
"""
basis(arg::Union{Int, AbstractArray}) = basis(Int, arg)
basis(::Type{T}, num_bits::Int) where T <: Integer = UnitRange{T}(0, 1 << num_bits-1)
basis(::Type{T}, state::AbstractArray) where T <: Integer = UnitRange{T}(0, size(state, 1) - 1)

"""
    packbits(arr::AbstractArray) -> AbstractArray

pack bits to integers, usually take a BitArray as input.
"""
packbits(arr::AbstractVector) = _packbits(arr)[]
packbits(arr::AbstractArray) = _packbits(arr)
_packbits(arr) = selectdim(sum(mapslices(x -> x .* (1 .<< (0:size(arr, 1)-1)), arr, dims=1), dims=1), 1, 1)

"""
    truncate(b, n)

Truncate bits `b` to given length `n`.
"""
btruncate(b::Integer, n) = b & (1 << n - 1)

"""
    bfloat(b::Integer; nbit::Int=bit_length(b)) -> Float64

float view, with big end qubit 1.
"""
bfloat(b::Integer; nbit::Int=bit_length(b)) = breflect(nbit, b) / (1<<nbit)

"""
    bfloat_r(b::Integer; nbit::Int) -> Float64

float view, with bits read in inverse order.
"""
bfloat_r(b::Integer; nbit::Int) = b / (1<<nbit)

"""
    bint(b; nbit=nothing) -> Int

integer view, with little end qubit 1.
"""
bint(b::Integer; nbit=nothing) = b
bint(x::Float64; nbit::Int) = breflect(nbit,bint_r(x, nbit=nbit))

"""
    bint_r(b; nbit::Int) -> Integer

integer read in inverse order.
"""
bint_r(b::Integer; nbit::Int) = breflect(nbit, b)
bint_r(x::Float64; nbit::Int) = Int(round(x * (1<<nbit)))


"""
    bmask(::Type{T}) where T <: Integer -> zero(T)
    bmask([T::Type], positions::Int...) -> T
    bmask([T::Type], range::UnitRange{Int}) -> T

Return an integer mask of type `T` where `1` is the position masked according to
`positions` or `range`. Directly use `T` will return an empty mask `0`.
"""
function bmask end

bmask(args...) = bmask(Int, args...)
bmask(::Type{T}) where T <: Integer = zero(T)
bmask(::Type{T}, positions::Int...) where T <: Integer = bmask(T, positions)
bmask(::Type{T}, itr) where T <: Integer = isempty(itr) ? 0 : reduce(+, one(T) << (b - 1) for b in itr)

function bmask(::Type{T}, range::UnitRange{Int})::T where T<:Integer
    ((one(T) << (range.stop - range.start + 1)) - one(T)) << (range.start - 1)
end

# NOTE: we have to return a vector here since this is calculated in runtime

"""
    baddrs(b::Integer) -> Vector

get the locations of nonzeros bits, i.e. the inverse operation of bmask.
"""
function baddrs(b::Integer)
    locs = Vector{Int}(undef, count_ones(b))
    k = 1
    for i = 1:bit_length(b)
        if readbit(b, i) == 1
            locs[k] = i
            k += 1
        end
    end
    return locs
end

"""
    readbit(x, loc...)

Read the bit config at given location.
"""
readbit(x::T, loc::Int) where T <: Integer = (x >> (loc - 1)) & one(T)

@inline function readbit(x::T, bits::Int...) where T <: Integer
    res = zero(T)
    for (i, loc) in enumerate(bits)
        res += readbit(x, loc) << (i-1)
    end
    return res
end

"""
    anyone(index::Integer, mask::Integer) -> Bool

Return `true` if any masked position of index is 1.
"""
anyone(index::T, mask::T) where T <: Integer = (index & mask) != zero(T)

"""
    allone(index::Integer, mask::Integer) -> Bool

Return `true` if all masked position of index is 1.
"""
allone(index::T, mask::T) where T <: Integer = (index & mask) == mask

"""
    ismatch(index::Integer, mask::Integer, target::Integer) -> Bool

Return `true` if bits at positions masked by `mask` equal to `1` are equal to `target`.

## Example

```julia
julia> n = 0b11001; mask = 0b10100; target = 0b10000;

julia> ismatch(n, mask, target)
true
```
"""
ismatch(index::T, mask::T, target::T) where T<:Integer = (index & mask) == target

"""
    setbit(index::Integer, mask::Integer) -> Integer

set the bit at masked position to 1.
"""
setbit(index::T, mask::T) where T<:Integer = index | mask

"""
    flip(index::Integer, mask::Integer) -> Integer

Return an Integer with bits at masked position flipped.
"""
flip(index::T, mask::T) where T<:Integer = index ⊻ mask

"""
    neg(index::Integer, num_bits::Int) -> Integer

Return an integer with all bits flipped (with total number of bit `num_bits`).
"""
neg(index::T, num_bits::Int) where T<:Integer = bmask(T, 1:num_bits) ⊻ index

"""
    swapbits(n::Integer, mask_ij::Integer) -> Integer

Return an integer with bits at `i` and `j` in given mask flipped.

!!! warning

    `mask_ij` should only contain two `1`, `swapbits` will not check it, use at
    your own risk.
"""
Base.@propagate_inbounds swapbits(b::T, mask_ij::T) where T <: Integer = unsafe_swapbits(b, mask_ij)

"""
    swapbits(n::Integer, i::Int, j::Int) -> Integer

Return an integer with bits at `i` and `j` flipped.
"""
swapbits(b::Integer, i::Int, j::Int) = unsafe_swapbits(b, i, j)
unsafe_swapbits(b::T, i::Int, j::Int) where {T <: Integer} = unsafe_swapbits(b, bmask(T, i, j))

@inline function unsafe_swapbits(b::T, mask::T) where T <: Integer
    bm = b & mask
    if bm !=0 && bm != mask
        b ⊻= mask
    end
    return b
end

"""
    breflect(num_bits::Int, b::Integer[, masks::Vector{Integer}]) -> Integer

Return left-right reflected integer.
"""
function breflect end

@inline function breflect(nbits::Int, b::Integer)
    @simd for i in 1:nbits÷2
        b = unsafe_swapbits(b, i, nbits - i + 1)
    end
    return b
end

@inline function breflect(num_bits::Int, b::T, masks::Vector{T})::T where T<:Integer
    @simd for m in masks
        b = unsafe_swapbits(b, m)
    end
    return b
end

const IntIterator{T} = Union{NTuple{<:Any, T}, Vector{T}, T, UnitRange{T}} where T <: Integer

"""
    controller(cbits, cvals) -> Function

Return a function that checks whether a basis at `cbits` takes specific value `cvals`.
"""
function controller(cbits::IntIterator{Int}, cvals::IntIterator{Int})
    do_mask = bmask(cbits)
    target = length(cvals) == 0 ? 0 : mapreduce(xy -> (xy[2]==1 ? 1<<(xy[1]-1) : 0), |, zip(cbits, cvals))
    return b->ismatch(b, do_mask, target)
end