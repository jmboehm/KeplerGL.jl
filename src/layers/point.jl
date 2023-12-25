"""
    add_point_layer!(m, table, latitude::Symbol, longitude::Symbol;
        color = colorant"#762A83",
        color_field::Symbol = :null,
        color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
        color_scale = "quantize",
        highlight_color = colorant"#762A83",
        altitude::Symbol = :null,
        radius = 10.0,
        radius_fixed = true,
        radius_field::Symbol = :null,
        radius_range = [5.0, 15.0],
        radius_scale = "sqrt",    
        filled = true,
        opacity = 1.0,
        outline = false,
        outline_thickness = 2.0,
        outline_color = colorant"#000000",
        outline_color_field::Symbol = :null,
        outline_color_range = [colorant"#FFFFFF", colorant"#000000"],
        outline_color_scale = "quantile")  
Adds a point layer to the map `m`, drawing data from `table`.
# Required Arguments
- `m::KeplerGLMap`: the map that the layer should be added to
- `table`: a `Tables.jl`-compatible table that contains the data to draw from 
- `latitude::Symbol`: name of the column of `table` that contains the latitude of the points
- `longitude::Symbol`: name of the column of `table` that contains the longitude of the points

# Optional Arguments
- `id = randstring(7)`: the string id of the layer
- `color = colorant"#762A83"`: a `Colors.jl`-compatible color that the points should have (if fixed)
- `color_field::Symbol = :null`: the name of the column of `table` that should be used to color the points
- `color_range`: a vector of `Colors.jl`-compatible colors. Use `colorant"xyz"` to generate.
- `color_scale = "quantize"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the color.
- `highlight_color = colorant"#762A83"`: highlight color.
- `altitude::Symbol = :null`: the name of the column of `table` that should be used for the altitude of the points
- `radius = 10.0`: fixed radius value of the points on the map
- `radius_fixed = true`: whether the radius should be fixed or depend on `radius_field` 
- `radius_field::Symbol = :null`: the name of the column of `table` that should be used for the radius of the points
- `radius_range = [5.0, 15.0]`: range of the radii of the points
- `radius_scale = "sqrt"`: how to map `radius_field` into the radius    
- `filled = true`: whether the point markers should be filled or not
- `opacity = 1.0`: opacity of the points, between `0.0` and `1.0`
- `outline = false`: whether the point markers should have an outline
- `outline_thickness = 2.0`: thickness of the outline
- `outline_color = colorant"#000000"`: a `Colors.jl`-compatible color that the point outlines should have (if fixed)
- `outline_color_field::Symbol = :null`: the name of the column of `table` that should be used to color the point outlines
- `outline_color_range = [colorant"#FFFFFF", colorant"#000000"]`: a vector of `Colors.jl`-compatible colors for the outlines. Use `colorant"xyz"` to generate.
- `outline_color_scale = "quantile"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the outline color

# Examples
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_point_layer!(m, df, :Latitude, :Longitude,
    color = colorant"rgb(23,184,190)", color_field = :Magnitude, color_scale = "quantize", 
    color_range = ColorBrewer.palette("PRGn", 6),
    radius_field = :Magnitude, radius_scale = "sqrt", radius_range = [4.2, 96.2], radius_fixed = false,
    filled = true, opacity = 0.39, outline = false);
```
"""
function add_point_layer!(m::KeplerGLMap, table, latitude::Symbol, longitude::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantize",
    highlight_color = colorant"#762A83",
    altitude::Symbol = :null,
    radius = 10.0,
    radius_fixed = true,
    radius_field::Symbol = :null,
    radius_range = [5.0, 15.0],
    radius_scale = "sqrt",    
    filled = true,
    opacity = 1.0,
    outline = false,
    outline_thickness = 2.0,
    outline_color = colorant"#000000",
    outline_color_field::Symbol = :null,
    outline_color_range = [colorant"#FFFFFF", colorant"#000000"],
    outline_color_scale = "quantile"  
)

    if !Tables.istable(table)
        error("Second argument to add_point_layer! must follow the Tables.jl interface.")
    end

    # prepare the data to be uploaded 
    cols = Tables.columns(table)
    df_to_use = DataFrame(:Latitude => Tables.getcolumn(cols, latitude),
        :Longitude => Tables.getcolumn(cols, longitude))
    if radius_field != :null 
        df_to_use[!,:Size] = Tables.getcolumn(cols, radius_field)
    end
    if color_field != :null 
        df_to_use[!,:Color] = Tables.getcolumn(cols, color_field)
    end
    if outline_color_field != :null 
        df_to_use[!,:OutlineColor] = Tables.getcolumn(cols, outline_color_field)
    end
    if altitude != :null 
        df_to_use[!,:Altitude] = Tables.getcolumn(cols, altitude)
    end

    buf = IOBuffer()
    CSV.write(buf, df_to_use)
    data_csv = String(take!(buf))

    # data code 
    dataset_id = "data_layer_$(id)"
    d = CSVData(dataset_id, data_csv)

    color_range_formatted = """{
                "name": "Custom Palette",
                "type": "custom",
                "category": "Custom",
                "colors": $(string.("#",Colors.hex.(color_range)))
              }
    """
    outline_color_range_formatted = """{
                "name": "Custom Palette",
                "type": "custom",
                "category": "Custom",
                "colors": $(string.("#",Colors.hex.(outline_color_range)))
            }
    """

    col = get_rgb_int(color)
    highlight_col = get_rgb_int(highlight_color)
    outline_col = get_rgb_int(outline_color)

    # config layer code 
    config_layer_code = """
    {
        "id": "$(id)",
        "type": "point",
        "config": {
            "dataId": "$(dataset_id)",
            "label": "Point: $(dataset_id)",
            "color": [
                $(col[1]),
                $(col[2]),
                $(col[3])
            ],
            "highlightColor": [
                $(highlight_col[1]),
                $(highlight_col[2]),
                $(highlight_col[3]),
                255
            ],
            "columns": {
                "lat": "Latitude",
                "lng": "Longitude",
                "altitude": $(altitude == :null ? "null" : "\"Altitude\"")
            },
            "isVisible": true,
            "visConfig": {
                "radius": $(radius),
                "fixedRadius": $(radius_fixed),
                "opacity": $(opacity),
                "outline": $(outline),
                "thickness": $(outline_thickness),
                "strokeColor": [
                    $(outline_col[1]),
                    $(outline_col[2]),
                    $(outline_col[3])
                ],
                "colorRange": $(color_range_formatted),
                "strokeColorRange": $(outline_color_range_formatted),
                "radiusRange": [
                    $(radius_range[1]),
                    $(radius_range[2])
                ],
                "filled": $(filled)
            },
            "hidden": false,
            "textLabel": [
                {
                    "field": null,
                    "color": [
                        255,
                        255,
                        255
                    ],
                    "size": 18,
                    "offset": [
                        0,
                        0
                    ],
                    "anchor": "start",
                    "alignment": "center"
                }
            ]
        },
        "visualChannels": {
            "colorField": {
                "name": $(color_field == :null ? "null" : "\"Color\""),
                "type": "real"
            },
            "colorScale": "$(color_scale)",
            "strokeColorField": {
                "name": $(outline_color_field == :null ? "null" : "\"OutlineColor\""),
                "type": "real"
            },
            "strokeColorScale": "$(outline_color_scale)",
            "sizeField": {
                "name":  $(radius_field == :null ? "null" : "\"Size\""),
                "type": "real"
            },
            "sizeScale": "$(radius_scale)"
        }
    }
    """

    # add to the map 
    push!(m.datasets, d)
    push!(m.config[:config][:visState][:layers], JSON3.read(config_layer_code))

    return "done"

end