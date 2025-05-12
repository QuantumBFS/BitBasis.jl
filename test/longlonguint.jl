using Test, BitBasis

@testset "longlonguint" begin
    x = LongLongUInt((3,))
    @test LongLongUInt{1}(x) == x
    @test Int(x) === 3
    @test bsizeof(x) == 64
    @test BitBasis.nint(x) == 1
    @test bitstring(x) == "0000000000000000000000000000000000000000000000000000000000000011"

    x = LongLongUInt((3, 6))
    @test bitstring(x) == "00000000000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000110"
    @test zero(x) == LongLongUInt((0, 0))
    @test x << 1 == LongLongUInt((6, 12))
    @test x >> 1 == LongLongUInt((UInt(1), UInt(3) + UInt(1)<<63))
    @test count_ones(x) == 4
    @test ~x == LongLongUInt((~UInt(3), ~UInt(6)))
    @test promote(UInt(1), LongLongUInt((3, 4))) == (LongLongUInt((0, 1)), LongLongUInt((3, 4)))

    y = LongLongUInt((5, 7))
    @test one(y) == LongLongUInt((0, 1))
    @test x & y == LongLongUInt((1, 6))
    @test x | y == LongLongUInt((7, 7))
    @test x ⊻ y == LongLongUInt((6, 1))
    @test x + y == LongLongUInt((8, 13))
    z = LongLongUInt((5, 4))
    @test z - x == LongLongUInt((UInt64(1), typemax(UInt64)-1))

    # add with overflow
    z = LongLongUInt((UInt(17), typemax(UInt)-1))
    @test z + x == LongLongUInt((21, 4))
    @test (@allocated z + x) == 0

    # maximum number of elements
    BitBasis.max_num_elements(LongLongUInt{2}, 2) == 80
    BitBasis.max_num_elements(LongLongUInt{2}, 4) == 40
    BitBasis.max_num_elements(UInt, 2) == 64
    BitBasis.max_num_elements(Int, 2) == 63

    @test count_ones(bmask(LongLongUInt{50}, 1:3000)) == 3000

    # Hard add
    a = LongLongUInt((ntuple(i -> UInt64(0), Val{1}())..., ntuple(i -> rand(UInt64), Val{9}())...))
    b = LongLongUInt((ntuple(i -> UInt64(0), Val{1}())..., ntuple(i -> rand(UInt64), Val{9}())...))
    @test BigInt(a + b) == BigInt(a) + BigInt(b)
end

@testset "shift" begin
    x = LongLongUInt((3, ))
    @test x << 0 == LongLongUInt((3, ))
    @test x << 1 == LongLongUInt((3 << 1, ))
    @test x >> 1 == LongLongUInt((3 >> 1, ))

    x = LongLongUInt((3, 6))
    @test x << 0 == LongLongUInt((3, 6))
    @test x << 64 == LongLongUInt((6, 0))
    @test x << 65 == LongLongUInt((6<<1, 0))
    @test x >> 64 == LongLongUInt((0, 3))
    @test x >> 65 == LongLongUInt((0, 1))
    @test x << -65 == LongLongUInt((0, 1))
    @test x >> -65 == LongLongUInt((6<<1, 0))

    x = LongLongUInt((3, 6, 7))
    @test x >> 66 == LongLongUInt((UInt(0), UInt(0), UInt(3) << 62 + UInt(1)))
    @test x << 63 == LongLongUInt((UInt(1) << 63 + UInt(6) >> 1, UInt(7) >> 1, UInt(1)<<63))
end

@testset "longinttype" begin
    @test BitBasis.longinttype(1, 2) == LongLongUInt{1}
    @test BitBasis.longinttype(64, 2) == LongLongUInt{1}
    @test BitBasis.longinttype(65, 2) == LongLongUInt{2}
end

@testset "hash" begin
    @test hash(LongLongUInt((3, 6))) == hash(LongLongUInt((3, 6)))
    @test hash(LongLongUInt((3, 6))) != hash(LongLongUInt((6, 3)))
end

@testset "indicator" begin
    @test indicator(LongLongUInt{1}, 1) == LongLongUInt((1,))
    @test indicator(LongLongUInt{1}, 64) == LongLongUInt((UInt(1)<<63,))
    @test indicator(LongLongUInt{2}, 64) == LongLongUInt((zero(UInt), UInt(1)<<63))
    @test indicator(LongLongUInt{2}, 65) == LongLongUInt((1, 0))
