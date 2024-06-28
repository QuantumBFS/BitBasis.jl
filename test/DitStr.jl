using BitBasis, Test

@testset "ditstr" begin
    x = dit"112100;3"
    @test x isa DitStr
    @test x |> length == 6
    println(x)
    @test buffer(x) === Int64(3^5 + 3^4 + 2 * 3^3 + 3^2)
    @test_throws ErrorException randn(100)[x]
    @test BitBasis.readat(x, 2) == Int64(0)
    @test x[2] == Int64(0)
    @test x[3] == Int64(1)
    @test x[4] == Int64(2)
    @test [x...] == Int64[0, 0, 1, 2, 1, 1]
    @test [DitStr{3}(Int64[0, 0, 1, 2, 1, 1])...] == Int64[0, 0, 1, 2, 1, 1]
    @test_throws ErrorException BitBasis.parse_dit(Int64, "112103;3")
    @test_throws ErrorException BitBasis.parse_dit(Int64, "112101;")

    @test join(dit"001;3", dit"002;3") == dit"001002;3"
    print(ldit"12341111111111111111111111111111111111111111111111111111111;5")
    @test_throws ErrorException Base.checkindex(Bool, 1:3, dit"22;3")
    @test BitBasis.readat(dit"001;3") == 0
    @test BitBasis.readat(dit"001;3", 1, 2, 3) == 1
    @test_throws ErrorException BitBasis.parse_dit(Int64, "12341111111111111111111111111111111111111111111111111111111;5")

    @test hash(x) isa UInt64
end

@testset "SubDitStr" begin
    x = dit"112100;3"
    sx = SubDitStr(x, 2, 4) # bit"210"
    @test_throws BoundsError SubDitStr(x, 2, 7)
    @test checkbounds(sx, 1) == nothing
    @test getindex(sx, 1) == 0
    @test getindex(sx, 2) == 1
    @test getindex(sx, 3) == 2
    @test_throws BoundsError getindex(sx, 4)
    @test_throws BoundsError getindex(sx, 0)
    @test length(sx) == 3
    @test sx == dit"210;3"
    @test dit"210;3" == sx
    @test DitStr(sx) == dit"210;3"
    @test SubDitStr(dit"210;3",1,length(dit"210;3")) == sx
    @test (@views x[4:end]) == dit"112;3"
    @test (@views x[begin:3]) == dit"100;3"   
end

# function bm()
#     # test performance in slicing
#     a = LongBitStr(ones(Bool, 200))
#     @btime LongBitStr($a[1:100]) # 3.925 μs (14 allocations: 1.42 KiB)
#     @btime SubDitStr($a, 1, 100) # 1.600 ns (0 allocations: 0 bytes) 
#     @btime DitStr(SubDitStr($a, 1, 100)) # 2.722 μs (4 allocations: 192 bytes)
# end