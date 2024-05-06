using Documenter
using KeplerGL
using KeplerGLBase

push!(LOAD_PATH,"../src/")

makedocs(
    sitename = "KeplerGL.jl",
    format = Documenter.HTML(),
    modules = [KeplerGL, KeplerGLBase],
    pages = [
        "Introduction" => "index.md",
        "Layers" => "layers.md",
        "Examples" => "examples.md",
        "Type & Function Reference" => "reference.md",
        "Index" => "ind.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/jmboehm/KeplerGL.jl",
    target = "build",
)
