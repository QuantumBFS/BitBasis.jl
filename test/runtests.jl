using BitBasis
using Test

const ⊗ = kron

@testset "test bit literal" begin
    include("bit_str.jl")
end

@testset "test operations" begin
    include("operations.jl")
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
