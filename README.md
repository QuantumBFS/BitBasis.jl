# BitBasis

[![Build Status](https://travis-ci.com/QuantumBFS/BitBasis.jl.svg?branch=master)](https://travis-ci.com/QuantumBFS/BitBasis.jl)
[![Codecov](https://codecov.io/gh/QuantumBFS/BitBasis.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/QuantumBFS/BitBasis.jl)
[![Coveralls](https://coveralls.io/repos/github/QuantumBFS/BitBasis.jl/badge.svg?branch=master)](https://coveralls.io/github/QuantumBFS/BitBasis.jl?branch=master)

Types and operations for basis represented by bits in linear algebra.

## Installation

Type `]` and enter package mode:

```julia
pkg> add BitBasis
```

## Usage

This package provides basic utilities to manipulate binary basis for linear algebra
objects, and a string literal `bit"` to make it easier to input a basis, e.g

```julia
julia> bit"101" * 2
1010 (10)

julia> bcat(bit"101" for i in 1:10)
101101101101101101101101101101 (766958445)

julia> repeat(bit"101", 2)
101101 (45)

julia> bit"1101"[2]
0
```

Other features including the following:

- `reorder(X, orders)`: Reorder `X` according to `orders`.
- `invorder(X)`: Inverse the order of given vector/matrix `X`.
- `basis(x)`: Returns the UnitRange for basis in Hilbert Space of num_bits qubits.
- `bfloat(b::Integer; nbit::Int=bit_length(b))`: float view, with big end qubit 1.
- etc.

Please read the [documentation]() for more info.

## License

Apache License 2.0
