const UIntStorage = Union{UInt8, UInt16, UInt32, UInt64, UInt128, LongLongUInt}
const IntStorage = Union{Int8, Int16, Int32,Int64,Int128,BigInt,UIntStorage}

########## DitStr #########
"""
    DitStr{D,N,T<:Integer} <: Integer

The struct for dit string with fixed length `N` and storage type `T`,
where `dit` is a extension of `dit` from binary system to a d-ary system.

    DitStr{D,N,T}(integer)
    DitStr{D,N}(integer)
    DitStr{D}(vector)

Returns a `DitStr`.
When the input is an integer, the dits are read from right to left.
When the input is a vector, the dits are read from left to right.

### Examples

```jldoctest
julia> DitStr{3}([1,2,1,1,0])
01121 ₍₃₎

julia> DitStr{3, 5}(71)
02122 ₍₃₎
```
"""
struct DitStr{D,N,T<:Integer} <: Integer
    buf::T
    DitStr{D,N,T}(buf::IntStorage) where {D,N,T} = new{D,N,T}(buf)
    DitStr{D,N}(buf::IntStorage) where {D,N} = new{D,N,typeof(buf)}(buf)
end

# vector inputs
function DitStr{D,T}(vector::Union{AbstractVector,Tuple}) where {D,T}
    val = zero(T)
    D_power_k = one(T)
    for k in 1:length(vector)
        0 <= vector[k] <= D - 1 || error("expect 0-$(D-1), got $(vector[k])")
        val = accum(Val{D}(), val, vector[k], D_power_k)
        D_power_k = _lshift(Val{D}(), D_power_k, 1)
    end
    return DitStr{D,length(vector),T}(val)
end
# val += x * y
accum(::Val{D}, val, x, y) where {D} = val + x * y
accum(::Val{2}, val, x, y) = iszero(x) ? val : val ⊻ y
DitStr{D}(vector::Tuple{T,Vararg{T,N}}) where {N,T,D} = DitStr{D,T}(vector)
DitStr{D}(vector::AbstractVector{T}) where {D,T} = DitStr{D,T}(vector)
DitStr{D,N,T}(val::DitStr) where {D,N,T<:Integer} = convert(DitStr{D,N,T}, val)
DitStr{D,N,T}(val::DitStr{D,N,T}) where {D,N,T<:Integer} = val

const DitStr64{D,N} = DitStr{D,N,Int64}
const LongDitStr{D,N} = DitStr{D,N,LongLongUInt{C}} where {C}
LongDitStr{D}(vector::AbstractVector{T}) where {D,T} = DitStr{D,longinttype(length(vector), D)}(vector)

Base.show(io::IO, ditstr::DitStr{D,N,<:Integer}) where {D,N} =
    print(io, string(buffer(ditstr), base=D, pad=N), " ₍$('₀'+D)₎")
Base.show(io::IO, ditstr::DitStr{D,N,<:LongLongUInt}) where {D,N} =
    print(io, join(map(string, [ditstr[end:-1:1]...])), " ₍$('₀'+D)₎")

Base.zero(::Type{DitStr{D,N,T}}) where {D,N,T} = DitStr{D,N,T}(zero(T))
Base.zero(::DitStr{D,N,T}) where {D,N,T} = DitStr{D,N,T}(zero(T))

buffer(b::DitStr) = b.buf
Base.hash(d::DitStr) = hash(buffer(d))
Base.reinterpret(::Type{DitStr{D,N,T}}, x::Integer) where {D,N,T} = DitStr{D,N,T}(reinterpret(T, x))
Base.reinterpret(::Type{T}, x::DitStr) where {T} = reinterpret(T, buffer(x))
Base.reinterpret(::Type{DitStr{D,N,T}}, x::DitStr) where {D,N,T} = DitStr{D,N,T}(x)

Base.convert(::Type{T}, b::DitStr) where {T<:Integer} = convert(T, buffer(b))
Base.convert(::Type{T}, b::Integer) where {T<:DitStr} = T(b)
Base.convert(::Type{DitStr{D,N,T}}, b::DitStr{D,N,T}) where {D,N,T<:Integer} = b
Base.convert(::Type{T1}, b::DitStr{D,N2,T2}) where {D,T1<:DitStr,N2,T2<:Integer} = convert(T1, buffer(b))
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
    @eval Base.$IT(b::DitStr) = $IT(buffer(b))
