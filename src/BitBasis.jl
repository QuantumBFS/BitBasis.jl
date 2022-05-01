module BitBasis

export DitStr, BitStr, @bit_str, @lbit_str, BitStr64, LongBitStr, bit_literal
export bcat, onehot, buffer
export bitarray, basis, packbits, bfloat, bfloat_r, bint, bint_r, flip
export anyone, allone, bmask, baddrs, readbit, setbit, controller
export swapbits, ismatch, neg, breflect, btruncate

include("utils.jl")
include("DitStr.jl")
include("BitStr.jl")
include("bit_operations.jl")
include("reorder.jl")
include("iterate_control.jl")

include("deprecations.jl")

end # module
