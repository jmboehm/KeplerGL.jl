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

export KeplerGLMap, make_static_config, render, export_image,
     load_map_from_json!, load_config_from_json!, load_map_from_json,
     add_grid_layer!, add_arc_layer!, add_cluster_layer!, add_h3_layer!, add_heatmap_layer!,
     add_hexagon_layer!, add_icon_layer!, add_line_layer!, add_polygon_layer!, add_trip_layer!

##############################################################################
##
## Load files
##
##############################################################################
include("KeplerGLData.jl")

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
include("layers/icon.jl")
include("layers/h3.jl")
include("layers/trip.jl")

include("export.jl")

end