export BitStr, @bit_str, bcat, bit_literal, to_location, onehot, onehot_batch

"""
    BitStr{N} <: Integer

primitive type for bit string with fixed length `N`, implements an integer with 64 bit storage.

    BitStr{N}(value)

Returns a `BitStr`.

## Example

`BitStr` supports some basic arithmetic operations. It acts like an integer, but supports
some frequently used methods for binary basis.

```julia
julia> bit"0101" * 2
1010

julia> bcat(bit"101" for i in 1:10)
101101101101101101101101101101 (766958445)

julia> repeat(bit"101", 2)
101101

julia> bit"1101"[2]
0
```
"""
primitive type BitStr{N} <: Integer 64 end
BitStr{N}(val::Integer) where N = reinterpret(BitStr{N}, convert(Int64,val))
Base.convert(::Type{T}, b::BitStr) where T<:Integer = convert(T, reinterpret(Int64, b))
for IT in [:BigInt, :Int128, :UInt128, :Int64,:UInt64, :Int32, :UInt32, :Int16, :UInt16, :Int8, :UInt8, :Bool]
    @eval Base.$IT(b::BitStr) = $IT(reinterpret(Int64, b))
end
for op in [:+, :-, :*, :÷, :|, :⊻, :&, :%, :mod, :mod1]
    @eval Base.$op(a::T, b::Integer) where T<:BitStr = reinterpret(T, Base.$op(Int64(a),b))
    @eval Base.$op(a::Integer, b::T) where T<:BitStr = reinterpret(T, Base.$op(a,Int64(b)))
    @eval Base.$op(a::T, b::T) where T<:BitStr = reinterpret(T, Base.$op(Int64(a),Int64(b)))
end
for op in [:(>>), :(<<)]
    @eval Base.$op(a::T, b::Int64) where T<:BitStr = reinterpret(T, Base.$op(Int64(a),b))
    #@eval Base.$op(a::T, b::T) where T<:BitStr = reinterpret(T, Base.$op(Int64(a),Int64(b)))
end

for op in [:<, :>, :(<=), :(>=)]
    @eval Base.$op(a::T, b::T) where T<:BitStr = Base.$op(Int64(a),Int64(b))
end

for op in [:(==)]
    @eval Base.$op(a::T, b::Number) where T<:BitStr = Base.$op(Int64(a),b)
    @eval Base.$op(a::Number, b::T) where T<:BitStr = Base.$op(a,Int64(b))
    @eval Base.$op(a::T, b::T) where T<:BitStr = Base.$op(Int64(a),Int64(b))
end
for op in [:count_ones, :count_zeros, :leading_ones, :leading_zeros]
    @eval Base.$op(a::BitStr) = Base.$op(Int64(a))
end

# Note: the transitivity of == is not satisfied here.
Base.:(==)(lhs::BitStr, rhs::BitStr) = false
Base.isapprox(a::BitStr, b::Number; kwargs...) = Base.isapprox(Int64(a),b; kwargs...)
Base.isapprox(a::Number, b::BitStr; kwargs...) = Base.isapprox(a,Int64(b); kwargs...)
Base.isapprox(lhs::BitStr, rhs::BitStr; kwargs...) = false
Base.isapprox(a::T, b::T; kwargs...) where T<:BitStr = Base.isapprox(Int64(a),Int64(b); kwargs...)

# Note: it is a bit confusing, with x::BitStr == y::Int64,
# they behave different when used for indexing.
Base.to_index(x::BitStr) = Int64(x) + 1

# use system interface
Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, i::BitStr) =
    checkindex(Bool, inds, Base.to_index(i))
Base.length(bits::BitStr{N}) where N = N
Base.lastindex(bits::BitStr) = length(bits)

Base.typemax(::Type{BitStr{N}}) where N = BitStr{N}(1<<N-1)
Base.typemin(::Type{BitStr{N}}) where N = BitStr{N}(0)
Base.typemax(::BitStr{N}) where N = BitStr{N}(1<<N-1)
Base.typemin(::BitStr{N}) where N = BitStr{N}(0)