end
for op in [:+, :-, :*, :÷, :|, :⊻, :&, :%, :mod, :mod1]
    @eval Base.$op(a::T, b::Integer) where {T<:DitStr} = T($op(buffer(a), b))
    @eval Base.$op(a::Integer, b::T) where {T<:DitStr} = T($op(a, buffer(b)))
    @eval Base.$op(a::DitStr{D,N,T}, b::DitStr{D,N,T}) where {D,N,T<:Integer} =
        DitStr{D,N,T}($op(buffer(a), buffer(b)))
    @eval Base.$op(a::DitStr, b::DitStr) = error("type mismatch: $(typeof(a)), $(typeof(b))")
end
Base.:-(x::DitStr{D,N,T}) where {D,N,T} = DitStr{D,N,T}(-buffer(x))

for op in [:<, :>, :(<=), :(>=)]
    @eval Base.$op(a::T, b::T) where {T<:DitStr} = Base.$op(buffer(a), buffer(b))
end

for Type in [Integer, BigInt, BigFloat]
    @eval Base.:(==)(a::T, b::$Type) where {T<:DitStr} = Base.:(==)(buffer(a), b)
    @eval Base.:(==)(a::$Type, b::T) where {T<:DitStr} = Base.:(==)(a, buffer(b))
end

Base.:(==)(a::DitStr{D,N}, b::DitStr{D,N}) where {D,N} = Base.:(==)(buffer(a), buffer(b))

# Note: the transitivity of == is not satisfied here.
Base.:(==)(lhs::DitStr, rhs::DitStr) = false
Base.isapprox(a::DitStr, b::Integer; kwargs...) = Base.isapprox(buffer(a), b; kwargs...)
Base.isapprox(a::Integer, b::DitStr; kwargs...) = Base.isapprox(a, buffer(b); kwargs...)
Base.isapprox(lhs::DitStr, rhs::DitStr; kwargs...) = false
Base.isapprox(a::T, b::T; kwargs...) where {T<:DitStr} =
    Base.isapprox(buffer(a), buffer(b); kwargs...)

# Note: it is a dit confusing, with x::DitStr == y::Integer,
# they behave different when used for indexing.
Base.to_index(x::DitStr) = error(
    "please do not use dit string for indexing, you may want to use `buffer(x)+1` for indexing to avoid ambiguity.",
)
Base.to_index(x::UnitRange{<:DitStr}) = error(
    "please do not use dit string for indexing, you may want to use `buffer(x)+1` for indexing to avoid ambiguity.",
)

# NOTE: maybe this is wrong?
Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, i::DitStr) =
    checkindex(Bool, inds, Base.to_index(i))
Base.checkindex(::Type{Bool}, inds::Base.IdentityUnitRange, i::DitStr) =
    checkindex(Bool, inds, Base.to_index(i))
Base.length(::DitStr{D,N,T}) where {D,N,T} = N
Base.lastindex(dits::DitStr) = length(dits)

Base.typemax(::Type{DitStr{D,N,T}}) where {D,N,T} = DitStr{D,N,T}(_lshift(Val{D}(), one(T), N) - 1)
Base.typemax(::DitStr{D,N,T}) where {D,N,T} = DitStr{D,N,T}(_lshift(Val{D}(), one(T), N) - 1)
Base.typemin(::Type{DitStr{D,N,T}}) where {D,N,T} = DitStr{D,N,T}(0)
Base.typemin(::DitStr{D,N,T}) where {D,N,T} = DitStr{D,N,T}(0)

"""
    readat(x, loc...) -> Integer

Read the dit config at given location.
"""
@inline @generated function readat(x::DitStr{D,N,T}, locs::Integer...) where {D,N,T}
    length(locs) == 0 && return :(zero($T))
    Expr(:call, :+, [:($_lshift($(Val(D)), mod($_rshift($(Val{D}()), buffer(x), locs[$i] - 1), $D), $(i - 1))) for i = 1:length(locs)]...)
end

