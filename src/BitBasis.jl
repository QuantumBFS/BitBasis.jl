module BitBasis

export DitStr, BitStr, @bit_str, @lbit_str, @dit_str, @ldit_str, BitStr64, LongBitStr, DitStr64, LongDitStr, bit_literal
export onehot, buffer, indicator
export bitarray, basis, packbits, bfloat, bfloat_r, bint, bint_r, flip
export anyone, allone, bmask, baddrs, readbit, setbit, controller
export swapbits, ismatch, neg, breflect, btruncate
export LongLongUInt

include("utils.jl")
include("longlonguint.jl")
include("DitStr.jl")
include("BitStr.jl")
include("bit_operations.jl")
include("reorder.jl")
include("iterate_control.jl")

include("deprecations.jl")

end # module
