using KeplerGL
using Documenter, Aqua
using Test

##

#=
ambiguities is tested separately since it defaults to recursive=true
but there are packages that have ambiguities that will cause the test
to fail
=#
Aqua.test_ambiguities(KeplerGL; recursive=false)
Aqua.test_all(KeplerGL; ambiguities=false)
tests = [
    "KeplerGL.jl"
    ]

for test in tests
    println("Testing $test :")
    include(test)
end

DocMeta.setdocmeta!(
    KeplerGL,
    :DocTestSetup,
    quote
        using KeplerGL
    end;
    recursive=true
)

@testset "KeplerGL.jl Documentation" begin
    doctest(KeplerGL)
end