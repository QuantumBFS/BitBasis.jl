using Test, BitBasis

@test bsizeof(ind) == sizeof(Int) * 8
@test onehot(ComplexF64, 2, 2) == [0, 0, 1, 0]
@test bnorm(1,7) == 2
@test logdim1(rand(4, 4)) == log2i(4)
