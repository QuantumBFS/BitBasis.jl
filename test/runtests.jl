using BitBasis
using Documenter
using Test
using Aqua
Aqua.test_all(BitBasis)

const ⊗ = kron

@testset "test dit literal" begin
    include("DitStr.jl")
end

@testset "test bit literal" begin
    include("BitStr.jl")
end

@testset "test operations" begin
    include("bit_operations.jl")
end

@testset "test reorder" begin
    include("reorder.jl")
end

@testset "test utils" begin
    include("utils.jl")
end

@testset "test iterate control" begin
    include("iterate_control.jl")
end

@testset "longlonguint" begin
    include("longlonguint.jl")
end

DocMeta.setdocmeta!(BitBasis, :DocTestSetup, :(using BitBasis); recursive=true)
Documenter.doctest(BitBasis; manual=false)