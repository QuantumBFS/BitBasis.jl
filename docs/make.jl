using Documenter, BitBasis
import BitBasis

# preprocess tutorial scripts
using Literate, Pkg
tutorialpath = joinpath(@__DIR__, "src")
for jlfile in ["tutorial.jl"]
    Literate.markdown(joinpath(tutorialpath, jlfile), tutorialpath)
end

const PAGES = [
    "Home" => "index.md",
    "Tutorial" => "tutorial.md",
    "Manual" => "man.md",
]

makedocs(
    modules = [BitBasis],
    format = Documenter.HTML(
        prettyurls = ("deploy" in ARGS),
        canonical = ("deploy" in ARGS) ? "https://quantumbfs.github.io/BitBasis.jl/latest/" : nothing,
    ),
    assets = ["assets/favicon.ico"],
    clean = false,
    sitename = "BitBasis.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = PAGES
)

deploydocs(
    repo = "github.com/QuantumBFS/BitBasis.jl.git",
    target = "build",
)
