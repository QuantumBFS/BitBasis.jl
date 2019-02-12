using BitBasis, Random, BenchmarkTools

function _reorder(b::Int, taker::Vector{Int}, differ::Vector{Int})::Int
    out::Int = 0
    @simd for i = 1:length(differ)
        @inbounds out += (b&taker[i]) << differ[i]
    end
    out
end


v = rand(1024)
orders = tuple(randperm(1000)...);
taker, differ = bmask.(orders), BitBasis.unsafe_sub(1:1000, orders);
vtaker, vdiffer = collect(taker), collect(differ);

@benchmark for i in 1:1000_000 BitBasis.next_reordered_basis(2, $taker, $differ) end
@benchmark for i in 1:1000_000 _reorder(2, $vtaker, $vdiffer) end

v = rand(1<<20)
orders = tuple(randperm(20)...)
@profiler reorder(v, orders)

@benchmark reorder($v, $orders)

function reorder(v::AbstractVector, orders)
    nbits = length(orders)
    nbits == log2i(length(v)) || throw(DimensionMismatch("size of array not match length of order"))
    nv = similar(v)
    taker, differ = bmask.(orders), unsafe_sub(1:nbits, orders)

    for b in basis(nbits)
        @inbounds nv[b+1] = v[next_reordered_basis(b, taker, differ)+1]
    end

    return nv
end


@benchmark

@profiler for i in 1:1000000000
    next_reordered_basis(2, taker, differ)
    # _reorder(2, vtaker, vdiffer)
end
