export BitStr, @bit_str, bcat, to_address

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

"""
    to_address(x)

Convert `x` to address.

# Example

```julia
julia> to_address(1)
1

julia> to_address(-1)
ERROR: address should be >= 1

julia> to_address(bit"1011")
12
```
"""
function to_address end
to_address(x::Nothing) = x
to_address(x::Integer) = x > 0 ? x : error("address should be >= 1")
to_address(x::BitStr) = Int(x.val) + 1
# better error msg
to_address(x::T) where T = error("$T is not an address type, maybe you want to overload to_address(::$T)")
to_address(x::Type{T}) where T = error("$T is not an address type, maybe you want to overload to_address(::$T)")



"""
    to_address(locs...)

Maps locations to indices.

# Example

```julia
julia> to_address(bit"1010", 2, bit"1111")
(11, 2, 16)
```
"""
to_address(locs...) = to_address(locs)
to_address(locs::Tuple) = map(to_address, locs)

# use system interface
Base.to_index(::Tuple, bits::BitStr) = to_address(bits)
Base.to_index(::AbstractArray, bits::BitStr) = to_address(bits)
Base.length(bits::BitStr{<:Integer, N}) where N = N


"""
    @bit_str -> BitStr

Construct a bit string. such as `bit"0000"`. The bit strings also supports string `bcat`. Just use
it like normal strings.

## Example

```julia
julia> bit"10001"
10001 (17)

julia> bit"100_111_101"
00001110101 (117)

julia> bcat(bit"1001", bit"11", bit"1110")
1001111110 (638)

julia> v = rand(16);

julia> v[bit"1001"]
0.38965443157314406

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

Base.@propagate_inbounds function Base.getindex(bit::BitStr, index::Int)
    @boundscheck 1 <= index <= length(bit) || throw(BoundsError(bit, index))
    return Int((bit.val >> (index - 1)) & 1)
end

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

# conversions
for IntType in [:Int8, :Int16, :Int32, :Int64, :Int128, :BigInt]
    @eval Base.$IntType(x::BitStr) = $IntType(x.val)
end

# TODO: support operations defined in operations.jl for BitStr
#    - bmask
