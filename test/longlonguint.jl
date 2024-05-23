using Test, BitBasis

@testset "longlonguint" begin
    x = LongLongUInt((3,))
    @test Int(x) === 3
    @test bsizeof(x) == 64
    @test BitBasis.nint(x) == 1

    x = LongLongUInt((3, 6))
    @test zero(x) == LongLongUInt((0, 0))
    @test x << 1 == LongLongUInt((6, 12))
    @test x >> 1 == LongLongUInt((UInt(1), UInt(3) + UInt(1)<<63))
    @test count_ones(x) == 4
    @test ~x == LongLongUInt((~UInt(3), ~UInt(6)))

    y = LongLongUInt((5, 7))
    @test x & y == LongLongUInt((1, 6))
    @test x | y == LongLongUInt((7, 7))
    @test x ⊻ y == LongLongUInt((6, 1))
    @test x + y == LongLongUInt((8, 13))

    # add with overflow
    z = LongLongUInt((UInt(17), typemax(UInt)-1))
    @test z + x == LongLongUInt((21, 4))
    @test (@allocated z + x) == 0

    # maximum number of elements
    BitBasis.max_num_elements(LongLongUInt{2}, 2) == 80
    BitBasis.max_num_elements(LongLongUInt{2}, 4) == 40
    BitBasis.max_num_elements(UInt, 2) == 64
    BitBasis.max_num_elements(Int, 2) == 63
end