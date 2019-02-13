export bsizeof, bnorm, bit_length, onehot, log2i, hypercubic, logdim1
# NOTE: all binary specified operations begin with b

"""
    bsizeof(::Type)

Returns the size of given type in number of binary digits.
"""
bsizeof(::Type{T}) where T = sizeof(T) << 3
bsizeof(::T) where T = bsizeof(T)

"""
    bnorm(i::Integer, j::Integer) -> Int

Return number of different bits.
"""
bnorm(i::Ti, j::Ti) where Ti<:Integer = count_ones(i ⊻ j)

"""
    onehot([T=Float64], nbits, x::Integer)

Returns an onehot vector of type `Vector{T}`, where index `x + 1` is one.
"""
function onehot(::Type{T}, nbits::Int, x::Integer) where T
    v = zeros(T, 1 << nbits)
    v[x + 1] = 1
    return v
end

onehot(nbits::Int, x::Integer) = onehot(Float64, nbits, x)

"""
    unsafe_sub(a::UnitRange, b::NTuple{N}) -> NTuple{N}

Returns result in type `Tuple` of `a .- b`. This will not check the length of `a` and `b`, use
at your own risk.
"""
@generated function unsafe_sub(a::UnitRange{T}, b::NTuple{N, T}) where {N, T}
    ex = Expr(:tuple)
    for k in 1:N
        push!(ex.args, :(a.start + $(k-1) - b[$k]))
    end
    return ex
end

"""
    unsafe_sub(a::UnitRange{T}, b::Vector{T}) where T

Returns `a .- b`, fallback version when b is a `Vector`.
"""
unsafe_sub(a::UnitRange{T}, b::Vector{T}) where T = a .- b

"""
    bit_length(x::Integer) -> Int

Return the number of bits required to represent input integer x.
"""
bit_length(x::Integer)  =  sizeof(x)*8 - leading_zeros(x)

"""
    log2i(x::Integer) -> Integer

Return log2(x), this integer version of `log2` is fast but only valid for number equal to 2^n.
"""
function log2i end

for N in [8, 16, 32, 64, 128]
    T = Symbol(:Int, N)
    UT = Symbol(:UInt, N)
    @eval begin
        log2i(x::$T) = !signbit(x) ? ($(N - 1) - leading_zeros(x)) : throw(ErrorException("nonnegative expected ($x)"))
        log2i(x::$UT) = $(N - 1) - leading_zeros(x)
    end
end

"""
    logdim1(X)

Returns the `log2` of the first dimension's size.
"""
logdim1(X) = log2i(size(X, 1))

"""
    hypercubic(A::Array) -> Array

get the hypercubic representation for an array.
"""
hypercubic(A::Array) = reshape(A, fill(2, size(A) |> prod |> log2i)...)

# NOTE: this is not exported
function int(n::Int)
    n <= 8 ?   Int8   :
    n <= 16 ?  Int16  :
    n <= 32 ?  Int32  :
    n <= 64 ?  Int64  :
    n <= 128 ? Int128 : BigInt
end
