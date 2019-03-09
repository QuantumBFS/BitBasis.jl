var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": "DocTestSetup = quote\n    using BitBasis, Dates\nend"
},

{
    "location": "#BitBasis-1",
    "page": "Home",
    "title": "BitBasis",
    "category": "section",
    "text": "Types and operations for basis represented by bits in linear algebra.using Markdown, Dates\nMarkdown.parse(\"*Documentation built* **$(Dates.now())** *with Julia* **$(VERSION)**\")"
},

{
    "location": "#Introduction-1",
    "page": "Home",
    "title": "Introduction",
    "category": "section",
    "text": "The basis of linear spaces can be marked by a set of symbols, for concrete physical systems, this can be binary spins, bits, qubits, etc. They can be in general represented as binary basis, e.g 00101, 10101....This package provides tools for manipulating such basis in an elegant efficient way in Julia."
},

{
    "location": "#BitBasis.allmasked-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.allmasked",
    "category": "method",
    "text": "allmasked(index::Integer, mask::Integer) -> Bool\n\nReturn true if all masked position of index is 1.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.anymasked-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.anymasked",
    "category": "method",
    "text": "anymasked(index::Integer, mask::Integer) -> Bool\n\nReturn true if any masked position of index is 1.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.baddrs-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.baddrs",
    "category": "method",
    "text": "baddrs(b::Integer) -> Vector\n\nget the locations of nonzeros bits, i.e. the inverse operation of bmask.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.basis-Tuple{Union{Int64, AbstractArray}}",
    "page": "Home",
    "title": "BitBasis.basis",
    "category": "method",
    "text": "basis([IntType], num_bits::Int) -> UnitRange{IntType}\nbasis([IntType], state::AbstractArray) -> UnitRange{IntType}\n\nReturns the UnitRange for basis in Hilbert Space of num_bits qubits. If an array is supplied, it will return a basis having the same size with the first diemension of array.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bdistance-Union{Tuple{Ti}, Tuple{Ti,Ti}} where Ti<:Integer",
    "page": "Home",
    "title": "BitBasis.bdistance",
    "category": "method",
    "text": "bdistance(i::Integer, j::Integer) -> Int\n\nReturn number of different bits.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bfloat-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.bfloat",
    "category": "method",
    "text": "bfloat(b::Integer; nbit::Int=bit_length(b)) -> Float64\n\nfloat view, with big end qubit 1.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bfloat_r-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.bfloat_r",
    "category": "method",
    "text": "bfloat_r(b::Integer; nbit::Int) -> Float64\n\nfloat view, with bits read in inverse order.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bint-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.bint",
    "category": "method",
    "text": "bint(b; nbit=nothing) -> Int\n\ninteger view, with little end qubit 1.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bint_r-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.bint_r",
    "category": "method",
    "text": "bint_r(b; nbit::Int) -> Integer\n\ninteger read in inverse order.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bit_length-Tuple{Integer}",
    "page": "Home",
    "title": "BitBasis.bit_length",
    "category": "method",
    "text": "bit_length(x::Integer) -> Int\n\nReturn the number of bits required to represent input integer x.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bit_literal-Tuple",
    "page": "Home",
    "title": "BitBasis.bit_literal",
    "category": "method",
    "text": "bit_literal(xs...)\n\nCreate a BitStr by input bits xs.\n\nExample\n\njulia> bit_literal(1, 0, 1, 0, 1, 1)\n110101 (53)\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bitarray-Union{Tuple{T}, Tuple{Array{T,1},Int64}} where T<:Number",
    "page": "Home",
    "title": "BitBasis.bitarray",
    "category": "method",
    "text": "bitarray(v::Vector, [num_bits::Int]) -> BitArray\nbitarray(v::Int, num_bits::Int) -> BitArray\nbitarray(num_bits::Int) -> Function\n\nConstruct BitArray from an integer vector, if num_bits not supplied, it is 64. If an integer is supplied, it returns a function mapping a Vector/Int to bitarray.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bmask",
    "page": "Home",
    "title": "BitBasis.bmask",
    "category": "function",
    "text": "bmask(::Type{T}) where T <: Integer -> zero(T)\nbmask([T::Type], positions::Int...) -> T\nbmask([T::Type], range::UnitRange{Int}) -> T\n\nReturn an integer mask of type T where 1 is the position masked according to positions or range. Directly use T will return an empty mask 0.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.breflect",
    "page": "Home",
    "title": "BitBasis.breflect",
    "category": "function",
    "text": "breflect(num_bits::Int, b::Integer[, masks::Vector{Integer}]) -> Integer\n\nReturn left-right reflected integer.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.bsizeof-Union{Tuple{Type{T}}, Tuple{T}} where T",
    "page": "Home",
    "title": "BitBasis.bsizeof",
    "category": "method",
    "text": "bsizeof(::Type)\n\nReturns the size of given type in number of binary digits.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.btruncate-Tuple{Integer,Any}",
    "page": "Home",
    "title": "BitBasis.btruncate",
    "category": "method",
    "text": "truncate(b, n)\n\nTruncate bits b to given length n.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.controldo-Union{Tuple{S}, Tuple{N}, Tuple{Union{Function, Type},IterControl{N,S,T} where T}} where S where N",
    "page": "Home",
    "title": "BitBasis.controldo",
    "category": "method",
    "text": "controldo(f, itr::IterControl)\n\nExecute f while iterating itr.\n\nnote: Note\nthis is faster but equivalent than using itr as an iterator. See also itercontrol.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.controller-Tuple{Union{UnitRange{Int64}, Int64, Array{Int64,1}, Tuple{Vararg{Int64,#s14}} where #s14},Union{UnitRange{Int64}, Int64, Array{Int64,1}, Tuple{Vararg{Int64,#s14}} where #s14}}",
    "page": "Home",
    "title": "BitBasis.controller",
    "category": "method",
    "text": "controller(cbits, cvals) -> Function\n\nReturn a function that checks whether a basis at cbits takes specific value cvals.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.flip-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.flip",
    "category": "method",
    "text": "flip(index::Integer, mask::Integer) -> Integer\n\nReturn an Integer with bits at masked position flipped.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.group_shift!-Union{Tuple{N}, Tuple{Int64,AbstractArray{Int64,1}}} where N",
    "page": "Home",
    "title": "BitBasis.group_shift!",
    "category": "method",
    "text": "group_shift!(nbits, positions)\n\nShift bits on positions together.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.hypercubic-Tuple{Array}",
    "page": "Home",
    "title": "BitBasis.hypercubic",
    "category": "method",
    "text": "hypercubic(A::Array) -> Array\n\nget the hypercubic representation for an array.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.invorder-Tuple{Union{AbstractArray{T,1}, AbstractArray{T,2}} where T}",
    "page": "Home",
    "title": "BitBasis.invorder",
    "category": "method",
    "text": "invorder(X::AbstractVecOrMat)\n\nInverse the order of given vector/matrix X.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.ismasked_equal-Union{Tuple{T}, Tuple{T,T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.ismasked_equal",
    "category": "method",
    "text": "ismasked_equal(index::Integer, mask::Integer, onemask::Integer) -> Bool\n\nReturn true if bits at positions masked by mask equal to 1 are equal to onemask.\n\nExample\n\njulia> n = 0b11001; mask = 0b10100; onemask = 0b10000;\n\njulia> ismasked_equal(n, mask, onemask)\ntrue\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.itercontrol-Tuple{Int64,AbstractArray{T,1} where T,Any}",
    "page": "Home",
    "title": "BitBasis.itercontrol",
    "category": "method",
    "text": "itercontrol([T=Int], nbits, positions, bit_configs)\n\nReturns an iterator which iterate through controlled subspace of bits.\n\nExample\n\nTo iterate through all the bits satisfy 0xx10x1 where x means an arbitrary bit.\n\njulia> for each in itercontrol(7, [1, 3, 4, 7], (1, 0, 1, 0))\n           println(string(each, base=2, pad=7))\n       end\n0001001\n0001011\n0011001\n0011011\n0101001\n0101011\n0111001\n0111011\n\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.log2dim1-Tuple{Any}",
    "page": "Home",
    "title": "BitBasis.log2dim1",
    "category": "method",
    "text": "log2dim1(X)\n\nReturns the log2 of the first dimension\'s size.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.log2i",
    "page": "Home",
    "title": "BitBasis.log2i",
    "category": "function",
    "text": "log2i(x::Integer) -> Integer\n\nReturn log2(x), this integer version of log2 is fast but only valid for number equal to 2^n.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.neg-Union{Tuple{T}, Tuple{T,Int64}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.neg",
    "category": "method",
    "text": "neg(index::Integer, num_bits::Int) -> Integer\n\nReturn an integer with all bits flipped (with total number of bit num_bits).\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.onehot-Union{Tuple{T}, Tuple{Type{T},BitStr}} where T",
    "page": "Home",
    "title": "BitBasis.onehot",
    "category": "method",
    "text": "onehot([T=Float64], bit_str)\n\nReturns an onehot vector of type Vector{T}, where the bit_str-th element is one.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.onehot-Union{Tuple{T}, Tuple{Type{T},Int64,Integer}} where T",
    "page": "Home",
    "title": "BitBasis.onehot",
    "category": "method",
    "text": "onehot([T=Float64], nbits, x::Integer)\n\nReturns an onehot vector of type Vector{T}, where index x + 1 is one.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.packbits-Tuple{AbstractArray{T,1} where T}",
    "page": "Home",
    "title": "BitBasis.packbits",
    "category": "method",
    "text": "packbits(arr::AbstractArray) -> AbstractArray\n\npack bits to integers, usually take a BitArray as input.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.reorder",
    "page": "Home",
    "title": "BitBasis.reorder",
    "category": "function",
    "text": "reorder(X::AbstractArray, orders)\n\nReorder X according to orders.\n\ntip: Tip\nAlthough orders can be any iterable, Tuple is preferred inorder to gain as much performance as possible. But the conversion won\'t take much anyway.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.setbit-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.setbit",
    "category": "method",
    "text": "setbit(index::Integer, mask::Integer) -> Integer\n\nset the bit at masked position to 1.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.swapbits-Tuple{Integer,Int64,Int64}",
    "page": "Home",
    "title": "BitBasis.swapbits",
    "category": "method",
    "text": "swapbits(n::Integer, i::Int, j::Int) -> Integer\n\nReturn an integer with bits at i and j flipped.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.swapbits-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Home",
    "title": "BitBasis.swapbits",
    "category": "method",
    "text": "swapbits(n::Integer, mask_ij::Integer) -> Integer\n\nReturn an integer with bits at i and j in given mask flipped.\n\nwarning: Warning\nmask_ij should only contain two 1, swapbits will not check it, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.@bit_str-Tuple{Any}",
    "page": "Home",
    "title": "BitBasis.@bit_str",
    "category": "macro",
    "text": "@bit_str -> BitStr\n\nConstruct a bit string. such as bit\"0000\". The bit strings also supports string bcat. Just use it like normal strings.\n\nExample\n\njulia> bit\"10001\"\n10001 (17)\n\njulia> bit\"100_111_101\"\n00001110101 (117)\n\njulia> bcat(bit\"1001\", bit\"11\", bit\"1110\")\n1001111110 (638)\n\njulia> v = rand(16);\n\njulia> v[bit\"1001\"]\n0.38965443157314406\n\njulia> onehot(bit\"1001\")\n16-element Array{Float64,1}:\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 1.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.BitStr",
    "page": "Home",
    "title": "BitBasis.BitStr",
    "category": "type",
    "text": "BitStr{T}\n\nString literal for bits.\n\nBitStr(value[, len=ndigits(value)])\n\nReturns a BitStr, by default the length is set to the minimum length required to represent value as bits.\n\nBitStr(str::String)\n\nParse the input string to a BitStr. See @bit_str for more details.\n\nExample\n\nBitStr supports some basic arithmetic operations. It acts like an integer, but supports some frequently used methods for binary basis.\n\njulia> bit\"101\" * 2\n1010 (10)\n\njulia> bcat(bit\"101\" for i in 1:10)\n101101101101101101101101101101 (766958445)\n\njulia> repeat(bit\"101\", 2)\n101101 (45)\n\njulia> bit\"1101\"[2]\n0\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.IterControl",
    "page": "Home",
    "title": "BitBasis.IterControl",
    "category": "type",
    "text": "IterControl{N, S, T}\n\nIterator to iterate through controlled subspace. See also itercontrol. N is the size of whole hilbert space, S is the number of shifts.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.ReorderedBasis",
    "page": "Home",
    "title": "BitBasis.ReorderedBasis",
    "category": "type",
    "text": "ReorderedBasis{N, T}\n\nLazy reorderd basis.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.ReorderedBasis-Union{Tuple{Tuple{Vararg{T,N}}}, Tuple{T}, Tuple{N}} where T<:Integer where N",
    "page": "Home",
    "title": "BitBasis.ReorderedBasis",
    "category": "method",
    "text": "ReorderedBasis(orders::NTuple{N, <:Integer})\n\nReturns a lazy set of reordered basis.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.next_reordered_basis-Union{Tuple{T}, Tuple{N}, Tuple{T,Tuple{Vararg{T,N}},Tuple{Vararg{T,N}}}} where T where N",
    "page": "Home",
    "title": "BitBasis.next_reordered_basis",
    "category": "method",
    "text": "next_reordered_basis(basis, takers, differ)\n\nReturns the next reordered basis accroding to current basis.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.unsafe_reorder",
    "page": "Home",
    "title": "BitBasis.unsafe_reorder",
    "category": "function",
    "text": "unsafe_reorder(X::AbstractArray, orders)\n\nReorder X according to orders.\n\nwarning: Warning\nunsafe_reorder won\'t check whether the length of orders and the size of first dimension of X match, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.unsafe_sub-Union{Tuple{T}, Tuple{N}, Tuple{UnitRange{T},Tuple{Vararg{T,N}}}} where T where N",
    "page": "Home",
    "title": "BitBasis.unsafe_sub",
    "category": "method",
    "text": "unsafe_sub(a::UnitRange, b::NTuple{N}) -> NTuple{N}\n\nReturns result in type Tuple of a .- b. This will not check the length of a and b, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "#BitBasis.unsafe_sub-Union{Tuple{T}, Tuple{UnitRange{T},Array{T,1}}} where T",
    "page": "Home",
    "title": "BitBasis.unsafe_sub",
    "category": "method",
    "text": "unsafe_sub(a::UnitRange{T}, b::Vector{T}) where T\n\nReturns a .- b, fallback version when b is a Vector.\n\n\n\n\n\n"
},

{
    "location": "#Documentation-1",
    "page": "Home",
    "title": "Documentation",
    "category": "section",
    "text": "Modules = [BitBasis]\nOrder   = [:function, :macro, :type]"
},

]}
