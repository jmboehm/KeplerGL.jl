module KeplerGL

##############################################################################
##
## Dependencies
##
##############################################################################

using Tables, Colors

import Colors, GeoJSON, JSON3, UUIDs
using WebIO, Blink
using CSV
using Dates
using Random
using DataFrames
using Base64

##############################################################################
##
## Exported methods and types
##
##############################################################################

export KeplerGLMap, make_static_config #, load_map_from_json!, show

##############################################################################
##
## Load files
##
##############################################################################
include("KeplerGLData.jl")

# include("layer.jl")
# include("layers/PointLayer.jl")

include("config.jl")
include("map.jl")
include("data.jl")

include("util.jl")

include("layers/point.jl")
include("layers/polygon.jl")
include("layers/hexagon.jl")
include("layers/grid.jl")
include("layers/line.jl")
include("layers/arc.jl")
include("layers/heatmap.jl")
include("layers/cluster.jl")


include("export.jl")

end