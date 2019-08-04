using Test, BitBasis

@testset "bit literal" begin
    @test bit"1011" == 0b1011
    @test bit"100_111" == 0b100_111
    @test bit"10_100_11" == bit"1010011"
    @test bit"10_100_11" != bit"01010011"
    @test bit"1011" === bit_literal(1,1,0,1)
end

@testset "operations" begin
    @test (bit"1010" + bit"0101") == bit"1111" == 15
    @test (bit"1111" - bit"0101") == bit"1010" == 10
    @test (bit"01010" * 2) == (2 * bit"01010") == bit"10100" == 20
    @test (bit"1010" ÷ 2) == bit"0101" == 5
    @test bcat(bit"101", bit"100", bit"111") == bit"101100111"
    @test bcat(bit"101" for k in 1:3) == bit"101101101"
    @test (bit"00101" << 2) == bit"10100"
    @test (bit"1101" >> 2) == bit"0011"
    @test bit"10011" == bit"10011"

    @test collect(bit"1101101") == Int64[1, 0, 1, 1, 0, 1, 1]
    @test length(bit"000":bit"111") == 8
    v = zeros(8); v[bit"101"] = 1
    @test onehot(bit"101") == v

    @test repeat(bit"101", 3) == bit"101101101"
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
    @test bit"110101"[mask] == [1, 1, 1]
end

@testset "bitstr arithmetic" begin
    x = BitStr{8}(99)
    y = BitStr{8}(UInt64(7))
    @test length(x) == 8
    for op in [+, -, *, ÷, |, ⊻, &, %, mod, mod1]
        z = op(x, y)
        @test z isa BitStr
        @test z == op(Int64(x),Int64(y))
        z = op(x, 7)
        @test z isa BitStr
        @test z == op(Int64(x),7)
        z = op(7, y)
        @test z isa BitStr
        @test z == op(7, Int64(y))
    end

    for op in [==, ≈]
        z = op(x, y)
        zz = op(Int64(x),Int64(y))
        @test typeof(z) == typeof(zz)
        @test z == zz
        z = op(x, 7)
        zz = op(Int64(x),7)
        @test typeof(z) == typeof(zz)
        @test z == zz
        z = op(7, y)
        zz = op(7, Int64(y))
        @test typeof(z) == typeof(zz)
        @test z == zz
    end

    for op in [>, <, >=, <=]
        @test op(x, y) == op(Int64(x), Int64(y))
    end

    for op in [leading_ones, leading_zeros, count_ones, count_zeros]
        op(x) == op(Int64(x))
    end
end

@testset "bitstr constructors" begin
    x = BitStr{8}(99)
    y = BitStr{8}(UInt64(7))
    @test x == 99
    @test y == 7
    @test y != BitStr{4}(7)
    @test bit"1001" == BitStr{4}(9)
    @test typemax(x) == bit"11111111"
    @test typemax(typeof(x)) == bit"11111111"
    @test typemin(x) == bit"00000000"
    @test typemin(typeof(x)) == bit"00000000"
end

@testset "bitstr binaryop" begin
    x = bit"001110"
    @test baddrs(x) == [2,3,4]
    @test breflect(x) === bit"011100"
    msk = bmask(BitStr{6}, 1,2,3)
    @test flip(x, msk) === bit"001001"
    @test setbit(x, msk) === bit"001111"
    @test readbit(x, 3) === bit"000001"
    @test readbit(x, 3,4) === bit"000011"
    @test anyone(x, msk) === true
    @test allone(x, msk) === false
    @test ismatch(x, msk, bit"000110") === true
    @test ismatch(x, msk, bit"100110") === false
    @test length(basis(x)) == 2^6
    @test length(basis(typeof(x))) == 2^6
    @test basis(x)[1] === bit"000000"

    @test neg(x) === bit"110001"
    @test swapbits(x, bit"101000") === bit"100110"
end

@testset "bitstr indexing" begin
    x = bit"001110"
    @test x[1] === 0
    @test x[2] === 1
    @test_throws BoundsError x[10]
    @test x[[true, false, true, true, true, false]] == [0,1,1,0]
    @test x[1:2] == [0,1]
    @test x[[1,4]] == [0,1]
end

@testset "bitstr readout" begin
    x = bit"001110"
    @test bint(x) === 14
    @test bint_r(x) === 28
    @test bfloat(x) === 28/2^6
    @test bfloat_r(x) === 14/2^6
    @test btruncate(x, 3) === bit"000110"
end