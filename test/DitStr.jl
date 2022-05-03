using BitBasis, Test

@testset "ditstr" begin
    x = dit"112100;3"
    @test x isa DitStr
    @test x |> length == 6
    println(x)
    @test buffer(x) === Int64(3^5 + 3^4 + 2*3^3 + 3^2)
    @test_throws ErrorException randn(100)[x]
    @test BitBasis.readat(x, 2) == Int64(0)
    @test x[2] == Int64(0)
    @test x[3] == Int64(1)
    @test x[4] == Int64(2)
    @test [x...] == Int64[0,0,1,2,1,1]
    @test [DitStr{3}(Int64[0,0,1,2,1,1])...] == Int64[0,0,1,2,1,1]
    @test_throws ErrorException BitBasis.parse_dit(Int64, "112103;3")
    @test_throws ErrorException BitBasis.parse_dit(Int64, "112101;")

    @test join(dit"001;3", dit"002;3") == dit"001002;3"
    print(ldit"12341111111111111111111111111111111111111111111111111111111;5")
    @test_throws ErrorException Base.checkindex(Bool, 1:3, dit"22;3")
    @test BitBasis.readat(dit"001;3") == 0
    @test BitBasis.readat(dit"001;3", 1, 2, 3) == 1
    @test_throws ErrorException BitBasis.parse_dit(Int64, "12341111111111111111111111111111111111111111111111111111111;5")
end
