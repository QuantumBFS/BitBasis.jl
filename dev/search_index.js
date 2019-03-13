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
    "location": "#Contents-1",
    "page": "Home",
    "title": "Contents",
    "category": "section",
    "text": "Pages = [\n    \"tutorial.md\",\n    \"man.md\",\n]"
},

{
    "location": "tutorial/#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": "using BitBasis"
},

{
    "location": "tutorial/#Conventions-1",
    "page": "Tutorial",
    "title": "Conventions",
    "category": "section",
    "text": "We use σ to represent a binary digit, its subtitle usually refers to the position of a given binary digit inside a number (bit string).There are two different representation orders of a bit string."
},

{
    "location": "tutorial/#array_order-1",
    "page": "Tutorial",
    "title": "array order",
    "category": "section",
    "text": "This follows the order of BitArray or other array representation of bits, e.gFor number 0b011101 (29)sigma_1=1 sigma_2=0 sigma_3=1 sigma_4=1 sigma_5=1 sigma_6=0"
},

{
    "location": "tutorial/#literal_order-1",
    "page": "Tutorial",
    "title": "literal order",
    "category": "section",
    "text": "This follows the order of binary literal 0bxxxx, e.gFor number 0b011101 (29)sigma_1=0 sigma_2=1 sigma_3=1 sigma_4=1 sigma_5=0 sigma_6=1"
},

{
    "location": "tutorial/#Integer-Representations-1",
    "page": "Tutorial",
    "title": "Integer Representations",
    "category": "section",
    "text": "We use an Int type to store bit-wise (spin) configurations, e.g. 0b011101 (29) represents the configurationsigma_1=1 sigma_2=0 sigma_3=1 sigma_4=1 sigma_5=1 sigma_6=0so we annotate the configurations vec σ with integer b by b = sumlimits_i 2^i-1σ_i. (Image: 11100) e.g. we can use a number 28 to represent bit configuration 0b11100bdistance(0b11100, 0b10101) == 2  # Hamming distance\nbit_length(0b11100) == 5In BitBasis, we also provide a more readable way to define these kind of objects, which is called the bit string literal, most of the integer operations and BitBasis functions are overloaded for the bit string literal.We can switch between binary and digital representations withbitarray(integers, nbits), transform integers to bistrings of type BitArray.\npackabits(bitstring), transform bitstrings to integers.\nbaddrs(integer), get the locations of nonzero qubits.bitarray(4, 5)\nbitarray([4, 5, 6], 5)\npackbits([1, 1, 0])\nbitarray([4, 5, 6], 5) |> packbits;A curried version of the above function is also provided. See also bitarray."
},

{
    "location": "tutorial/#bit_literal-1",
    "page": "Tutorial",
    "title": "Bit String Literal",
    "category": "section",
    "text": "bit strings are literals for bits, it provides better view on binary basis. you could use @bit_str, which looks like the followingbit\"101\" * 2\nbcat(bit\"101\" for i in 1:10)\nrepeat(bit\"101\", 2)\nbit\"1101\"[2]to define a bit string with length. bit\"10101\" is equivalent to 0b10101 on both performance and functionality but it store the length of given bits statically. The bit string literal offers a more readable syntax for these kind of objects.Besides bit literal, you can convert a string or an integer to bit literal by bit, e.gbit(0b00101; len=5)Or use the least number of digits requiredbit(0b00101)"
},

{
    "location": "tutorial/#Bit-Manipulations-1",
    "page": "Tutorial",
    "title": "Bit Manipulations",
    "category": "section",
    "text": ""
},

{
    "location": "tutorial/#[readbit](@ref)-and-[baddrs](@ref)-1",
    "page": "Tutorial",
    "title": "readbit and baddrs",
    "category": "section",
    "text": "(Image: 11100)readbit(0b11100, 2, 3) == 0b10  # read the 2nd and 3rd bits as `x₃x₂`\nbaddrs(0b11100) == [3,4,5]  # locations of one bits"
},

{
    "location": "tutorial/#[bmask](@ref)-1",
    "page": "Tutorial",
    "title": "bmask",
    "category": "section",
    "text": "Masking technic provides faster binary operations, to generate a mask with specific position masked, e.g. we want to mask qubits 1, 3, 4mask = bmask(UInt8, 1,3,4)\nbit(mask; len=4)"
},

