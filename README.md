# KeplerGL.jl

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://jmboehm.github.io/KeplerGL.jl/dev/)
[![Build Status](https://github.com/jmboehm/KeplerGL.jl/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jmboehm/KeplerGL.jl/actions/workflows/ci.yml?query=branch%3Amain)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://github.com/jmboehm/KeplerGL.jl/blob/main/LICENSE)
[![Downloads](https://shields.io/endpoint?url=https://pkgs.genieframework.com/api/v1/badge/KeplerGL&label=Downloads)](https://pkgs.genieframework.com?packages=KeplerGL)

<h3></h3>

<img width="600" alt="Kepler.gl Demo" src="assets/img/earthquakes.png">

Julia package to create, render, and export geospatial maps, using [Kepler.gl](http://kepler.gl), via [Blink.jl](https://github.com/JuliaGizmos/Blink.jl). 

Currently uses version 2.5.5 of Kepler.gl.

## Example

The following code produces the point map above:

```julia
using KeplerGL, Colors, ColorBrewer

token = "<INSERT MAPBOX TOKEN HERE>"

m = KeplerGL.KeplerGLMap(token, center_map=false)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false);
m.config[:config][:mapState][:latitude] = 38.32068477880718
m.config[:config][:mapState][:longitude]= -120.42806781055732
m.config[:config][:mapState][:zoom] = 4.886825331541375
m.window[:map_legend_show] = false
m.window[:map_legend_active] = false
m.window[:visible_layers_show] = false
m.window[:visible_layers_active] = false
win = KeplerGL.render(m);

# Exporting an image
KeplerGL.export_image(win, "assets/img/earthquakes.png")
```

## Layers

At this point the following layers are implemented:

### Point layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false);
w = KeplerGL.render(m);
```

### Polygon layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/counties-unemployment.csv", DataFrame)
KeplerGL.add_polygon_layer!(m, df, :_geojson ,
    color = colorant"red", color_field = :unemployment_rate, color_range = ColorBrewer.palette("RdPu", 9))
w = KeplerGL.render(m)
```

### Hexbin layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_hexagon_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude )
w = KeplerGL.render(m)
```

### Line layer
```julia
using Random
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
rng = MersenneTwister(12345)
df.Latitude1 = df.Latitude .+ (rand(rng, Float64, length(df.Latitude)) .- 0.5)
df.Longitude1 = df.Longitude .+ 10.0 .* (rand(rng, Float64, length(df.Longitude)) .- 0.5) 
KeplerGL.add_line_layer!(m, df, :Latitude, :Longitude, :Latitude1, :Longitude1,
    opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    color_range = ColorBrewer.palette("BuPu",6), thickness = 3)
w = KeplerGL.render(m)
```

### Arc layer
```julia
using Random
m = KeplerGL.KeplerGLMap(token)
m.window[:toggle_3d_show] = true
rng = MersenneTwister(12345)
df = CSV.read("assets/example_data/data.csv", DataFrame)
df.Latitude1 = df.Latitude .+ (rand(rng, Float64, length(df.Latitude)) .- 0.5)
df.Longitude1 = df.Longitude .+ 10.0 .* (rand(rng, Float64, length(df.Longitude)) .- 0.5) 
KeplerGL.add_arc_layer!(m, df, :Latitude, :Longitude, :Latitude1, :Longitude1,  id = "abc", 
    opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    color_range = ColorBrewer.palette("BuPu",6), thickness = 3)
w = KeplerGL.render(m)
```

### Grid layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_grid_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude )
w = KeplerGL.render(m)
```

### Heatmap layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_heatmap_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, weight_field = :Magnitude, weight_scale = "linear",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6) )
w = KeplerGL.render(m)
```

### Cluster layer
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_cluster_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius_range = [1,40], cluster_radius = 20, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "count" )
w = KeplerGL.render(m)
```
