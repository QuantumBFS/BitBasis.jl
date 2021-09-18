export ReorderedBasis, reorder, invorder

using LinearAlgebra

"""
    ReorderedBasis{N, T}

Lazy reorderd basis.
"""
struct ReorderedBasis{N,T<:Integer}
    orders::NTuple{N,T}
    takers::NTuple{N,T}
    differ::NTuple{N,T}

    function ReorderedBasis{M,T}(
        orders::Tuple{T, Vararg{T, N}},
        takers::Tuple{T, Vararg{T, N}},
        differ::Tuple{T, Vararg{T, N}},
    ) where {M,T,N}
        N+1 == M || error("length mismatch")
        new{M,T}(orders, takers, differ)
    end
end

function ReorderedBasis(
    orders::Tuple{T, Vararg{T, N}},
    takers::Tuple{T, Vararg{T, N}},
    differ::Tuple{T, Vararg{T, N}},
) where {N,T}
    ReorderedBasis{N+1,T}(orders, takers, differ)
end

"""
    ReorderedBasis(orders::NTuple{N, <:Integer})

Returns a lazy set of reordered basis.
"""
ReorderedBasis(orders::Tuple{T, Vararg{T,N}}) where {N,T<:Integer} =
    ReorderedBasis{N+1,T}(orders, bmask.(orders), unsafe_sub(1:N, orders))

Base.length(::ReorderedBasis{N}) where {N} = 1 << N
Base.eltype(::ReorderedBasis{N,T}) where {N,T} = T
Base.getindex(it::ReorderedBasis, k::Int) = next_reordered_basis(k - 1, it.takers, it.differ)

function Base.iterate(it::ReorderedBasis{N}, state = 1) where {N}
    if state - 1 == 1 << N
        return nothing
    else
        return next_reordered_basis(state - 1, it.takers, it.differ), state + 1
    end
end

"""
    next_reordered_basis(basis, takers, differ)

Returns the next reordered basis accroding to current basis.
"""
function next_reordered_basis(basis::T, takers::NTuple{N,T}, differ::NTuple{N,T}) where {N,T}
    out = zero(T)
    # NOTE: do not add simd here, this will cause other loop become less efficient
    #       have some confidence with the compiler :-)
    for i in 1:N
        @inbounds out += (basis & takers[i]) << differ[i]
    end
    return out
end

"""
    unsafe_reorder(X::AbstractArray, orders)

Reorder `X` according to `orders`.

!!! warning

    `unsafe_reorder` won't check whether the length of `orders` and
    the size of first dimension of `X` match, use at your own risk.
"""
function unsafe_reorder end

function unsafe_reorder(v::AbstractVector, orders::NTuple{N,<:Integer}) where {N}
    nv = similar(v)
    for (k, b) in enumerate(ReorderedBasis(orders))
        @inbounds nv[k] = v[b+1]
    end
    return nv
end

function unsafe_reorder(A::AbstractMatrix, orders::NTuple{N,<:Integer}) where {N}
    od = Vector{Int}(undef, 1 << length(orders))
    for (i, b) in enumerate(ReorderedBasis(orders))
        @inbounds od[i] = 1 + b
    end

    od = invperm(od)
    return A[od, od]
end

function unsafe_reorder(A::Diagonal, orders::NTuple{N,<:Integer}) where {N}
    diag = similar(A.diag)
    for (i, b) in enumerate(ReorderedBasis(orders))
        @inbounds diag[b+1] = A.diag[i]
    end
    return Diagonal(diag)
end

function _reorder(v::AbstractArray, orders::NTuple{N,<:Integer}) where {N}
    length(orders) == log2dim1(v) ||
        throw(DimensionMismatch("size of array not match length of order"))
    return unsafe_reorder(v, orders)
end

"""
    reorder(X::AbstractArray, orders)

Reorder `X` according to `orders`.

!!! tip
    Although `orders` can be any iterable, `Tuple` is preferred inorder to
    gain as much performance as possible. But the conversion won't take much
    anyway.
"""
function reorder end

reorder(v::AbstractArray, itr) = _reorder(v, Tuple(itr))
reorder(v::AbstractArray, orders::Tuple) = _reorder(v, promote(orders...))
reorder(v::AbstractArray, orders::NTuple{N,<:Integer}) where {N} = _reorder(v, orders)

"""
    invorder(X::AbstractVecOrMat)

Inverse the order of given vector/matrix `X`.
"""
invorder(X::AbstractVecOrMat) = reorder(X, Tuple(log2dim1(X):-1:1))
