"""
    LongLongUInt{N, C} <: Integer

A `LongLongUInt{N, C}` is an integer with `N` valid bits and `C` `UInt` numbers to store the value.
"""
struct LongLongUInt{N, C} <: Integer
    content::NTuple{C, UInt}
end
Base.Int(x::LongLongUInt{N, 1}) where {N} = Int(x.content[1])
Base.UInt(x::LongLongUInt{N, 1}) where {N} = x.content[1]
LongLongUInt{N}(content::NTuple{C, T}) where {N, C, T<:Integer} = LongLongUInt{N, C}(content)

Base.:(>>)(x::LongLongUInt{N}, y::Int) where N = LongLongUInt{N}(x.content .>> y)
Base.:(<<)(x::LongLongUInt{N}, y::Int) where N = LongLongUInt{N}(x.content .<< y)
for OP in [:&, :|, :xor]
    @eval Base.$OP(x::LongLongUInt{N,C}, y::LongLongUInt{N, C}) where {N,C} = LongLongUInt{N, C}($OP.(x.content, y.content))
end
Base.:(~)(x::LongLongUInt{N, C}) where {N, C} = LongLongUInt{N, C}((~).(x.content))
function Base.:(+)(x::LongLongUInt{N,C}, y::LongLongUInt{N, C}) where {N,C}
    return LongLongUInt{N}(_sadd(x.content, y.content, false))
end
function _sadd(x::NTuple{1,UInt}, y::NTuple{1,UInt}, c::Bool)
    return (x[1] + y[1] + c,)
end
function _sadd(x::NTuple{C,UInt}, y::NTuple{C,UInt}, c::Bool) where {C}
    v1, c1 = Base.add_with_overflow(x[C], y[C])
    if c
        v2, c2 = Base.add_with_overflow(v1, c)
        c = c1 || c2
        return (_sadd(x[1:C-1], y[1:C-1], c)..., v2)
    else
        return (_sadd(x[1:C-1], y[1:C-1], c1)..., v1)
    end
end
Base.count_ones(x::LongLongUInt{N}) where N = sum(c->count_ones(c), x.content)