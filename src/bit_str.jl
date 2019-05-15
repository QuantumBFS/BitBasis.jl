export BitStr, @bit_str, bcat, bit_literal, bit, to_location, onehot, onehot_batch

"""
    BitStr{T}

String literal for bits.

    BitStr(value[, len=ndigits(value)])

Returns a `BitStr`, by default the length is set to the minimum length required to represent
`value` as bits.

    BitStr(str::String)

Parse the input string to a BitStr. See [`@bit_str`](@ref) for more details.

## Example

`BitStr` supports some basic arithmetic operations. It acts like an integer, but supports
some frequently used methods for binary basis.

```julia
julia> bit"101" * 2
1010 (10)

julia> bcat(bit"101" for i in 1:10)
101101101101101101101101101101 (766958445)

julia> repeat(bit"101", 2)
101101 (45)

julia> bit"1101"[2]
0
```
"""
struct BitStr{T <: Integer, N}
    val::T

    BitStr(value::T, len=ndigits(value, base=2)) where T = new{T, len}(value)
end

function BitStr(str::String)
    str = eat_underscore(str)
    required_nbits = length(str)

    # NOTE: since in most cases this is used as basis and used for indexing
    #       we use Int as much as possible.
    return parse_bit(promote_type(Int, int(required_nbits)), str)
end

BitStr(x::BitStr{T, N}) where {T, N} = BitStr(x.val, N)

"""
    bit(string)

Create a [`BitStr`](@ref) with given string of bits. See also [`@bit_str`](@ref).
"""
bit(x::String) = BitStr(x)

"""
    bit(x[; len=ndigits(x, base=2)])

Create a [`BitStr`](@ref) accroding to integer `x` to given length `len`.
"""
bit(x::Integer; len=ndigits(x, base=2)) = BitStr(x, len)

"""
    bit(;len)

Lazy curried version of [`bit`](@ref).
"""
bit(;len) = x -> bit(x; len=len)

"""
    bit_literal(xs...)

Create a [`BitStr`](@ref) by input bits `xs`.

# Example

```jldoctest
julia> bit_literal(1, 0, 1, 0, 1, 1)
110101 (53)
```
"""
bit_literal(xs...) = bit_literal(xs)
function bit_literal(xs::NTuple{N, Int}) where N
    val = zero(int(N))
    for k in 1:N
        xs[k] == 0 || xs[k] == 1 || error("expect 0 or 1, got $(xs[k])")
        val += xs[k] << (k - 1)
    end
    return BitStr(val, N)
end

# use system interface
Base.to_index(x::BitStr) = Int(x.val) + 1
Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, i::BitStr) =
    checkindex(Bool, inds, Base.to_index(i))
Base.length(bits::BitStr{<:Integer, N}) where N = N
Base.lastindex(bits::BitStr) = length(bits)

"""
    to_location(x)

Convert bit configuration `x` to an index.

# Example

```jldoctest
julia> to_location(1)
2

julia> to_location(bit"111")
111 (7)
```
"""
to_location(x) = error("expect an integer or @bit_str, got $(typeof(x))")
to_location(x::Integer) = x + 1
to_location(x::BitStr) = x