end

@testset "takebit" begin
    x = LongLongUInt((3,))
    @test readbit(x, 1) == 1
    @test readbit(x, 2) == 1
    @test readbit(x, 3) == 0
    @test readbit(x, 4) == 0

    x = LongLongUInt((3, 6))
    @test readbit(x, 1) == 0
    @test readbit(x, 2) == 1
    @test readbit(x, 3) == 1
    @test readbit(x, 4) == 0

    @test readbit(x, 64) == 0
    @test readbit(x, 65) == 1
    @test readbit(x, 66) == 1
    @test readbit(x, 67) == 0
    @test readbit(BitStr{78}(x), 66) == 1
end

@testset "bmask" begin
    @test bmask(LongLongUInt{1}, 1:1) == LongLongUInt((UInt64(1),))
    @test bmask(LongLongUInt{2}, 1:65) == LongLongUInt((UInt64(1), typemax(UInt64)))
end

@testset "isless" begin
    x = LongLongUInt((3,))
    y = LongLongUInt((5,))
    @test x < y
    @test y > x

    x = LongLongUInt((3, 6))
    y = LongLongUInt((3, 7))
    @test x < y
    @test y > x

    x = LongLongUInt((3, 6))
    y = LongLongUInt((3, 6))
    @test !(x < y)
    @test !(y < x)
    @test x ≥ y
    @test y ≥ x

    xs = [LongLongUInt((3, 6)), LongLongUInt((3, 7)), LongLongUInt((2, 4))]
    sorted_xs = sort(xs)
    @test sorted_xs == [LongLongUInt((2, 4)), LongLongUInt((3, 6)), LongLongUInt((3, 7))]
end

@testset "patch" begin
    @test BigInt(LongLongUInt((3,))) == 3
    @test BigInt(LongLongUInt((3, 0))) == BigInt(3) << 64
    @test BigInt(LongLongUInt((0, 3))) == 3
    @test BigInt(LongLongUInt((1,2))) == (BigInt(1) << 64) + BigInt(2)
    @test log2i(LongLongUInt((3,))) == 1
    @test log2i(LongLongUInt((1,2))) == 64
    @test log2i(LongLongUInt((0,2))) == 1
    @test log2i(LongLongUInt((1,0))) == 64
end

@testset "multiplication" begin
    # Test basic multiplication
    x = LongLongUInt((2,))
    y = LongLongUInt((3,))
    @test x * y == LongLongUInt((6,))
    
    # Test multiplication with overflow within a single UInt
    x = LongLongUInt((0x8000000000000000,))
    y = LongLongUInt((2,))
    @test x * y == LongLongUInt((0,))  # Overflow truncated to original size
    
    # Test multiplication across multiple UInts
    x = LongLongUInt((1, 0))  # 1 << 64
    y = LongLongUInt((0, 5))  # 2 << 64
    @test x * y == LongLongUInt((5, 0))  # Result truncated to original size
    
    # Test with values in both positions
    x = LongLongUInt((0, 2))
    y = LongLongUInt((3, 4))
    # Expected: (1*3) << 128 + (1*4 + 2*3) << 64 + (2*4), truncated to 2 UInts
    @test x * y == LongLongUInt((6, 8))
    
    # Verify with BigInt conversion
    x = LongLongUInt((10, 7))
    y = LongLongUInt((0, 3))
    result = x * y
    expected = BigInt(x) * BigInt(y)
    expected_truncated = expected & ((BigInt(1) << 128) - 1)  # Truncate to 128 bits
    @test BigInt(result) == expected_truncated

    x = LongLongUInt((UInt(0), typemax(UInt64)))
    y = LongLongUInt((UInt(0), UInt(3)))
    @test BigInt(x * y) == BigInt(x) * BigInt(y)

    # Hard instance
    a = LongLongUInt((ntuple(i -> UInt64(0), Val{10}())..., ntuple(i -> rand(UInt64), Val{5}())...))
    b = LongLongUInt((ntuple(i -> UInt64(0), Val{6}())..., ntuple(i -> rand(UInt64), Val{9}())...))
    @show BigInt(a * b) - BigInt(a) * BigInt(b)
    @test BigInt(a * b) == BigInt(a) * BigInt(b)
end
