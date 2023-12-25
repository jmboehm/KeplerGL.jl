# Example script to display a scatter plot

# Kepler.gl with local js files 

using KeplerGL

using Blink, GeoJSON
using DataFrames, CSV, Colors, ColorBrewer
using Random
using Test

# toggle this to write the new comparison files to disk
write_to_disk = false

function comparewithfile(s::String, file::String)

    f1 = open(file, "r")
    s1 = read(f1, String)
    close(f1)

    s1 = replace(s1, "\r\n" => "\n")
    
    # Character-by-character comparison
    for i=1:length(s1)
        if s1[i]!=s[i]
            println("Character $(i) different: $(s1[i]) $(s[i])")
        end
    end

    if s1 == s
        return true
    else
        return false
        println("Reference output:")
        @show s1
        println("KeplerGL.jl output:")
        @show s
    end
end

token = "mytoken"

# load an existing kepler.gl map (in json form) and show it
m = KeplerGL.KeplerGLMap(token)
KeplerGL.load_map_from_json!(m, "../assets/example_data/earthquakes.kepler.gl.json");
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map1.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map1.html")
# KeplerGL.render(m)


# 2.) point layer 
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
# df = DataFrame(:lat => rand(Float64, 10), :lon => rand(Float64, 10))
latitude = :Latitude
longitude = :Longitude
KeplerGL.add_point_layer!(m, df, latitude, longitude, id = "abc");
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map2.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map2.html")


# 2.b with more attributes
m = KeplerGL.KeplerGLMap(token, center_map=false)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
latitude = :Latitude
longitude = :Longitude
KeplerGL.add_point_layer!(m, df, latitude, longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", id = "abc", 
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
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map2b.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map2b.html")

# # Testing the exporting requires a mapbox token... don't do this at this point
# win = KeplerGL.render(m);
# # Exporting an image
# KeplerGL.export_image(win, "test/earthquakes.png")


m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
latitude = :Latitude
longitude = :Longitude
KeplerGL.add_point_layer!(m, df, latitude, longitude,  id = "abc", 
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    radius_field = :Magnitude,
    radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, 
    outline = true, outline_color = colorant"rgb(255,0,0)", outline_thickness = 2.0);
# KeplerGL.render(m)

m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
latitude = :Latitude
longitude = :Longitude
KeplerGL.add_point_layer!(m, df, latitude, longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize",   id = "abc", 
    radius_field = :Magnitude,
    radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, 
    outline = true, outline_color = colorant"rgb(255,0,0)", outline_thickness = 2.0,
    outline_color_field = :Magnitude,
    outline_color_range = ColorBrewer.palette("Greens", 5), outline_color_scale = "quantile");
# KeplerGL.render(m)


# 3.) Multiple point layers:
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
df2 = copy(df)
rng = MersenneTwister(12345)
df2.Latitude = df2.Latitude .+ (rand(rng, Float64, length(df2.Latitude)) .- 0.5)
df2.Longitude = df2.Longitude .+ 10.0 .* (rand(rng, Float64, length(df2.Longitude)) .- 0.5) 
KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,  id = "abc", 
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    radius_field = :Magnitude,
    radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, 
    outline = false);
KeplerGL.add_point_layer!(m, df2, :Latitude, :Longitude,  id = "def", 
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("BrBG", 10),
    radius_field = :Magnitude,
    radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, 
    outline = false);
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map3.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map3.html")
# win = KeplerGL.render(m)

# 4.) Polygon layer 
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/counties-unemployment.csv", DataFrame)
KeplerGL.add_polygon_layer!(m, df, :_geojson , id = "abc", 
    color = colorant"red", color_field = :unemployment_rate, color_range = ColorBrewer.palette("RdPu", 9))
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map4.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map4.html")    
# win = KeplerGL.render(m)

# more options:
m = KeplerGL.KeplerGLMap(token, center_map=false, read_only=true)
df = CSV.read("../assets/example_data/counties-unemployment.csv", DataFrame)
m.config[:config][:mapState][:latitude] = 50.599316787924764
m.config[:config][:mapState][:longitude] = -115.66724821496788
m.config[:config][:mapState][:zoom] = 2.7356799639938085
KeplerGL.add_polygon_layer!(m, df, :_geojson , id = "abc", 
    color = colorant"red", color_field = :unemployment_rate, color_range = ColorBrewer.palette("RdPu", 9),
    color_scale = "quantile", opacity = 0.8)
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map4b.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map4b.html")   
# win = KeplerGL.render(m)

# 5.) Hexagon layer 
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
KeplerGL.add_hexagon_layer!(m, df, :Latitude, :Longitude,  id = "abc", opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude )
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map5.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map5.html")   
# win = KeplerGL.render(m)

# in 3d:
m = KeplerGL.KeplerGLMap(token, center_map=false)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
KeplerGL.add_hexagon_layer!(m, df, :Latitude, :Longitude,  id = "abc",  opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude, elevation_scale=68.2, height_aggregation = "sum", enable_3d = true  )
m.config[:config][:mapState][:latitude] = 37.47
m.config[:config][:mapState][:longitude] = -121.947
m.config[:config][:mapState][:pitch] = 24.858
m.config[:config][:mapState][:zoom] = 4.892
# win = KeplerGL.render(m)


# 6.) Line layer 
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
df.Latitude1 = df.Latitude .+ (rand(rng, Float64, length(df.Latitude)) .- 0.5)
df.Longitude1 = df.Longitude .+ 10.0 .* (rand(rng, Float64, length(df.Longitude)) .- 0.5) 
KeplerGL.add_line_layer!(m, df, :Latitude, :Longitude, :Latitude1, :Longitude1, id = "abc", 
    opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    color_range = ColorBrewer.palette("BuPu",6), thickness = 3)
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map6.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map6.html")   
# win = KeplerGL.render(m)


# 7.) Arc layer 
m = KeplerGL.KeplerGLMap(token)
m.window[:toggle_3d_show] = true
df = CSV.read("../assets/example_data/data.csv", DataFrame)
df.Latitude1 = df.Latitude .+ (rand(rng, Float64, length(df.Latitude)) .- 0.5)
df.Longitude1 = df.Longitude .+ 10.0 .* (rand(rng, Float64, length(df.Longitude)) .- 0.5) 
KeplerGL.add_arc_layer!(m, df, :Latitude, :Longitude, :Latitude1, :Longitude1,  id = "abc", 
    opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    color_range = ColorBrewer.palette("BuPu",6), thickness = 3)
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map7.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map7.html")
# win = KeplerGL.render(m)


# 8.) Grid layer 
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
KeplerGL.add_grid_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile", id = "abc", 
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude )
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map8.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map8.html")
# win = KeplerGL.render(m)

# 9.) Heatmap layer
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
KeplerGL.add_heatmap_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, weight_field = :Magnitude, weight_scale = "linear", id = "abc", 
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6) )
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map9.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map9.html")
# win = KeplerGL.render(m)

# 10.) Cluster layer
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("../assets/example_data/data.csv", DataFrame)
KeplerGL.add_cluster_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile", id = "abc", 
    radius_range = [1,40], cluster_radius = 20, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "count" )
s = KeplerGL.get_html(m)
# # use this to write the string s to a reference file
if write_to_disk
    f = open("../test/comparison/map10.html", "w")
    write(f, s)
    close(f)
end
@test comparewithfile(s, "../test/comparison/map10.html")
# win = KeplerGL.render(m)