"""
    @bit_str -> BitStr

Construct a bit string. such as `bit"0000"`. The bit strings also supports string `bcat`. Just use
it like normal strings.

## Example

```jldoctest
julia> bit"10001"
10001 (17)

julia> bit"100_111_101"
100111101 (317)

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
    return BitStr(str)
end

eat_underscore(str::String) = filter(x->x!='_', str)

function parse_bit(::Type{T}, str::String) where {T <: Integer}
    val = zero(T); k = 1
    for each in reverse(str)
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

    return BitStr(val, k - 1)
end

sum_length(a::BitStr, bits::BitStr...) = length(a) + sum_length(bits...)
sum_length(a::BitStr) = length(a)

function bcat(bits::BitStr...)
    total_bits = sum_length(bits...)
    T = promote_type(Int, int(total_bits))
    val = zero(T); len = 0

    for k in length(bits):-1:1
        val += T(bits[k].val) << len
        len += length(bits[k])
    end
    return BitStr(val, total_bits)
end

# expand iterator to tuple
bcat(bits) = bcat(bits...)

Base.@propagate_inbounds function Base.getindex(bit::BitStr{T}, index::Int) where T
    @boundscheck 1 <= index <= length(bit) || throw(BoundsError(bit, index))
    return readbit(bit.val, index)
end

Base.@propagate_inbounds function Base.getindex(bit::BitStr{T}, itr::Union{AbstractVector, AbstractRange}) where T
    @boundscheck all(x->1<=x<=length(bit), itr) || throw(BoundsError(bit, itr))
    return map(x->readbit(bit.val, x), itr)
end

# TODO: support AbstractArray, should return its corresponding shape

Base.@propagate_inbounds function Base.getindex(bit::BitStr{T}, mask::Union{Vector{Bool}, BitArray}) where T
    @boundscheck length(bit) == length(mask) || error("length of bits and mask does not match.")

    out = T[]
    for k in eachindex(mask)
        if mask[k]
            push!(out, bit[k])
        end
    end
    return out
end

Base.@propagate_inbounds function Base.:(<<)(bit::BitStr, n::Int)
    @boundscheck n + length(bit) < bsizeof(bit.val) || OverflowError()
    return BitStr(bit.val << n, length(bit) + n)
end

Base.@propagate_inbounds function Base.:(>>)(bit::BitStr, n::Int)
    @boundscheck length(bit) - n > 0 || OverflowError()
    return BitStr(bit.val >> n, length(bit) - n)
end

# Forward if it's not on BitStr
Base.:(<<)(n::Int, b::BitStr) = n << b.val
Base.:(>>)(n::Int, b::BitStr) = n >> b.val

for op in [:+, :-, :*, :÷]

    @eval function Base.$op(lhs::BitStr, rhs::BitStr)
        return BitStr($op(lhs.val, rhs.val), ndigits($op(lhs.val, rhs.val), base=2, pad=max(length(lhs), length(rhs))))
    end

    @eval function Base.$op(lhs::BitStr, rhs::Integer)
        return BitStr($op(lhs.val, rhs), ndigits($op(lhs.val, rhs), base=2, pad=length(lhs)))
    end

    @eval function Base.$op(lhs::Integer, rhs::BitStr)
        return $op(rhs, lhs)
    end

end

Base.mod1(x::BitStr{T, N}, y) where {T, N} = BitStr(mod1(x.val, y), N)

Base.:(==)(lhs::BitStr, rhs::Integer) = lhs.val == rhs
Base.:(==)(lhs::Integer, rhs::BitStr) = lhs == rhs.val
Base.:(==)(lhs::BitStr{<:Integer, N}, rhs::BitStr{<:Integer, N}) where N = lhs.val == rhs.val
Base.:(==)(lhs::BitStr, rhs::BitStr) = false

Base.eltype(::BitStr{T}) where T = T

function Base.iterate(bit::BitStr, state::Integer=1)
    if state > length(bit)
        return nothing
    else
        return bit[state], state + 1
    end
end

Base.repeat(s::BitStr, n::Integer) = bcat(s for i in 1:n)
Base.show(io::IO, bitstr::BitStr) = print(io, string(bitstr.val, base=2, pad=length(bitstr)), " (", bitstr.val, ")")

"""
    onehot([T=Float64], bit_str)

Returns an onehot vector of type `Vector{T}`, where the `bit_str`-th element is one.
"""
onehot(::Type{T}, n::BitStr) where T = onehot(T, length(n), n.val)
onehot(n::BitStr) = onehot(Float64, n)

onehot_batch(::Type{T}, n::BitStr, nbatch::Int) where T = onehot_batch(T, length(n), n.val, nbatch)
onehot_batch(n::BitStr, nbatch::Int) = onehot_batch(Float64, n, nbatch)

# conversions
for IntType in [:Int8, :Int16, :Int32, :Int64, :Int128, :BigInt]
    @eval Base.convert(::Type{$IntType}, x::BitStr) = $IntType(x.val)
    @eval Base.$IntType(x::BitStr) = $IntType(x.val)
end

# operations

btruncate(b::BitStr, n) = BitStr(btruncate(b.val, n), n)

"""
    breflect(bit_str[, masks])