"""
    @bit_str -> BitStr

Construct a bit string. such as `bit"0000"`. The bit strings also supports string `bcat`. Just use
it like normal strings.

## Example

```jldoctest
julia> bit"10001"
10001

julia> bit"100_111_101"
100111101

julia> bcat(bit"1001", bit"11", bit"1110")
1001111110 (638)

julia> v = collect(1:16);

julia> v[bit"1001"]
10

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

function parse_bit(::Type{T}, str::String) where {T <: Integer}
    val = Int64(0); k = 1
    for each in reverse(filter(x->x!='_', str))
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
    end

    return BitStr{k-1}(val)
end

function bcat(bits::BitStr...)
    total_bits = mapreduce(length, +, bits)
    val, len = Int64(0), 0

    for k in length(bits):-1:1
        val += Int64(bits[k]) << len
        len += length(bits[k])
    end
    return BitStr{total_bits}(val)
end

# expand iterator to tuple
bcat(bits) = bcat(bits...)

Base.@propagate_inbounds function Base.getindex(bit::BitStr{N}, index::Int) where N
    @boundscheck 1 <= index <= N || throw(BoundsError(bit, index))
    return Int64(readbit(bit, index))
end

Base.@propagate_inbounds function Base.getindex(bit::BitStr{N}, itr::Union{AbstractVector, AbstractRange}) where N
    @boundscheck all(x->1<=x<=N, itr) || throw(BoundsError(bit, itr))
    return map(x->Int64(readbit(bit, x)), itr)
end

# TODO: support AbstractArray, should return its corresponding shape

Base.@propagate_inbounds function Base.getindex(bit::BitStr{N}, mask::Union{Vector{Bool}, BitArray}) where N
    @boundscheck N == length(mask) || error("length of bits and mask does not match.")

    out = Int64[]
    for k in eachindex(mask)
        if mask[k]
            push!(out, bit[k])
        end
    end
    return out
end

Base.eltype(::T) where T<:BitStr = Int64

function Base.iterate(bit::BitStr, state::Integer=1)
    if state > length(bit)
        return nothing
    else
        return bit[state], state + 1
    end
end
Base.IteratorSize(::BitStr) = Base.HasLength()

Base.repeat(s::BitStr, n::Integer) = bcat(s for i in 1:n)
Base.show(io::IO, bitstr::BitStr{N}) where N = print(io, string(Int64(bitstr), base=2, pad=N))

"""
    onehot([T=Float64], bit_str[, nbatch])

Returns an onehot vector in type `Vector{T}`, or a batch of onehot
vector in type `Matrix{T}`, where the `bit_str`-th element is one.
"""
onehot(::Type{T}, n::BitStr{N}) where {T,N} = onehot(T, N, Int64(n))
onehot(n::BitStr) = onehot(Float64, n)

onehot(::Type{T}, n::BitStr{N}, nbatch::Int) where {T,N} = onehot(T, N, Int64(n), nbatch)
onehot(n::BitStr, nbatch::Int) = onehot(Float64, n, nbatch)

# operations
"""
    breflect(bit_str[, masks])

Return left-right reflected bit string.
"""
breflect(b::BitStr{N}) where N = breflect(b; nbits=N)
breflect(b::BitStr{N}, masks::Vector{<:Integer}) where N = BitStr{N}(breflect(Int64(b), masks; nbits=N))

"""
    neg(b::BitStr) -> BitStr
"""
neg(b::BitStr{N}) where N = neg(b, N)

"""
    bfloat(b::BitStr) -> Float64
"""
bfloat(b::BitStr{N}) where N = bfloat(b; nbits=N)

"""
    bfloat_r(b::BitStr) -> Float64
"""
bfloat_r(b::BitStr{N}) where N = bfloat_r(b; nbits=N)

"""
    bint_r(b::BitStr) -> Int64
"""
bint_r(b::BitStr{N}) where N = Int64(breflect(b))

"""
    bint(b::BitStr) -> Int64
"""
bint(b::BitStr) = Int64(b)

"""
    bit_literal(xs...)

Create a [`BitStr`](@ref) by input bits `xs`.

# Example

```jldoctest
julia> bit_literal(1, 0, 1, 0, 1, 1)
110101
```
"""
bit_literal(xs...) = bit_literal(xs)
function bit_literal(xs::NTuple{N, Int}) where N
    val = Int64(0)
    for k in 1:N
        xs[k] == 0 || xs[k] == 1 || error("expect 0 or 1, got $(xs[k])")
        val += xs[k] << (k - 1)
    end
    return BitStr{N}(val)
end

basis(b::BitStr) = typemin(b):typemax(b)
basis(::Type{BT}) where BT<:BitStr = typemin(BT):typemax(BT)