Base.@propagate_inbounds function Base.getindex(dit::DitStr{D,N}, index::Integer) where {D,N}
    @boundscheck 1 <= index <= N || throw(BoundsError(dit, index))
    return readat(dit, index)
end

Base.@propagate_inbounds function Base.getindex(dit::DitStr{D,N,T}, itr::AbstractVector) where {D,N,T}
    @boundscheck all(x -> 1 <= x <= N, itr) || throw(BoundsError(dit, itr))
    return map(x -> readat(dit, x), itr)
end


"""
    SubDitStr{D,N,T<:Integer} <: Integer

The struct as a `SubString`-like object for `DitStr`(`SubString` is an official implementation of sliced strings, see [String](https://docs.julialang.org/en/v1/base/strings/#Base.SubString) for reference). This slicing returns a view into the parent `DitStr` instead of making a copy (similar to the `@views` macro for strings).

`SubDitStr` can be used to describe the qubit configuration within the subspace of the entire Hilbert space.It provides similar `getindex`, `length` functions as `DitStr`. 

    SubDitStr(dit::DitStr{D,N,T}, i::Int, j::Int)
    SubDitStr(dit::DitStr{D,N,T}, r::AbstractUnitRange{<:Integer})

Or by `@views` macro for `DitStr` (this macro makes your life easier by supporting `begin` and `end` syntax):

    @views dit[i:j]

Returns a `SubDitStr`.

### Examples

```jldoctest
julia> x = DitStr{3, 5}(71)
02122 ₍₃₎

julia> sx =  SubDitStr(x, 2, 4) 
SubDitStr{3, 5, Int64}(02122 ₍₃₎, 1, 3)

julia> @views x[2:end] 
SubDitStr{3, 5, Int64}(02122 ₍₃₎, 1, 4)

julia> sx == dit"212;3"
true
```
"""
struct SubDitStr{D,N,T<:Integer} <: Integer
    dit::DitStr{D,N,T}
    offset::Int
    ncodeunits::Int

    function SubDitStr(dit::DitStr{D,N,T}, i::Int, j::Int) where {D,N,T}
        i ≤ j || return new{D,N,T}(dit, 0, 0)
        @boundscheck begin
            1 ≤ i ≤ length(dit) || throw(BoundsError(dit, i))
            1 ≤ j ≤ length(dit) || throw(BoundsError(dit, i))
        end
        return new{D,N,T}(dit, i - 1, j - i + 1)
    end
end

Base.@propagate_inbounds Base.view(dit::DitStr{D,N,T}, i::Integer, j::Integer) where {D,N,T} = SubDitStr(dit, i, j)
Base.@propagate_inbounds Base.view(dit::DitStr{D,N,T}, r::AbstractUnitRange{<:Integer}) where {D,N,T} = SubDitStr(dit, first(r), last(r))
Base.@propagate_inbounds Base.maybeview(dit::DitStr{D,N,T}, r::AbstractUnitRange{<:Integer}) where {D,N,T} = view(dit,r) 

"""
    DitStr(dit::SubDitStr{D,N,T}) -> DitStr{D,N,T}
Raise type `SubDitStr` to `DitStr`.
```jldoctest
julia> x = DitStr{3, 5}(71)
02122 ₍₃₎

julia> sx =  SubDitStr(x, 2, 4)
SubDitStr{3, 5, Int64}(02122 ₍₃₎, 1, 3)

julia> DitStr(sx)
212 ₍₃₎
```
"""
function DitStr(dit::SubDitStr{D,N,T}) where {D,N,T}
    val = zero(T)
    D_power_k = one(T)
    len = ncodeunits(dit)
    for k in 1:len
        val = accum(Val{D}(), val, readat(dit.dit, dit.offset + k), D_power_k)
        D_power_k = _lshift(Val{D}(), D_power_k, 1)
    end
    return DitStr{D,len,T}(val)
end

ncodeunits(dit::SubDitStr{D,N,T}) where {D,N,T} = dit.ncodeunits

## bounds checking ##
Base.checkbounds(::Type{Bool}, dit::SubDitStr{D,N,T}, i::Integer) where {D,N,T} =
    1 ≤ i ≤ ncodeunits(dit)