Return left-right reflected bit string.
"""
breflect(b::BitStr) = bit(breflect(length(b), b.val); len=length(b))
breflect(b::BitStr, masks::Vector{<:Integer}) = bit(breflect(length(b), b.val, masks), len=length(b))

"""
    neg(bit_str) -> Integer

Return an [`BitStr`](@ref) with all bits flipped.

# Example

```jldoctest
julia> neg(bit"1111", 4)
0000 (0)

julia> neg(bit"0111", 4)
1000 (8)
```
"""
neg(bit::BitStr) = bit(neg(bit.val, length(bit)); len=length(bit))

"""
    flip(bit_str, mask::Integer) -> Integer

Return an [`BitStr`](@ref) with bits at masked position flipped.

# Example

```jldoctest
julia> flip(bit"1011", 0b1011)
0000 (0)
```
"""
flip(b::BitStr{T}, mask::Integer) where T = flip(b.val, T(mask)) |> bit(len=length(b))


"""
    swapbits(n::BitStr, mask_ij::Integer) -> BitStr
    swapbits(n::BitStr, i::Int, j::Int) -> BitStr

Return a [`BitStr`](@ref) with bits at `i` and `j` flipped.

# Example

```jldoctest
julia> swapbits(0b1011, 0b1100) == 0b0111
true
```

!!! warning

    `mask_ij` should only contain two `1`, `swapbits` will not check it, use at
    your own risk.
"""
swapbits(b::BitStr, i::Int, j::Int) = bit(swapbits(b.val, i, j); len=length(b))
swapbits(b::BitStr{T}, mask::Integer) where T = bit(swapbits(b.val, T(mask)); len=length(b))

"""
    setbit(b::BitStr, mask::Integer) -> Integer

set the bit at masked position to 1.

# Example

```jldoctest
julia> setbit(bit"1011", 0b1100)
1111 (15)

julia> setbit(bit"1011", 0b0100)
1111 (15)

julia> setbit(bit"1011", 0b0000)
1011 (11)
```
"""
setbit(b::BitStr{T}, mask::Integer) where T = setbit(b.val, T(mask)) |> bit(len=length(b))


"""
    anyone(b::BitStr, mask::Integer) -> Bool

Return `true` if any masked position of index is 1.

# Example

`true` if any masked positions is 1.

```jldoctest
julia> anyone(bit"1011", 0b1001)
true

julia> anyone(bit"1011", 0b1100)
true

julia> anyone(bit"1011", 0b0100)
false
```
"""
anyone(b::BitStr{T}, mask::Integer) where T = anyone(b.val, mask) |> bit(len=length(b))

"""
    allone(b::BitStr, mask::Integer) -> Bool

Return `true` if all masked position of index is 1.

# Example

`true` if all masked positions are 1.

```jldoctest
julia> allone(bit"1011", 0b1011)
true

julia> allone(bit"1011", 0b1001)
true

julia> allone(bit"1011", 0b0100)
false
```
"""
allone(b::BitStr{T}, mask::Integer) where T = allone(b.val, T(mask))

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
ismatch(b::BitStr{T}, mask::Integer, target::Integer) where T = ismatch(b.val, T(mask), T(target))

# NOTE: we have to return a vector here since this is calculated in runtime

"""
    baddrs(b::Integer) -> Vector

get the locations of nonzeros bits, i.e. the inverse operation of bmask.
"""
baddrs(b::BitStr) = baddrs(b.val) |> bit(len=length(b))


"""
    bfloat(b::BitStr) -> Float64

float view, with MSB 0 bit numbering.
See also [wiki: bit numbering](https://en.wikipedia.org/wiki/Bit_numbering)
"""
bfloat(b::BitStr) = bfloat(b.val; nbits=length(b))

"""
    bfloat_r(b::Integer; nbits::Int) -> Float64

float view, with bits read in inverse order.
"""
bfloat_r(b::BitStr) = bfloat_r(b.val; nbits=length(b))

"""
    bint(b; nbits=nothing) -> Int

integer view, with LSB 0 bit numbering.
See also [wiki: bit numbering](https://en.wikipedia.org/wiki/Bit_numbering)
"""
bint(b::BitStr) = b.val

"""
    bint_r(b; nbits::Int) -> Integer

integer read in inverse order.
"""
bint_r(b::BitStr) = breflect(b; nbits=length(b))
