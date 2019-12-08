export bsizeof, bdistance, bit_length, onehot, log2i, hypercubic, log2dim1, indices_with
# NOTE: all binary specified operations begin with b

"""
    bsizeof(::Type)

Returns the size of given type in number of binary digits.
"""
bsizeof(::Type{T}) where {T} = sizeof(T) << 3
bsizeof(::T) where {T} = bsizeof(T)

"""
    bdistance(i::Integer, j::Integer) -> Int

Return number of different bits.
"""
bdistance(i::Ti, j::Ti) where {Ti<:Integer} = count_ones(i ⊻ j)

"""
    onehot([T=Float64], nbits, x::Integer; nbatch::Int])

Create an onehot vector in type `Vector{T}` or a batch of onehot vector in type `Matrix{T}`,
where index `x + 1` is one.
"""
function onehot(::Type{T}, nbits::Int, x::Integer) where {T}
    v = zeros(T, 1 << nbits)
    v[x+1] = 1
    return v
end

onehot(nbits::Int, x::Integer) = onehot(Float64, nbits, x)

function onehot(::Type{T}, nbits::Int, x::Integer, nbatch::Int) where {T}
    v = zeros(T, 1 << nbits, nbatch)
    v[x+1, :] .= 1
    return v
end

onehot(nbits::Int, x::Integer, nbatch::Int) = onehot(Float64, nbits, x, nbatch)

"""
    unsafe_sub(a::UnitRange, b::NTuple{N}) -> NTuple{N}

Returns result in type `Tuple` of `a .- b`. This will not check the length of `a` and `b`, use
at your own risk.
"""
@generated function unsafe_sub(a::UnitRange{T}, b::NTuple{N,T}) where {N,T}
    ex = Expr(:tuple)
    for k in 1:N
        push!(ex.args, :(a.start + $(k - 1) - b[$k]))
    end
    return ex
end

"""
    unsafe_sub(a::UnitRange{T}, b::Vector{T}) where T

Returns `a .- b`, fallback version when b is a `Vector`.
"""
unsafe_sub(a::UnitRange{T}, b::Vector{T}) where {T} = a .- b

"""
    bit_length(x::Integer) -> Int

Return the number of bits required to represent input integer x.
"""
bit_length(x::Integer) = sizeof(x) * 8 - leading_zeros(x)

"""
    log2i(x::Integer) -> Integer

Return log2(x), this integer version of `log2` is fast but only valid for number equal to 2^n.
"""
function log2i end

for N in [8, 16, 32, 64, 128]
    T = Symbol(:Int, N)
    UT = Symbol(:UInt, N)
    @eval begin
        log2i(x::$T) = !signbit(x) ? ($(N - 1) - leading_zeros(x)) :
            throw(ErrorException("nonnegative expected ($x)"))
        log2i(x::$UT) = $(N - 1) - leading_zeros(x)
    end
end

"""
    log2dim1(X)

Returns the `log2` of the first dimension's size.
"""
log2dim1(X) = log2i(size(X, 1))

"""
    hypercubic(A::Array) -> Array

get the hypercubic representation for an array.
"""
hypercubic(A::Array) = reshape(A, fill(2, size(A) |> prod |> log2i)...)

"""
    indices_with(n::Int, locs::Vector{Int}, vals::Vector{Int}) -> Vector{Int}

Return indices with specific positions `locs` with value `vals` in a hilbert space of `n` qubits.
"""
function indices_with(n::Int, locs::Vector{Int}, vals::Vector{Int})
    mask = bmask(locs)
    onemask = bmask(locs[vals.!=0])
    return filter(x -> ismatch(x, mask, onemask), basis(n))
end
