export BitStr, @bit_str, @lbit_str, BitStr64, LongBitStr, bit_literal
export bcat, onehot, buffer

const UIntStorage = Union{UInt8, UInt16, UInt32, UInt64, UInt128}
const IntStorage = Union{Int8, Int16, Int32, Int64, Int128, BigInt, UIntStorage}

"""
    BitStr{N,T} <: Integer

struct for bit string with fixed length `N`, the storage type is `T`.

    BitStr{N,T}(value)
    BitStr64{N}(value)
    LongBitStr{N}(value)

Returns a `BitStr`.

## Example

`BitStr` supports some basic arithmetic operations. It acts like an integer, but supports
some frequently used methods for binary basis.

```julia
julia> bit"0101" * 2
1010 ₍₂₎

julia> bcat(bit"101" for i in 1:10)
101101101101101101101101101101 (766958445)

julia> repeat(bit"101", 2)
101101 ₍₂₎

julia> bit"1101"[2]
0
```
"""
struct BitStr{N,T<:Integer} <: Integer
    buf::T

    BitStr{N,T}(buf::IntStorage) where {N,T} = new{N, T}(buf)
    BitStr{N}(buf::IntStorage) where N = new{N, typeof(buf)}(buf)
end

const BitStr64{N} = BitStr{N,Int64}
const LongBitStr{N} = BitStr{N,BigInt}

BitStr{N,T}(val::BitStr) where {N,T<:Integer} = convert(BitStr{N,T}, val)
BitStr{N,T}(val::BitStr{N,T}) where {N,T<:Integer} = val

Base.zero(::Type{BitStr{N,T}}) where {N,T} = BitStr{N,T}(zero(T))
Base.zero(::BitStr{N,T}) where {N,T} = BitStr{N,T}(zero(T))

buffer(b::BitStr) = b.buf
Base.reinterpret(::Type{BitStr{N,T}}, x::Integer) where {N,T} = BitStr{N,T}(reinterpret(T, x))
Base.reinterpret(::Type{T}, x::BitStr) where {T} = reinterpret(T, buffer(x))
Base.reinterpret(::Type{BitStr{N,T}}, x::BitStr) where {N,T} = x

Base.convert(::Type{T}, b::BitStr) where {T<:Integer} = convert(T, buffer(b))
Base.convert(::Type{T}, b::Integer) where {T<:BitStr} = T(b)
Base.convert(::Type{BitStr{N,T}}, b::BitStr{N,T}) where {N,T<:Integer} = b
Base.convert(::Type{T1}, b::BitStr{N2,T2}) where {T1<:BitStr,N2,T2<:Integer} = convert(T1, buffer(b))
#Base.promote_rule(::Type{BitStr{N,T1}}, ::Type{BitStr{N,T2}}) where {N,T1,T2} = BitStr{N,promote_rule(T1,T2)}
for IT in [
    :BigInt,
    :Int128,
    :UInt128,
    :Int64,
    :UInt64,
    :Int32,
    :UInt32,
    :Int16,
    :UInt16,
    :Int8,
    :UInt8,
    :Bool,
]
    @eval Base.$IT(b::BitStr) = $IT(buffer(b))
end
for op in [:+, :-, :*, :÷, :|, :⊻, :&, :%, :mod, :mod1]
    @eval Base.$op(a::T, b::Integer) where {T <: BitStr} = T($op(buffer(a), b))
    @eval Base.$op(a::Integer, b::T) where {T <: BitStr} = T($op(a, buffer(b)))
    @eval Base.$op(a::BitStr{N,T}, b::BitStr{N,T}) where {N,T<:Integer} =
        BitStr{N,T}($op(buffer(a), buffer(b)))
    @eval Base.$op(a::BitStr, b::BitStr) = error("type mismatch: $(typeof(a)), $(typeof(b))")
end
Base.:-(x::BitStr{N,T}) where {N,T} = BitStr{N,T}(-buffer(x))

for op in [:(>>), :(<<)]
    @eval Base.$op(a::BitStr{N,T}, b::Int) where {N,T} = BitStr{N,T}(Base.$op(buffer(a), b))
    #@eval Base.$op(a::T, b::T) where T<:BitStr = T(Base.$op(buffer(a),buffer(b)))
end

for op in [:<, :>, :(<=), :(>=)]
    @eval Base.$op(a::T, b::T) where {T<:BitStr} = Base.$op(buffer(a), buffer(b))
