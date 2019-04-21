using Test, BitBasis

@test bsizeof(ind) == sizeof(Int) * 8
@test onehot(ComplexF64, 2, 2) == [0, 0, 1, 0]
@test bdistance(1,7) == 2
@test log2dim1(rand(4, 4)) == log2i(4)

@testset "log2i" begin
    for itype in [
            Int8, Int16, Int32, Int64, Int128,
            UInt8, UInt16, UInt32, UInt64, UInt128,
        ]
        @test log2i(itype(2^5)) == 5
        @test typeof(log2i(itype(2^5))) == Int
    end
end

@testset "bit length" begin
    @test bit_length(8) == 4
    @test bit_length(Int32(8)) == 4
end

@testset "indices with" begin
    # indices_with
    nbit = 5
    poss, vals = [4,2,3], [1,0,1]
    @test indices_with(nbit, poss, vals) == filter(x-> readbit.(x, poss) == vals, basis(nbit))
end
