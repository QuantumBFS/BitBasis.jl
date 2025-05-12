"""
    LongLongUInt{C} <: Integer

A `LongLongUInt{C}` is an integer with `C` `UInt` numbers to store the value.
"""
struct LongLongUInt{C} <: Unsigned
    content::NTuple{C, UInt}
    function LongLongUInt{C}(content::NTuple{C, UInt}) where {C}
        new{C}(content)
    end
    function LongLongUInt{C}(content::NTuple{C}) where {C}
        new{C}(UInt.(content))
    end
    function LongLongUInt(content::NTuple{C}) where {C}
        LongLongUInt{C}(content)
    end
end
Base.string(x::LongLongUInt{C}) where {C} = "LongLongUInt{$C}(" * join(bitstring.(x.content), "") * ")"
Base.show(io::IO, x::LongLongUInt{C}) where {C} = print(io, string(x))
Base.show(io::IO, ::MIME"text/plain", x::LongLongUInt{C}) where {C} = print(io, string(x))
bsizeof(::LongLongUInt{C}) where C = bsizeof(UInt64) * C
nint(::LongLongUInt{C}) where {C} = C
Base.Int(x::LongLongUInt{1}) = Int(x.content[1])
Base.UInt(x::LongLongUInt{1}) = x.content[1]
Base.zero(::Type{LongLongUInt{C}}) where {C} = LongLongUInt{C}(ntuple(_->UInt(0), Val{C}()))
Base.zero(::LongLongUInt{C}) where {C} = zero(LongLongUInt{C})
# convert from integers
LongLongUInt{C}(x::T) where {C, T<:Integer} = LongLongUInt{C}(ntuple(i->i==C ? UInt(x) : zero(UInt), Val{C}()))
LongLongUInt{C}(x::LongLongUInt{C}) where {C} = x
Base.promote_rule(::Type{LongLongUInt{C}}, ::Type{Int}) where {C} = LongLongUInt{C}
Base.promote_rule(::Type{LongLongUInt{C}}, ::Type{UInt}) where {C} = LongLongUInt{C}
function Base.mod(x::LongLongUInt{C}, D::Int) where {C}
    D == 2 ? mod(x.content[end], 2) : error("mod only supports 2")
end

function Base.:(>>)(x::LongLongUInt{1}, y::Int)
    return LongLongUInt{1}(x.content[1] >> y)
end
function Base.:(<<)(x::LongLongUInt{1}, y::Int)
    return LongLongUInt{1}(x.content[1] << y)
end

function readbit(x::LongLongUInt{1}, loc::Int)
    return readbit(x.content[1], loc)
end
function indicator(::Type{LongLongUInt{1}}, i::Int)
    return LongLongUInt{1}(indicator(UInt, i))
end

function Base.:(<)(val1::LongLongUInt{1}, val2::LongLongUInt{1})
    return val1.content[1] < val2.content[1]
end

function Base.:(<)(val1::LongLongUInt{C}, val2::LongLongUInt{C}) where{C}
    for i in 1:C
        if val1.content[i] < val2.content[i]
            return true
        elseif val1.content[i] > val2.content[i]
            return false
        end
    end
    return false
end

function Base.:(>>)(x::LongLongUInt{C}, y::Int) where {C}
    y < 0 && return x << -y
    nshift = y ÷ bsizeof(UInt)
    nshift_inner = y % bsizeof(UInt)
    LongLongUInt(ntuple(Val{C}()) do k
            right = k<=nshift ? zero(UInt) : x.content[k-nshift]
            left = k<=(nshift+1) ? zero(UInt) : x.content[k-nshift-1]
            (right >> nshift_inner) | (left << (bsizeof(UInt) - nshift_inner))
        end
    )
end
function Base.:(<<)(x::LongLongUInt{C}, y::Int) where C
    y < 0 && return x >> -y
    nshift = y ÷ bsizeof(UInt)
    nshift_inner = y % bsizeof(UInt)
    LongLongUInt(ntuple(Val{C}()) do k
            left = k>C-nshift ? zero(UInt) : x.content[k+nshift]
            right = k>C-nshift-1 ? zero(UInt) : x.content[k+nshift+1]
            (left << nshift_inner) | (right >> (bsizeof(UInt) - nshift_inner))
        end
    )
end
function readbit(x::LongLongUInt{C}, loc::Int) where {C}
    k = (loc-1) ÷ bsizeof(UInt)
    return readbit(x.content[C-k], loc - k*bsizeof(UInt))
