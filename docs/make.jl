
using BitBasis
using Documenter
using DocThemeIndigo

indigo = DocThemeIndigo.install(BitBasis)

makedocs(
    modules = [BitBasis],
    repo = "https://github.com/QuantumBFS/BitBasis.jl/blob/{commit}{path}#{line}",
    format = Documenter.HTML(
        prettyurls = ("deploy" in ARGS),
        canonical = "https://quantumbfs.github.io/BitBasis.jl/dev/",
        assets = String[indigo, "assets/favicon.ico"],
    ),
    sitename = "BitBasis.jl",
    linkcheck = !("skiplinks" in ARGS),
    pages = ["Home" => "index.md", "Tutorial" => "tutorial.md", "Manual" => "man.md"],
)

deploydocs(repo = "github.com/QuantumBFS/BitBasis.jl.git")