end

for Type in [Integer, BigInt, BigFloat]
    @eval Base.:(==)(a::T, b::$Type) where {T<:BitStr} = Base.:(==)(buffer(a), b)
    @eval Base.:(==)(a::$Type, b::T) where {T<:BitStr} = Base.:(==)(a, buffer(b))
end

Base.:(==)(a::BitStr{N}, b::BitStr{N}) where {N} = Base.:(==)(buffer(a), buffer(b))

for op in [:count_ones, :count_zeros, :leading_ones, :leading_zeros, :trailing_zeros, :trailing_ones]
    @eval Base.$op(a::BitStr) = Base.$op(buffer(a))
end

# Note: the transitivity of == is not satisfied here.
Base.:(==)(lhs::BitStr, rhs::BitStr) = false
Base.isapprox(a::BitStr, b::Number; kwargs...) = Base.isapprox(buffer(a), b; kwargs...)
Base.isapprox(a::Number, b::BitStr; kwargs...) = Base.isapprox(a, buffer(b); kwargs...)
Base.isapprox(lhs::BitStr, rhs::BitStr; kwargs...) = false
Base.isapprox(a::T, b::T; kwargs...) where {T<:BitStr} =
    Base.isapprox(buffer(a), buffer(b); kwargs...)

# Note: it is a bit confusing, with x::BitStr == y::Integer,
# they behave different when used for indexing.
Base.to_index(x::BitStr) = error(
    "please do not use bit string for indexing, you may want to use `buffer(x)+1` for indexing to avoid ambiguity.",
)
Base.to_index(x::UnitRange{<:BitStr}) = error(
    "please do not use bit string for indexing, you may want to use `buffer(x)+1` for indexing to avoid ambiguity.",
)

# use system interface
Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, i::BitStr) =
    checkindex(Bool, inds, Base.to_index(i))
Base.length(bits::BitStr{N}) where {N} = N
Base.lastindex(bits::BitStr) = length(bits)

Base.typemax(::Type{BitStr{N,T}}) where {N,T} = BitStr{N,T}(1 << N - 1)
Base.typemin(::Type{BitStr{N,T}}) where {N,T} = BitStr{N,T}(0)
Base.typemax(::BitStr{N,T}) where {N,T} = BitStr{N,T}(1 << N - 1)
Base.typemin(::BitStr{N,T}) where {N,T} = BitStr{N,T}(0)

"""
    @bit_str -> BitStr64

Construct a bit string. such as `bit"0000"`. The bit strings also supports string `bcat`. Just use
it like normal strings.

## Example

```jldoctest
julia> bit"10001"
10001 ₍₂₎

julia> bit"100_111_101"
100111101 ₍₂₎

julia> bcat(bit"1001", bit"11", bit"1110")
1001111110 ₍₂₎

julia> onehot(bit"1001")
16-element Array{Float64,1}:
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0
 1.0
 0.0
 0.0
 0.0
 0.0
 0.0
 0.0

```
"""
macro bit_str(str)
    return parse_bit(Int64, str)
end

"""
    @bit_str -> LongBitStr

Long bit string version of `@bit_str` macro.
"""
macro lbit_str(str)
    return parse_bit(BigInt, str)
end

function parse_bit(::Type{T}, str::String) where {T<:Integer}
    val = zero(T)
    k = 1
    for each in reverse(filter(x -> x != '_', str))
        if each == '1'
            val += one(T) << (k - 1)
            k += 1
        elseif each == '0'
            k += 1
        elseif each == '_'
            continue
        else
            error("expect 0 or 1, got $each at $k-th bit")
        end
        (isbitstype(T) && k > bsizeof(T)) &&
            error("string length is larger than $(bsizeof(T)), use @lbit_str instead")
    end
    return BitStr{k - 1,T}(val)
end

sum_length(a::BitStr, bits::BitStr...) = length(a) + sum_length(bits...)
sum_length(a::BitStr) = length(a)

function bcat(bit::BitStr{N,T}, bits::BitStr...) where {N,T<:Integer}
    total_bits = sum_length(bit, bits...)
    val, len = zero(T), 0

    for k in length(bits):-1:1
        val += buffer(bits[k]) << len
        len += length(bits[k])
    end
    val += buffer(bit) << len
    len += length(bit)
    return BitStr{total_bits,T}(val)