end
function indicator(::Type{LongLongUInt{C}}, i::Int) where C
    k = (i-1) ÷ bsizeof(UInt)
    LongLongUInt{C}(ntuple(j->j==C-k ? indicator(UInt, i-k*bsizeof(UInt)) : zero(UInt), Val{C}()))
end
for OP in [:&, :|, :xor]
    @eval Base.$OP(x::LongLongUInt{C}, y::LongLongUInt{C}) where {C} = LongLongUInt{C}($OP.(x.content, y.content))
end
Base.:(~)(x::LongLongUInt{C}) where {C} = LongLongUInt{C}((~).(x.content))
function Base.:(+)(x::LongLongUInt{C}, y::LongLongUInt{C}) where {C}
    return LongLongUInt(_sadd(x.content, y.content, false))
end
function _sadd(x::NTuple{1,UInt}, y::NTuple{1,UInt}, c::Bool)
    return (x[1] + y[1] + c,)
end
function _sadd(x::NTuple{C,UInt}, y::NTuple{C,UInt}, c::Bool) where {C}
    v1, c1 = Base.add_with_overflow(x[C], y[C])
    if c
        v2, c2 = Base.add_with_overflow(v1, UInt(c))
        c = c1 || c2
        return (_sadd(x[1:C-1], y[1:C-1], c)..., v2)
    else
        return (_sadd(x[1:C-1], y[1:C-1], c1)..., v1)
    end
end
function Base.:(-)(x::LongLongUInt{C}, y::LongLongUInt{C}) where {C}
    return LongLongUInt(_ssub(x.content, y.content, false))
end
function _ssub(x::NTuple{1,UInt}, y::NTuple{1,UInt}, c::Bool)
    return (x[1] - y[1] - c,)
end
function _ssub(x::NTuple{C,UInt}, y::NTuple{C,UInt}, c::Bool) where {C}
    v1, c1 = Base.sub_with_overflow(x[C], y[C])
    if c
        v2, c2 = Base.sub_with_overflow(v1, one(UInt))
        c = c1 || c2
        return (_ssub(x[1:C-1], y[1:C-1], c)..., v2)
    else
        return (_ssub(x[1:C-1], y[1:C-1], c1)..., v1)
    end
end

function Base.:(*)(x::LongLongUInt{C}, y::LongLongUInt{C}) where {C}
    result = zero(LongLongUInt{C})
    for i in 1:C
        x.content[C-i+1] == 0 && continue
        for j in 1:C
            y.content[C-j+1] == 0 && continue
            # Skip if either position is out of bounds for the result
            pos = i + j - 1
            pos > C && continue
            
            # Multiply the corresponding elements
            mres = Base.widemul(x.content[C-i+1], y.content[C-j+1])
            
            # Add the low part to the result at position pos
            partial = LongLongUInt(ntuple(k -> (k == C-pos+1 ? UInt(mres & typemax(UInt)) : (k == C-pos ? UInt(mres >> bsizeof(UInt)) : zero(UInt))), Val{C}()))
            result = result + partial
        end
    end
    return result
end

Base.count_ones(x::LongLongUInt) = sum(count_ones, x.content)
Base.bitstring(x::LongLongUInt) = join(bitstring.(x.content), "")

function longinttype(n::Int, D::Int)
    N = ceil(Int, n * log2(D))
    C = (N-1) ÷ bsizeof(UInt) + 1
    return LongLongUInt{C}
end

Base.hash(x::LongLongUInt{1}) = hash(x.content[1])
Base.hash(x::LongLongUInt{C}) where{C} = hash(x.content)

# these APIs will are used in SparseTN
BitBasis.log2i(x::LongLongUInt{C}) where C = floor(Int, log2(Float64(BigInt(x))))
Base.BigInt(x::LongLongUInt{C}) where C = mapfoldl(x -> BigInt(x), (x, y) -> ((x << 64) | y), x.content)

function Base.Int(x::LongLongUInt)
    if all(iszero, x.content[2:end]) && x.content[1] < typemax(Int)
        return Int(x.content[1])
    else
        throw(InexactError(:Int, x))
    end
end

function Base.hash(bits_tuple::Tuple{LongLongUInt{C}, Vararg{LongLongUInt{C}, M}}) where{M, C}
    N = M + 1
    hash0 = Base.hash(bits_tuple[1].content)
    for i in 2:N
        hash0 = Base.hash(bits_tuple[i].content, hash0)
    end
    return hash0
end