Base.checkbounds(::Type{Bool}, dit::SubDitStr{D,N,T}, r::AbstractRange{<:Integer}) where {D,N,T} =
    isempty(r) || (1 ≤ minimum(r) && maximum(r) ≤ ncodeunits(dit))
Base.checkbounds(::Type{Bool}, dit::SubDitStr{D,N,T}, I::AbstractArray{<:Integer}) where {D,N,T} =
    all(i -> checkbounds(Bool, dit, i), I)
Base.checkbounds(dit::SubDitStr{D,N,T}, I::Union{Integer,AbstractArray}) where {D,N,T} = checkbounds(Bool, dit, I) ? nothing : throw(BoundsError(dit, I))

Base.@propagate_inbounds SubDitStr(dit::DitStr{D,N,T}, i::Integer, j::Integer) where {D,N,T} = SubDitStr{D,N,T}(dit, i, j)
Base.@propagate_inbounds SubDitStr(dit::DitStr{D,N,T}, r::AbstractUnitRange{<:Integer}) where {D,N,T} = SubDitStr{D,N,T}(dit, first(r), last(r))

Base.@propagate_inbounds function SubDitStr(dit::SubDitStr{D,N,T}, i::Int, j::Int) where {D,N,T}
    @boundscheck i ≤ j && checkbounds(dit, i:j)
    SubString(dit.dit, dit.offset + i, dit.offset + j)
end

Base.length(dit::SubDitStr{D,N,T}) where {D,N,T} = ncodeunits(dit)

"""
    ==(lhs::SubDitStr{D,N,T}, rhs::DitStr{D,N,T}) -> Bool
    ==(lhs::DitStr{D,N,T}, rhs::SubDitStr{D,N,T}) -> Bool
    ==(lhs::SubDitStr{D,N,T}, rhs::SubDitStr{D,N,T}) -> Bool
Compare the equality between `SubDitStr` and `DitStr`. 
"""
function Base.:(==)(lhs::SubDitStr{D,N1}, rhs::DitStr{D,N2}) where {D,N1,N2}
    length(lhs) == length(rhs) && @inbounds all(i -> lhs[i] == rhs[i], 1:length(lhs))
end

function Base.:(==)(lhs::SubDitStr{D,N1}, rhs::SubDitStr{D,N2}) where {D,N1,N2}
    length(lhs) == length(rhs) && @inbounds all(i -> lhs[i] == rhs[i], 1:length(lhs))
end

function Base.:(==)(lhs::DitStr{D,N1}, rhs::SubDitStr{D,N2}) where {D,N1,N2}
    length(lhs) == length(rhs) && @inbounds all(i -> lhs[i] == rhs[i], 1:length(lhs))
end

function Base.getindex(dit::SubDitStr{D,N,T}, i::Integer) where {D,N,T}
    @boundscheck checkbounds(dit, i)
    @inbounds return getindex(dit.dit, dit.offset + i)
end


# TODO: support AbstractArray, should return its corresponding shape

Base.@propagate_inbounds function Base.getindex(
    dit::DitStr{D,N,T},
    mask::AbstractVector{Bool},
) where {D,N,T}
    @boundscheck N == length(mask) || error("length of dits and mask does not match.")

    out = T[]
    for k in eachindex(mask)
        if mask[k]
            push!(out, dit[k])
        end
    end
    return out
end

Base.eltype(::DitStr{D,N,T}) where {D,N,T} = T

function Base.iterate(dit::DitStr, state::Integer=1)
    if state > length(dit)
        return nothing
    else
        return dit[state], state + 1
    end
end
Base.IteratorSize(::DitStr) = Base.HasLength()

"""
    basis(ditstr) -> UnitRange{DitStr{D,N,T}}
    basis(DitStr{D,N,T}) -> UnitRange{DitStr{D,N,T}}

Returns the `UnitRange` for basis in Hilbert Space of qudits.
"""
basis(b::DitStr) = typemin(b):typemax(b)
basis(::Type{DitStr{D,N,T}}) where {D,N,T} = UnitRange(typemin(DitStr{D,N,T}), typemax(DitStr{D,N,T}))

function Base.rand(::Type{T}) where {D,N,Ti,T<:DitStr{D,N,Ti}}
    return T(rand(typemin(T).buf:typemax(T).buf))
