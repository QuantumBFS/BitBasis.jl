######################## BitStr #########################
"""
    BitStr{N,T} <: Integer

The struct for bit string with fixed length `N` and storage type `T`.
It is an alias of `DitStr{2,N,T}`.

    BitStr{N,T}(integer)
    BitStr64{N}(integer)
    BitStr64(vector)
    LongBitStr{N}(integer)
    LongBitStr(vector)

Returns a `BitStr`.
When the input is an integer, the bits are read from right to left.
When the input is a vector, the bits are read from left to right.

## Examples

`BitStr` supports some basic arithmetic operations. It acts like an integer, but supports
some frequently used methods for binary basis.

```jldoctest
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
const BitStr{N,T} = DitStr{2,N,T}
const BitStr64{N} = BitStr{N,Int64}
const LongBitStr{N} = BitStr{N,BigInt}
const BitStr{N}(x::T) where {N,T<:IntStorage} = DitStr{2,N}(x)

# only for bitstr
for op in [:(>>), :(<<)]
    @eval Base.$op(a::BitStr{N,T}, b::Int) where {N,T} = BitStr{N,T}(Base.$op(buffer(a), b))
end

for op in [:count_ones, :count_zeros, :leading_ones, :leading_zeros, :trailing_zeros, :trailing_ones]
    @eval Base.$op(a::BitStr) = Base.$op(buffer(a))
end

########## @bit_str macro ##############
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
    return _parse_dit(Val(2), Int64, str)
end

"""
    @lbit_str -> LongBitStr

Long bit string version of `@bit_str` macro.
"""
macro lbit_str(str)
    return _parse_dit(Val(2), BigInt, str)
end

onehot(::Type{T}, n::BitStr{N,T1}; nbatch=nothing) where {N,T1,T} = onehot(n=>one(T); nbatch)
onehot(n::BitStr{N,T1}; nbatch=nothing) where {N,T1} = onehot(Float64, n; nbatch)

######## Extra bit string operations #######
"""
    bit_literal(xs...)

Create a [`BitStr`](@ref) by input bits `xs`.

# Example

```jldoctest
julia> bit_literal(1, 0, 1, 0, 1, 1)
110101 ₍₂₎
```
"""
bit_literal(x::Integer, xs::Integer...) = bit_literal((x, xs...))
function bit_literal(xs::Tuple{T,Vararg{T,N}}) where {T<:Integer,N}
    DitStr{2}(xs)
end

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