end

# expand iterator to tuple
bcat(bits) = bcat(bits...)

Base.@propagate_inbounds function Base.getindex(bit::BitStr{N}, index::Int) where {N}
    @boundscheck 1 <= index <= N || throw(BoundsError(bit, index))
    return buffer(readbit(bit, index))
end

Base.@propagate_inbounds function Base.getindex(
    bit::BitStr{N,T},
    itr::AbstractVector,
) where {N,T}
    @boundscheck all(x -> 1 <= x <= N, itr) || throw(BoundsError(bit, itr))
    return map(x -> buffer(readbit(bit, x)), itr)
end

# TODO: support AbstractArray, should return its corresponding shape

Base.@propagate_inbounds function Base.getindex(
    bit::BitStr{N,T},
    mask::AbstractVector{Bool},
) where {N,T}
    @boundscheck N == length(mask) || error("length of bits and mask does not match.")

    out = T[]
    for k in eachindex(mask)
        if mask[k]
            push!(out, bit[k])
        end
    end
    return out
end

Base.eltype(::BitStr{N,T}) where {N,T} = T

function Base.iterate(bit::BitStr, state::Integer = 1)
    if state > length(bit)
        return nothing
    else
        return bit[state], state + 1
    end
end
Base.IteratorSize(::BitStr) = Base.HasLength()

Base.repeat(s::BitStr, n::Integer) = bcat(s for i in 1:n)
Base.show(io::IO, bitstr::BitStr64{N}) where {N} =
    print(io, string(buffer(bitstr), base = 2, pad = N), " ₍₂₎")
Base.show(io::IO, bitstr::LongBitStr{N}) where {N} =
    print(io, join(map(string, [bitstr[end:-1:1]...])), " ₍₂₎")

"""
    onehot([T=Float64], bit_str[, nbatch])

Returns an onehot vector in type `Vector{T}`, or a batch of onehot
vector in type `Matrix{T}`, where the `bit_str`-th element is one.
"""
onehot(::Type{T}, n::BitStr{N}) where {T,N} = onehot(T, N, buffer(n))
onehot(n::BitStr) = onehot(Float64, n)

onehot(::Type{T}, n::BitStr{N}, nbatch::Int) where {T,N} = onehot(T, N, buffer(n), nbatch)
onehot(n::BitStr, nbatch::Int) = onehot(Float64, n, nbatch)

# operations
"""
    breflect(bit_str[, masks])

Return left-right reflected bit string.
"""
breflect(b::BitStr{N}) where {N} = breflect(b; nbits = N)
breflect(b::BitStr{N,T}, masks::Vector{<:BitStr{N,T}}) where {N,T} =
    BitStr{N,T}(breflect(buffer(b), reinterpret(T, masks); nbits = N))

"""
    neg(b::BitStr) -> BitStr
"""
neg(b::BitStr{N}) where {N} = neg(b, N)

"""
    bfloat(b::BitStr) -> Float64
"""
bfloat(b::BitStr{N}) where {N} = bfloat(buffer(b); nbits = N)

"""
    bfloat_r(b::BitStr) -> Float64
"""
bfloat_r(b::BitStr{N}) where {N} = bfloat_r(buffer(b); nbits = N)

"""
    bint_r(b::BitStr) -> Integer
"""
bint_r(b::BitStr{N}) where {N} = buffer(breflect(b))

"""
    bint(b::BitStr) -> Integer
"""
bint(b::BitStr) = buffer(b)

"""
    bit_literal(xs...)

Create a [`BitStr`](@ref) by input bits `xs`.

# Example

```jldoctest
julia> bit_literal(1, 0, 1, 0, 1, 1)
110101 ₍₂₎
```
"""
bit_literal(x::Int, xs::Int...) = bit_literal((x, xs...))

function bit_literal(xs::Tuple{T, Vararg{T, N}}) where {T <: Integer, N}
    val = T(0)
    for k in 1:N+1
        xs[k] == 0 || xs[k] == 1 || error("expect 0 or 1, got $(xs[k])")
        val += xs[k] << (k - 1)
    end
    return BitStr64{N+1}(val)
end

basis(b::BitStr) = typemin(b):typemax(b)
basis(::Type{BT}) where {BT<:BitStr} = typemin(BT):typemax(BT)
