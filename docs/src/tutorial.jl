# # Basics Bitwise Operations
using BitBasis
#------------------
# ## Table of Contents
# * Representations
# * Bit Manipulations
# * Number Readouts
# * Iterating over Bases
# * Reordering Basis
# * Bit String Representation
#---------------------
# ## Representations
# We use an `Int` type to store spin configurations, e.g. `0b011101` (`29`) represents qubit configuration
# ```math
# \sigma_1=1, \sigma_2=0, \sigma_3=1, \sigma_4=1, \sigma_5=1, \sigma_6=0
# ```
# so we relate the configurations $\vec σ$ with integer $b$ by $b = \sum\limits_i 2^{i-1}σ_i$.
# ![11100](assets/bitbasic.png)
# e.g. we can use a digit `28` to represent bit configuration `0b11100`
@assert bdistance(0b11100, 0b10101) == 2  # Hamming distance
@assert bit_length(0b11100) == 5

#----------------------------
# We can switch between binary and digital representations with
# * `integer(s) |> bitarray(nbits)`, transform integers to bistrings of type `BitArray`.
# * `bitstring |> packabits`, transform bitstrings to integers.
# * `integer |> baddrs`, get the locations of nonzero qubits.
@show 4 |> bitarray(5)
@show [4, 5, 6] |> bitarray(5)
@show [1, 1 , 0] |> packbits
@show [4, 5, 6] |> bitarray(5) |> packbits;

# ## Bit Manipulations
# #### [`readbit`](@ref) and [`baddrs`](@ref)
# ![11100](assets/11100.png)
@assert readbit(0b11100, 2, 3) == 0b10  # read the 2nd and 3rd bits as `x₃x₂`
@assert baddrs(0b11100) == [3,4,5]  # locations of one bits

# #### [`bmask`](@ref)
# Masking technic provides faster binary operations, to generate a mask with specific position masked, e.g. we want to mask qubits `1, 3, 4`
mask = bmask(UInt8, 1,3,4)
@assert mask == 0b1101;

# #### [`allone`](@ref) and [`anyone`](@ref)
# with this mask (masked positions are colored light blue), we have
# ![1011_1101](assets/1011_1101.png)
@assert allone(0b1011, mask) == false # true if all masked positions are 1
@assert anyone(0b1011, mask) == true # true if any masked positions is 1

# #### [`ismatch`](@ref)
# ![ismatch](assets/ismatch.png)
@assert ismatch(0b1011, mask, 0b1001) == true  # true if masked part matches `0b1001`

# #### [`flip`](@ref)
# ![1011_1101](assets/flip.png)
@assert flip(0b1011, mask) == 0b0110  # flip masked positions

# #### [`setbit`](@ref)
# ![setbit](assets/setbit.png)
@assert setbit(0b1011, 0b1100) == 0b1111 # set masked positions 1

# #### [`swapbits`](@ref)
# ![swapbits](assets/swapbits.png)
@assert swapbits(0b1011, 0b1100) == 0b0111  # swap masked positions

#### [`neg`](@ref)
@assert neg(0b1011, 2) == 0b1000  # flip masked positions

# #### [`btruncate`](@ref) and [`breflect`](@ref)
# ![btruncate](assets/btruncate.png)
@assert btruncate(0b1011, 2) == 0b0011  # only the first two qubits are retained

# #### [`breflect`](@ref)
# ![breflect](assets/breflect.png)
@assert breflect(4, 0b1011) == 0b1101  # reflect little end and big end

# For more interesting bitwise operations, see manual page [BitBasis](@ref BitBasis).
# ----------------------------------
# ## Number Readouts
# In phase estimation and HHL algorithms, one need to read out qubits as integer or float point numbers.
# A register can be read out in different ways, like
# * bint, the integer itself
# * bint_r, the integer with bits small-big end reflected.
# * bfloat, the float point number 0.σ₁σ₂...σₙ.
# * bfloat_r, the float point number 0.σₙ...σ₂σ₁.
#
# ![010101](assets/010101.png)
@show bint(0b010101)
@show bint_r(0b010101, nbits=6)
@show bfloat(0b010101)
@show bfloat_r(0b010101, nbits=6);

# Notice here functions with `_r` ending always require `nbits` as an additional input parameter to help reading, which is regarded as less natural way of expressing numbers.
#----------------------
# ## Iterating over Bases
# Counting from `0` is very natural way of iterating quantum registers, very pity for `Julia`
basis(4)

# [`itercontrol`](@ref) is a complicated API, but it plays an fundamental role in high performance quantum simulation of `Yao`.
# It is used for iterating over basis in controlled way, its interface looks like
@doc itercontrol

# ## Reordering Basis
# We store the wave function as $v[b+1] := \langle b|\psi\rangle$.
# We are able to reorder the basis as
v = onehot(5, 0b11100)  # the product state
@assert reorder(v, (3,2,1,5,4)) ≈ onehot(5, 0b11001)
@assert invorder(v) ≈ onehot(5, 0b00111)  # breflect for each basis

# ## Bit String Representation
# bit strings are literals for bits, it provides better view on binary basis.
# you could use
