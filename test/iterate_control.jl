using Test, BitBasis

function swaprows!(v::AbstractVector, i::Int, j::Int)
    temp = v[i]
    v[i] = v[j]
    v[j] = temp
    v
end

function eye(b::Int)
    res = zeros(b, b)
    for i in 1:b
        res[i, i] = 1
    end
    res
end

mulrow!(v::AbstractVector, i::Int, f) = (v[i] *= f; v)

@testset "test group_shift!" begin
    @test group_shift!(5, [1, 2, 5]) == ([3, 28], [4, 8])
    @test group_shift!(5, [2, 3]) == ([1, 30], [1, 4])
    @test group_shift!(5, [1, 3, 5]) == ([1, 2, 28], [2, 4, 8])
end

@testset "test IterControl" begin
    v = randn(ComplexF64, 1 << 4)
    it = itercontrol(4, [3], [1])
    vec = Int[]
    it2 = itercontrol(4, [3, 4], [0, 0])
    for i in it2
        push!(vec, i)
    end
    @test vec == [0, 1, 2, 3]
    @test it2[end] == 3

    vec = Int[]
    it4 = itercontrol(4, [4, 2, 1], [1, 1, 1])
    for i in it4
        push!(vec, i)
    end
    @test vec == [11, 15]

    # test controlled operations
    @testset "test controlled operations" begin
        P0 = ComplexF64[1 0; 0 0]
        P1 = ComplexF64[0 0; 0 1]
        Z = ComplexF64[1 0; 0 -1]

        rrr = copy(v)
        controldo(x -> mulrow!(rrr, x + 1, -1.0), it4)
        M =
            kron(P1, eye(2), P1, Z) +
            kron(P0, eye(2), P0, eye(2)) +
            kron(P1, eye(2), P0, eye(2)) +
            kron(P0, eye(2), P1, eye(2))
        @test rrr ≈ M * v

        it = itercontrol(8, [3], [1])
        V = randn(ComplexF64, 1 << 8)
        res = kron(eye(1 << 5), ComplexF64[0 1; 1 0], eye(1 << 2)) * V
        rrr = copy(V)
        controldo(x -> swaprows!(rrr, x + 1, x - 3), it)
        @test rrr ≈ res

        rrr = copy(V)
        controldo(x -> mulrow!(rrr, x + 1, -1), itercontrol(8, [3, 7, 6], [1, 1, 1]))

        M =
            kron(eye(2), P1, Z, eye(4), P1, eye(4)) +
            kron(eye(2), P0, eye(8), P0, eye(4)) +
            kron(eye(2), P1, eye(8), P0, eye(4)) +
            kron(eye(2), P0, eye(8), P1, eye(4))

        @test rrr ≈ M * V
        ic = itercontrol(4, [2, 3], [0, 0])
        @test [ic...] == [ic[k] for k in 1:4]
    end
end
