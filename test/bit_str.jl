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
    @test bcat(bit"101", bit"100", bit"111") == bit"101100111"
    @test bcat(bit"101" for k in 1:3) == bit"101101101"
end

@testset "conversions" begin
    for T in [Int8, Int16, Int32, Int64, Int128, BigInt]
        @test T(bit"11") == 0b11
    end
end