{
    "location": "tutorial/#[allone](@ref)-and-[anyone](@ref)-1",
    "page": "Tutorial",
    "title": "allone and anyone",
    "category": "section",
    "text": "with this mask (masked positions are colored light blue), we have (Image: 1011_1101)allone(0b1011, mask) == false # true if all masked positions are 1\nanyone(0b1011, mask) == true # true if any masked positions is 1"
},

{
    "location": "tutorial/#[ismatch](@ref)-1",
    "page": "Tutorial",
    "title": "ismatch",
    "category": "section",
    "text": "(Image: ismatch)ismatch(0b1011, mask, 0b1001) == true  # true if masked part matches `0b1001`"
},

{
    "location": "tutorial/#[flip](@ref)-1",
    "page": "Tutorial",
    "title": "flip",
    "category": "section",
    "text": "(Image: 1011_1101)bit(flip(0b1011, mask); len=4)  # flip masked positions"
},

{
    "location": "tutorial/#[setbit](@ref)-1",
    "page": "Tutorial",
    "title": "setbit",
    "category": "section",
    "text": "(Image: setbit)setbit(0b1011, 0b1100) == 0b1111 # set masked positions 1"
},

{
    "location": "tutorial/#[swapbits](@ref)-1",
    "page": "Tutorial",
    "title": "swapbits",
    "category": "section",
    "text": "(Image: swapbits)swapbits(0b1011, 0b1100) == 0b0111  # swap masked positions"
},

{
    "location": "tutorial/#[neg](@ref)-1",
    "page": "Tutorial",
    "title": "neg",
    "category": "section",
    "text": "neg(0b1011, 2) == 0b1000"
},

{
    "location": "tutorial/#[btruncate](@ref)-and-[breflect](@ref)-1",
    "page": "Tutorial",
    "title": "btruncate and breflect",
    "category": "section",
    "text": "(Image: btruncate)btruncate(0b1011, 2) == 0b0011  # only the first two qubits are retained"
},

{
    "location": "tutorial/#[breflect](@ref)-1",
    "page": "Tutorial",
    "title": "breflect",
    "category": "section",
    "text": "(Image: breflect)breflect(4, 0b1011) == 0b1101  # reflect little end and big endFor more interesting bitwise operations, see manual page BitBasis."
},

{
    "location": "tutorial/#Number-Readouts-1",
    "page": "Tutorial",
    "title": "Number Readouts",
    "category": "section",
    "text": "In phase estimation and HHL algorithms, one need to read out qubits as integer or float point numbers. A register can be read out in different ways, likebint, the integer itself\nbint_r, the integer with bits small-big end reflected.\nbfloat, the float point number 0.σ₁σ₂...σₙ.\nbfloat_r, the float point number 0.σₙ...σ₂σ₁.(Image: 010101)bint(0b010101)\nbint_r(0b010101, nbits=6)\nbfloat(0b010101)\nbfloat_r(0b010101, nbits=6);Notice the functions with _r as postfix always require nbits as an additional input parameter to help reading, which is regarded as less natural way of expressing numbers."
},

{
    "location": "tutorial/#Iterating-over-Bases-1",
    "page": "Tutorial",
    "title": "Iterating over Bases",
    "category": "section",
    "text": "Counting from 0 is very natural way of iterating quantum registers, very pity for Juliaitr = basis(4)\ncollect(itr)itercontrol is a complicated API, but it plays an fundamental role in high performance quantum simulation of Yao. It is used for iterating over basis in controlled way, its interface looks likefor each in itercontrol(7, [1, 3, 4, 7], (1, 0, 1, 0))\n    println(string(each, base=2, pad=7))\nend"
},

{
    "location": "tutorial/#Reordering-Basis-1",
    "page": "Tutorial",
    "title": "Reordering Basis",
    "category": "section",
    "text": "We store the wave function as vb+1 = langle bpsirangle. We are able to reorder the basis asv = onehot(5, 0b11100)  # the one hot vector representation of given bits\nreorder(v, (3,2,1,5,4)) ≈ onehot(5, 0b11001)\ninvorder(v) ≈ onehot(5, 0b00111)  # breflect for each basis"
},

