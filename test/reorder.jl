using BitBasis, Random, SparseArrays, LinearAlgebra

DA = Diagonal(randn(2))
DB = Diagonal(randn(2))
DC = Diagonal(randn(2))
@test reorder(DC ⊗ DB ⊗ DA, [3, 1, 2]) ≈ DB ⊗ DA ⊗ DC
@test invorder(DC ⊗ DB ⊗ DA) ≈ DA ⊗ DB ⊗ DC

DA = sprand(2, 2, 0.5)
DB = sprand(2, 2, 0.5)
DC = sprand(2, 2, 0.5)
@test reorder(DC ⊗ DB ⊗ DA, [3, 1, 2]) ≈ DB ⊗ DA ⊗ DC
@test invorder(DC ⊗ DB ⊗ DA) ≈ DA ⊗ DB ⊗ DC
