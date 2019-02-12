using BitBasis
using Test

@testset "test bit literal" begin
    include("bit_str.jl")
end

@testset "test operations" begin
    include("operations.jl")
end

@testset "test reorder" begin
    include("reorder.jl")
end