{
    "location": "man/#",
    "page": "Manual",
    "title": "Manual",
    "category": "page",
    "text": "DocTestSetup = quote\n    using BitBasis\nend"
},

{
    "location": "man/#BitBasis.BitStr",
    "page": "Manual",
    "title": "BitBasis.BitStr",
    "category": "type",
    "text": "BitStr{T}\n\nString literal for bits.\n\nBitStr(value[, len=ndigits(value)])\n\nReturns a BitStr, by default the length is set to the minimum length required to represent value as bits.\n\nBitStr(str::String)\n\nParse the input string to a BitStr. See @bit_str for more details.\n\nExample\n\nBitStr supports some basic arithmetic operations. It acts like an integer, but supports some frequently used methods for binary basis.\n\njulia> bit\"101\" * 2\n1010 (10)\n\njulia> bcat(bit\"101\" for i in 1:10)\n101101101101101101101101101101 (766958445)\n\njulia> repeat(bit\"101\", 2)\n101101 (45)\n\njulia> bit\"1101\"[2]\n0\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.IterControl",
    "page": "Manual",
    "title": "BitBasis.IterControl",
    "category": "type",
    "text": "IterControl{N, S, T}\n\nIterator to iterate through controlled subspace. See also itercontrol. N is the size of whole hilbert space, S is the number of shifts.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.ReorderedBasis",
    "page": "Manual",
    "title": "BitBasis.ReorderedBasis",
    "category": "type",
    "text": "ReorderedBasis{N, T}\n\nLazy reorderd basis.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.ReorderedBasis-Union{Tuple{Tuple{Vararg{T,N}}}, Tuple{T}, Tuple{N}} where T<:Integer where N",
    "page": "Manual",
    "title": "BitBasis.ReorderedBasis",
    "category": "method",
    "text": "ReorderedBasis(orders::NTuple{N, <:Integer})\n\nReturns a lazy set of reordered basis.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.@bit_str-Tuple{Any}",
    "page": "Manual",
    "title": "BitBasis.@bit_str",
    "category": "macro",
    "text": "@bit_str -> BitStr\n\nConstruct a bit string. such as bit\"0000\". The bit strings also supports string bcat. Just use it like normal strings.\n\nExample\n\njulia> bit\"10001\"\n10001 (17)\n\njulia> bit\"100_111_101\"\n100111101 (317)\n\njulia> bcat(bit\"1001\", bit\"11\", bit\"1110\")\n1001111110 (638)\n\njulia> v = collect(1:16);\n\njulia> v[bit\"1001\"]\n10\n\njulia> onehot(bit\"1001\")\n16-element Array{Float64,1}:\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 1.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n 0.0\n\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.allone-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.allone",
    "category": "method",
    "text": "allone(index::Integer, mask::Integer) -> Bool\n\nReturn true if all masked position of index is 1.\n\nExample\n\ntrue if all masked positions are 1.\n\njulia> allone(0b1011, 0b1011)\ntrue\n\njulia> allone(0b1011, 0b1001)\ntrue\n\njulia> allone(0b1011, 0b0100)\nfalse\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.anyone-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.anyone",
    "category": "method",
    "text": "anyone(index::Integer, mask::Integer) -> Bool\n\nReturn true if any masked position of index is 1.\n\nExample\n\ntrue if any masked positions is 1.\n\njulia> anyone(0b1011, 0b1001)\ntrue\n\njulia> anyone(0b1011, 0b1100)\ntrue\n\njulia> anyone(0b1011, 0b0100)\nfalse\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.baddrs-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.baddrs",
    "category": "method",
    "text": "baddrs(b::Integer) -> Vector\n\nget the locations of nonzeros bits, i.e. the inverse operation of bmask.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.basis-Tuple{Union{Int64, AbstractArray}}",
    "page": "Manual",
    "title": "BitBasis.basis",
    "category": "method",
    "text": "basis([IntType], nbits::Int) -> UnitRange{IntType}\nbasis([IntType], state::AbstractArray) -> UnitRange{IntType}\n\nReturns the UnitRange for basis in Hilbert Space of nbits qubits. If an array is supplied, it will return a basis having the same size with the first diemension of array.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bdistance-Union{Tuple{Ti}, Tuple{Ti,Ti}} where Ti<:Integer",
    "page": "Manual",
    "title": "BitBasis.bdistance",
    "category": "method",
    "text": "bdistance(i::Integer, j::Integer) -> Int\n\nReturn number of different bits.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bfloat-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bfloat",
    "category": "method",
    "text": "bfloat(b::Integer; nbits::Int=bit_length(b)) -> Float64\n\nfloat view, with big end qubit 1.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bfloat_r-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bfloat_r",
    "category": "method",
    "text": "bfloat_r(b::Integer; nbits::Int) -> Float64\n\nfloat view, with bits read in inverse order.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bint-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bint",
    "category": "method",
    "text": "bint(b; nbits=nothing) -> Int\n\ninteger view, with little end qubit 1.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bint_r-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bint_r",
    "category": "method",
    "text": "bint_r(b; nbits::Int) -> Integer\n\ninteger read in inverse order.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bit-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bit",
    "category": "method",
    "text": "bit(x[; len=ndigits(x, base=2)])\n\nCreate a BitStr accroding to integer x to given length len.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bit-Tuple{String}",
    "page": "Manual",
    "title": "BitBasis.bit",
    "category": "method",
    "text": "bit(string)\n\nCreate a BitStr with given string of bits. See also @bit_str.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bit-Tuple{}",
    "page": "Manual",
    "title": "BitBasis.bit",
    "category": "method",
    "text": "bit(;len)\n\nLazy curried version of bit.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bit_length-Tuple{Integer}",
    "page": "Manual",
    "title": "BitBasis.bit_length",
    "category": "method",
    "text": "bit_length(x::Integer) -> Int\n\nReturn the number of bits required to represent input integer x.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bit_literal-Tuple",
    "page": "Manual",
    "title": "BitBasis.bit_literal",
    "category": "method",
    "text": "bit_literal(xs...)\n\nCreate a BitStr by input bits xs.\n\nExample\n\njulia> bit_literal(1, 0, 1, 0, 1, 1)\n110101 (53)\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bitarray-Union{Tuple{T}, Tuple{Array{T,1},Int64}} where T<:Number",
    "page": "Manual",
    "title": "BitBasis.bitarray",
    "category": "method",
    "text": "bitarray(v::Vector, [nbits::Int]) -> BitArray\nbitarray(v::Int, nbits::Int) -> BitArray\nbitarray(nbits::Int) -> Function\n\nConstruct BitArray from an integer vector, if nbits not supplied, it is 64. If an integer is supplied, it returns a function mapping a Vector/Int to bitarray.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bmask",
    "page": "Manual",
    "title": "BitBasis.bmask",
    "category": "function",
    "text": "bmask(::Type{T}) where T <: Integer -> zero(T)\nbmask([T::Type], positions::Int...) -> T\nbmask([T::Type], range::UnitRange{Int}) -> T\n\nReturn an integer mask of type T where 1 is the position masked according to positions or range. Directly use T will return an empty mask 0.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.breflect",
    "page": "Manual",
    "title": "BitBasis.breflect",
    "category": "function",
    "text": "breflect(nbits::Int, b::Integer[, masks::Vector{Integer}]) -> Integer\n\nReturn left-right reflected integer.\n\nExample\n\nReflect the order of bits.\n\njulia> breflect(4, 0b1011) == 0b1101\ntrue\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.bsizeof-Union{Tuple{Type{T}}, Tuple{T}} where T",
    "page": "Manual",
    "title": "BitBasis.bsizeof",
    "category": "method",
    "text": "bsizeof(::Type)\n\nReturns the size of given type in number of binary digits.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.btruncate-Tuple{Integer,Any}",
    "page": "Manual",
    "title": "BitBasis.btruncate",
    "category": "method",
    "text": "truncate(b, n)\n\nTruncate bits b to given length n.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.controldo-Union{Tuple{S}, Tuple{N}, Tuple{Union{Function, Type},IterControl{N,S,T} where T}} where S where N",
    "page": "Manual",
    "title": "BitBasis.controldo",
    "category": "method",
    "text": "controldo(f, itr::IterControl)\n\nExecute f while iterating itr.\n\nnote: Note\nthis is faster but equivalent than using itr as an iterator. See also itercontrol.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.controller-Tuple{Union{UnitRange{Int64}, Int64, Array{Int64,1}, Tuple{Vararg{Int64,#s14}} where #s14},Union{UnitRange{Int64}, Int64, Array{Int64,1}, Tuple{Vararg{Int64,#s14}} where #s14}}",
    "page": "Manual",
    "title": "BitBasis.controller",
    "category": "method",
    "text": "controller(cbits, cvals) -> Function\n\nReturn a function that checks whether a basis at cbits takes specific value cvals.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.flip-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.flip",
    "category": "method",
    "text": "flip(index::Integer, mask::Integer) -> Integer\n\nReturn an Integer with bits at masked position flipped.\n\nExample\n\njulia> flip(0b1011, 0b1011) |> bit(len=4)\n0000 (0)\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.group_shift!-Union{Tuple{N}, Tuple{Int64,AbstractArray{Int64,1}}} where N",
    "page": "Manual",
    "title": "BitBasis.group_shift!",
    "category": "method",
    "text": "group_shift!(nbits, positions)\n\nShift bits on positions together.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.hypercubic-Tuple{Array}",
    "page": "Manual",
    "title": "BitBasis.hypercubic",
    "category": "method",
    "text": "hypercubic(A::Array) -> Array\n\nget the hypercubic representation for an array.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.invorder-Tuple{Union{AbstractArray{T,1}, AbstractArray{T,2}} where T}",
    "page": "Manual",
    "title": "BitBasis.invorder",
    "category": "method",
    "text": "invorder(X::AbstractVecOrMat)\n\nInverse the order of given vector/matrix X.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.ismatch-Union{Tuple{T}, Tuple{T,T,T}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.ismatch",
    "category": "method",
    "text": "ismatch(index::Integer, mask::Integer, target::Integer) -> Bool\n\nReturn true if bits at positions masked by mask equal to 1 are equal to target.\n\nExample\n\njulia> n = 0b11001; mask = 0b10100; target = 0b10000;\n\njulia> ismatch(n, mask, target)\ntrue\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.itercontrol-Tuple{Int64,AbstractArray{T,1} where T,Any}",
    "page": "Manual",
    "title": "BitBasis.itercontrol",
    "category": "method",
    "text": "itercontrol([T=Int], nbits, positions, bit_configs)\n\nReturns an iterator which iterate through controlled subspace of bits.\n\nExample\n\nTo iterate through all the bits satisfy 0xx10x1 where x means an arbitrary bit.\n\njulia> for each in itercontrol(7, [1, 3, 4, 7], (1, 0, 1, 0))\n           println(string(each, base=2, pad=7))\n       end\n0001001\n0001011\n0011001\n0011011\n0101001\n0101011\n0111001\n0111011\n\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.log2dim1-Tuple{Any}",
    "page": "Manual",
    "title": "BitBasis.log2dim1",
    "category": "method",
    "text": "log2dim1(X)\n\nReturns the log2 of the first dimension\'s size.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.log2i",
    "page": "Manual",
    "title": "BitBasis.log2i",
    "category": "function",
    "text": "log2i(x::Integer) -> Integer\n\nReturn log2(x), this integer version of log2 is fast but only valid for number equal to 2^n.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.neg-Union{Tuple{T}, Tuple{T,Int64}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.neg",
    "category": "method",
    "text": "neg(index::Integer, nbits::Int) -> Integer\n\nReturn an integer with all bits flipped (with total number of bit nbits).\n\nExample\n\njulia> neg(0b1111, 4) |> bit(len=4)\n0000 (0)\n\njulia> neg(0b0111, 4) |> bit(len=4)\n1000 (8)\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.onehot-Union{Tuple{T}, Tuple{Type{T},BitStr}} where T",
    "page": "Manual",
    "title": "BitBasis.onehot",
    "category": "method",
    "text": "onehot([T=Float64], bit_str)\n\nReturns an onehot vector of type Vector{T}, where the bit_str-th element is one.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.onehot-Union{Tuple{T}, Tuple{Type{T},Int64,Integer}} where T",
    "page": "Manual",
    "title": "BitBasis.onehot",
    "category": "method",
    "text": "onehot([T=Float64], nbits, x::Integer)\n\nReturns an onehot vector of type Vector{T}, where index x + 1 is one.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.packbits-Tuple{AbstractArray{T,1} where T}",
    "page": "Manual",
    "title": "BitBasis.packbits",
    "category": "method",
    "text": "packbits(arr::AbstractArray) -> AbstractArray\n\npack bits to integers, usually take a BitArray as input.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.readbit-Union{Tuple{T}, Tuple{T,Int64}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.readbit",
    "category": "method",
    "text": "readbit(x, loc...)\n\nRead the bit config at given location.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.reorder",
    "page": "Manual",
    "title": "BitBasis.reorder",
    "category": "function",
    "text": "reorder(X::AbstractArray, orders)\n\nReorder X according to orders.\n\ntip: Tip\nAlthough orders can be any iterable, Tuple is preferred inorder to gain as much performance as possible. But the conversion won\'t take much anyway.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.setbit-Union{Tuple{T}, Tuple{T,T}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.setbit",
    "category": "method",
    "text": "setbit(index::Integer, mask::Integer) -> Integer\n\nset the bit at masked position to 1.\n\nExample\n\njulia> setbit(0b1011, 0b1100) |> bit(len=4)\n1111 (15)\n\njulia> setbit(0b1011, 0b0100) |> bit(len=4)\n1111 (15)\n\njulia> setbit(0b1011, 0b0000) |> bit(len=4)\n1011 (11)\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.swapbits-Union{Tuple{T}, Tuple{T,Int64,Int64}} where T<:Integer",
    "page": "Manual",
    "title": "BitBasis.swapbits",
    "category": "method",
    "text": "swapbits(n::Integer, mask_ij::Integer) -> Integer\nswapbits(n::Integer, i::Int, j::Int) -> Integer\n\nReturn an integer with bits at i and j flipped. For performance, locations i and j specified by mask is prefered.\n\nExample\n\njulia> swapbits(0b1011, 0b1100) == 0b0111\ntrue\n\nwarning: Warning\nmask_ij should only contain two 1, swapbits will not check it, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.next_reordered_basis-Union{Tuple{T}, Tuple{N}, Tuple{T,Tuple{Vararg{T,N}},Tuple{Vararg{T,N}}}} where T where N",
    "page": "Manual",
    "title": "BitBasis.next_reordered_basis",
    "category": "method",
    "text": "next_reordered_basis(basis, takers, differ)\n\nReturns the next reordered basis accroding to current basis.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.unsafe_reorder",
    "page": "Manual",
    "title": "BitBasis.unsafe_reorder",
    "category": "function",
    "text": "unsafe_reorder(X::AbstractArray, orders)\n\nReorder X according to orders.\n\nwarning: Warning\nunsafe_reorder won\'t check whether the length of orders and the size of first dimension of X match, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.unsafe_sub-Union{Tuple{T}, Tuple{N}, Tuple{UnitRange{T},Tuple{Vararg{T,N}}}} where T where N",
    "page": "Manual",
    "title": "BitBasis.unsafe_sub",
    "category": "method",
    "text": "unsafe_sub(a::UnitRange, b::NTuple{N}) -> NTuple{N}\n\nReturns result in type Tuple of a .- b. This will not check the length of a and b, use at your own risk.\n\n\n\n\n\n"
},

{
    "location": "man/#BitBasis.unsafe_sub-Union{Tuple{T}, Tuple{UnitRange{T},Array{T,1}}} where T",
    "page": "Manual",
    "title": "BitBasis.unsafe_sub",
    "category": "method",
    "text": "unsafe_sub(a::UnitRange{T}, b::Vector{T}) where T\n\nReturns a .- b, fallback version when b is a Vector.\n\n\n\n\n\n"
},

{
    "location": "man/#Manual-1",
    "page": "Manual",
    "title": "Manual",
    "category": "section",
    "text": "Modules = [BitBasis]\nOrder   = [:module, :constant, :type, :macro, :function]"
},

]}
