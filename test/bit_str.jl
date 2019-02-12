using Test, BitBasis

@testset "bit literal" begin
    @test bit"1011" == 0b1011
    @test bit"100_111" == 0b100_111
    # @test bit"10^3" == bit"101010"
end

@testset "operations" begin
    @test (bit"1010" + bit"0101") == bit"1111" == 15
    @test (bit"1111" - bit"0101") == bit"1010" == 10
    @test (bit"1010" * 2) == bit"10100" == 20
    @test (bit"1010" ÷ 2) == bit"0101" == 5
    @test bcat(bit"101", bit"100", bit"111") == bit"101100111"
    @test bcat(bit"101" for k in 1:3) == bit"101101101"
    @test (bit"101" << 2) == bit"10100"
    @test (bit"1101" >> 2) == bit"11"

    @test collect(bit"1101101") == Int[1, 0, 1, 1, 0, 1, 1]
    v = zeros(8); v[bit"101"] = 1
    @test onehot(bit"101") == v
end

@testset "conversions" begin
    for T in [Int8, Int16, Int32, Int64, Int128, BigInt]
        @test T(bit"11") == 0b11
    end
end

@testset "indexing" begin
    A = rand(16)
    @test A[bit"1101"] == A[14]
    @test bit"1101"[1] == 1
    @test bit"1101"[2] == 0
    @test bit"1101"[3] == 1
    @test bit"1101"[4] == 1

    mask = Bool[1, 0, 0, 0, 1, 1]
    bit"110101"[mask] == [1, 1, 1]
end
