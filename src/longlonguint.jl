"""
    LongLongUInt{N, C} <: Integer

A `LongLongUInt{N, C}` is an integer with `N` valid bits and `C` `UInt` numbers to store the value.
"""
struct LongLongUInt{N, C} <: Integer
    content::NTuple{C, UInt}
    function LongLongUInt{N, C}(content::NTuple{C}) where {N, C}
        new{N, C}(UInt.(content))
    end
end
bsizeof(::LongLongUInt{N}) where N = N
nint(::LongLongUInt{N, C}) where {N, C} = C
Base.Int(x::LongLongUInt{N, 1}) where {N} = Int(x.content[1])
Base.UInt(x::LongLongUInt{N, 1}) where {N} = x.content[1]
Base.zero(::Type{LongLongUInt{N, C}}) where {N, C} = LongLongUInt{N, C}(ntuple(_->UInt(0), C))
Base.zero(::LongLongUInt{N, C}) where {N, C} = zero(LongLongUInt{N, C})
LongLongUInt{N}(content::NTuple{C}) where {N, C} = LongLongUInt{N, C}(content)
LongLongUInt{N,C}(x::T) where {N, C, T<:Integer} = LongLongUInt{N, C}(ntuple(i->i==1 ? UInt(x) : zero(UInt), C))
Base.promote_type(::Type{LongLongUInt{N, C}}, ::Type{Int}) where {N, C} = LongLongUInt{N, C}
Base.promote_type(::Type{LongLongUInt{N, C}}, ::Type{UInt}) where {N, C} = LongLongUInt{N, C}
Base.promote_type(::Type{LongLongUInt{N, C}}, ::Type{LongLongUInt{N, C}}) where {N, C} = LongLongUInt{N, C}
function Base.mod(x::LongLongUInt{N, C}, D::Int) where {N, C}
    D == 2 ? mod(x.content[end], 2) : error("mod only supports 2")
end

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