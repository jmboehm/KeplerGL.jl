# KeplerGL.jl

The package provides functions for displaying and exporting interactive maps through the Javascript package [Kepler.gl](https://kepler.gl/), which is being loaded in Julia through [Blink.jl](https://github.com/JuliaGizmos/Blink.jl). 

The version of Kepler.gl that is currently used is 2.5.5.

## Table of Contents

```@contents
Pages = ["index.md", "layers.md", "examples.md", "reference.md", "ind.md"]
Depth = 3
```

## Installation

To install the package, type in the Julia command prompt

```
] add https://github.com/jmboehm/KeplerGL.jl
```

The package will be registered in Julia's `General` registry once it's a bit more mature.

## Support policy

The development of the package is done in the author's spare time. I try to fix bugs as I have time and as they are reported on the [Github issue tracker](https://github.com/jmboehm/KeplerGL.jl/issues). The package isn't particularly complicated, and I'm happy to review and merge pull requests for both bug fixes and new features. Please don't email me about the package.

## Package philosophy

There are several excellent options for plotting maps using Julia (including [GeoMakie.jl](https://github.com/MakieOrg/GeoMakie.jl) and [Tyler.jl](https://github.com/MakieOrg/Tyler.jl)).

The main motivation behind creating this package is to tap into [Kepler.gl](https://kepler.gl/)'s ease of use and bring it to scientific applications. Kepler.gl is excellent for creating beautiful maps interactively, but the resulting maps are difficult to integrate into a scientific workflow, which requires the maps to be created from code in order to be reproducible. This package aims to fill this gap.

Some principles I had in mind when creating the package:
- Provide code interfaces for the creation of map layers with all options that Kepler.gl itself supports. 
- The way maps are stored internally follows the same structure as Kepler.gl's [JSON format](https://docs.kepler.gl/docs/user-guides/k-save-and-export#export-map-as-json), this makes for easy saving and loading.
- The keyword arguments in the layer functions should be named as close as possible to the layer options that Kepler.gl uses internally, except when ambiguous.

## Roadmap

1. Finish support for all layer types implemented in Kepler.gl.
2. Filters, tooltips, legends, base maps
2. More and better data import options
3. More and better map export options
4. Update to Kepler.gl 3.0

Things that could be added, but are not currently planned, are:
- Compatibility with other [WebIO](https://github.com/JuliaGizmos/WebIO.jl) backends
- Compatibility with [GeoInterface.jl](https://github.com/JuliaGeo/GeoInterface.jl)
- Compatibility with different [tile providers](https://github.com/JuliaGeo/TileProviders.jl)
- Functions to generate KeplerGL.jl map creation code from an open map window

