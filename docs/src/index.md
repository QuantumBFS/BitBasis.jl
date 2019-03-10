```@meta
DocTestSetup = quote
    using BitBasis, Dates
end
```

# BitBasis

Types and operations for basis represented by bits in linear algebra.

```@eval
using Markdown, Dates
Markdown.parse("*Documentation built* **$(Dates.now())** *with Julia* **$(VERSION)**")
```

## Introduction

The basis of linear spaces can be marked by a set of symbols, for concrete physical systems, this can be binary spins, bits, qubits, etc. They can be in general represented as binary basis, e.g `00101`, `10101`....

This package provides tools for manipulating such basis in an elegant efficient way in Julia.


## Documentation
```@contents
Pages = [
    "tutorial.md",
    "man.md",
]
Depth = 1
```
