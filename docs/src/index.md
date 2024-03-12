```@meta
DocTestSetup = quote
    using BitBasis, Dates
end
```

# BitBasis

Manipulate binary (and nary) basis in an elegant efficient way in Julia.

```@eval
using Markdown, Dates
Markdown.parse("*Documentation built* **$(Dates.now())** *with Julia* **$(VERSION)**")
```

## Introduction

This package provides tools for manipulating binary basis in an elegant efficient way in Julia. Binary basis are used to represent states of spins, qubits, qudits, etc. It stores the basis as an integer with little-endian ordering, e.g `5` for `00101`, `6` for `00110`, etc.

## Contents
```@contents
Pages = [
    "tutorial.md",
    "man.md",
]
```