end

######################### Operations #####################
_lshift(::Val{D}, x::Integer, i::Integer) where {D} = x * (D^i)
_rshift(::Val{D}, x::Integer, i::Integer) where {D} = x ÷ (D^i)
_lshift(::Val{2}, x::Integer, i::Integer) = x << i
_rshift(::Val{2}, x::Integer, i::Integer) = x >> i

# expand iterator to tuple
sum_length(a::DitStr, dits::DitStr...) = length(a) + sum_length(dits...)
sum_length(a::DitStr) = length(a)

function Base.join(dit::DitStr{D,N,T}, dits::DitStr{D}...) where {D,N,T<:Integer}
    total_dits = sum_length(dit, dits...)
    val, len = zero(T), 0

    for k in length(dits):-1:1
        val += _lshift(Val(D), buffer(dits[k]), len)
        len += length(dits[k])
    end
    val += _lshift(Val(D), buffer(dit), len)
    len += length(dit)
    return DitStr{D,total_dits,T}(val)
end
Base.repeat(s::DitStr, n::Integer) = join([s for i in 1:n]...)

"""
    onehot([T=Float64], dit_str[; nbatch])

Create an onehot vector in type `Vector{T}` or a batch of onehot vector in type `Matrix{T}`, where index `x + 1` is one.
One can specify the value of the nonzero entry by inputing a pair.
"""
onehot(::Type{T}, n::DitStr{D,N,T1}; nbatch=nothing) where {D,T,N,T1} = _onehot(T, D^N, buffer(n) + 1; nbatch)
onehot(n::DitStr; nbatch=nothing) = onehot(ComplexF64, n; nbatch)

readbit(x::DitStr{D,N,LongLongUInt{C}}, loc::Int) where {D,N,C} = readbit(x.buf, loc)

########## @dit_str macro ##############
"""
    @dit_str -> DitStr64

Construct a dit string. such as `dit"0201;3"`. The dit strings also supports string `join`. Just use
it like normal strings.

## Example

```jldoctest
julia> dit"10201;3"
10201 ₍₃₎

julia> dit"100_121_121;3"
100121121 ₍₃₎

julia> join(dit"1021;3", dit"11;3", dit"1210;3")
1021111210 ₍₃₎

julia> onehot(dit"1021;3")
81-element Vector{ComplexF64}:
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
     ⋮
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im
 0.0 + 0.0im

```
"""
macro dit_str(str)
    return parse_dit(Int64, str)
end

"""
    @ldit_str -> LongDitStr

Long dit string version of `@dit_str` macro.
"""
macro ldit_str(str)
    return parse_dit(BigInt, str)
end

function parse_dit(::Type{T}, str::String) where {T<:Integer}
    res = match(r"(.*);(\d+)", str)
    if res === nothing
        error("Input string literal format error, should be e.g. `dit\"01121;3\"`")
    end
    return _parse_dit(Val(parse(Int, res[2])), T, res[1])
end

function _parse_dit(::Val{D}, ::Type{T}, str::AbstractString) where {D,T<:Integer}
    TT = T <: LongLongUInt ? longinttype(count(isdigit, str), D) : T
    _parse_dit_safe(Val(D), TT, str)
end

function _parse_dit_safe(::Val{D}, ::Type{T}, str::AbstractString) where {D,T<:Integer}
    val = zero(T)
    k = 0
    maxk = max_num_elements(T, D)
    for each in reverse(str)
        k >= maxk - 1 && error("string length is larger than $(maxk), use @ldit_str instead")
        v = each - '0'
        if 0 <= v < D
            val += _lshift(Val(D), T(v), k)
            k += 1
        elseif each == '_'
            continue
        else
            error("expect char in range 0-$(D-1), got $each at $(k+1)-th dit")
        end
    end
    return DitStr{D,k,T}(val)
end

max_num_elements(::Type{T}, D::Int) where {T<:Integer} = floor(Int, log(typemax(T)) / log(D))
max_num_elements(::Type{BigInt}, D::Int) = typemax(Int)
max_num_elements(::Type{LongLongUInt{C}}, D::Int) where {C} = max_num_elements(UInt, D) * C