using Test, BitBasis

ind = 12
inds = Int[12, 2]

@test readbit(12, 2) == 0
@test readbit.([12, 2], 2) == [0,1]
@test readbit.(12, [3,2]) == [1,0]
@test readbit.(12, [3,2], [2,3]) == [1, 2]
@test bmask(baddrs(13)...) == 13

@test flip(12, bmask(1)) == 13
@test flip(12, bmask(1, 3)) == 9
@test flip.([12, 2], bmask(2)) == [14, 0]
@test flip.([12, 2], bmask(2, 1)) == [15, 1]

@test setbit.(inds, bmask(2, 1)) == [15, 3]

# bitarray version
# b - bitarray and take bit
ba1_f = bitarray(ind, 64)
ba2_f = bitarray(Int64.(inds))
ba3_f = bitarray(Int32.(inds), 32)
@test size(ba1_f) == (64,)
@test size(ba2_f) == (64, 2)
@test Int.(ba2_f[1:32,:]) == Int.(ba3_f)

ba1 = bitarray(ind, 4)
ba2 = bitarray(inds, 4)
@test size(ba1) == (4,)
@test size(ba2) == (4, 2)
@test ind |> bitarray(4) == ba1
@test inds |> bitarray(4) == ba2

@test ba1[2, 1] == readbit(ind, 2)
@test ba1[[3, 2], 1] == readbit.(ind, [3, 2])
@test ba2[2,:] == readbit.([ind, 2], 2)

msk = bmask(2,5)
@test swapbits(7, msk) == 21
@test breflect(7, Int(0b0110001)) == Int(0b1000110) == breflect(7, Int(0b0110001), [bmask(1, 7), bmask(2, 6), bmask(3,5)])

@test bitarray(2, 4) == [false, true, false, false]
@test packbits(BitArray([true, true, true])) == 7

@test packbits(bitarray(3, 10)) == 3
@test packbits(bitarray([5,3,7,21], 10)) == [5, 3, 7, 21]

@testset "bint & bfloat" begin
    @test bint(5) == 5
    @test bint_r(3, nbit=4) == 12
    @test bfloat(3) == 0.75
    @test bfloat_r(3, nbit=4) == 0.75/4
    @test bint_r(0.75, nbit=3) == 6
    @test bint(0.75, nbit=3) == 3
end
