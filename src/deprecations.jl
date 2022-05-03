@deprecate testany(index::T, mask::T) where {T<:Integer} anyone(index, mask)
@deprecate testall(index::T, mask::T) where {T<:Integer} allone(index, mask)
@deprecate testval(index::T, mask::T, onemask::T) where {T<:Integer} ismatch(index, mask, onemask)
@deprecate takebit(index::T, ibit::Int) where {T<:Integer} readbit(index, ibit)
@deprecate takebit(index::T, bits::Int...) where {T<:Integer} readbit(index, bits...)
@deprecate breflect(nbits::Int, b::Integer) breflect(b; nbits = nbits)
@deprecate breflect(nbits::Int, b::T, masks::Vector{T}) where {T} breflect(b, masks; nbits = nbits)
@deprecate bit(b; len) BitStr{len}(b)

@deprecate to_location(x::Integer) x + 1
@deprecate to_location(x::BitStr) buffer(x) + 1
@deprecate bcat join
