"""
    add_arc_layer!(m::KeplerGLMap, table, latitude0::Symbol, longitude0::Symbol, 
        latitude1::Symbol, longitude1::Symbol;
        color = colorant"#762A83",
        color_field::Symbol = :null,
        color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
        color_scale = "quantize",
        highlight_color = colorant"#762A83",
        altitude0::Symbol = :null,
        altitude1::Symbol = :null,
        size_field::Symbol = :null,
        size_range = [1,10],
        size_scale = "linear",
        opacity = 1.0,
        thickness = 2.0,
        elevation_scale = 1)

Adds an arc layer to the map `m`, drawing data from `table`.
# Required Arguments
- `m::KeplerGLMap`: the map that the layer should be added to
- `table`: a `Tables.jl`-compatible table that contains the data to draw from 
- `latitude0::Symbol`: name of the column of `table` that contains the latitude of the origin of the line
- `longitude0::Symbol`: name of the column of `table` that contains the longitude of the origin of the line
- `latitude1::Symbol`: name of the column of `table` that contains the latitude of the endpoint of the line
- `longitude1::Symbol`: name of the column of `table` that contains the longitude of the endpoint of the line


# Optional Arguments
- `id = randstring(7)`: the string id of the layer
- `color = colorant"#762A83"`: a `Colors.jl`-compatible color that the lines should have (if fixed)
- `color_field::Symbol = :null`: the name of the column of `table` that should be used to color the lines
- `color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"]`: a vector of `Colors.jl`-compatible colors. Use `colorant"xyz"` to generate.
- `color_scale = "quantize"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the color.
- `highlight_color = colorant"#762A83"`: highlight color.
- `altitude0::Symbol = :null`: altitude of the origin of the line.
- `altitude1::Symbol = :null`: altitude of the endpoint of the line.
- `size_field::Symbol = :null`: name of the column of `table` that should be used for the line thickness
- `size_range = [1,10]`: thickness range of the lines
- `size_scale = "linear"`: how `size_field` should be converted into the actual line thickness
- `opacity = 1.0`: opacity of the lines
- `thickness = 2.0`: line thickness, if constant
- `elevation_scale = 1`: scaling factor for the altitude.

# Examples
```julia
m = KeplerGL.KeplerGLMap(token, center_map=false)
df = CSV.read("assets/example_data/data.csv", DataFrame)
df.Latitude1 = df.Latitude .+ (rand(rng, Float64, length(df.Latitude)) .- 0.5)
df.Longitude1 = df.Longitude .+ 10.0 .* (rand(rng, Float64, length(df.Longitude)) .- 0.5) 
KeplerGL.add_arc_layer!(m, df, :Latitude, :Longitude, :Latitude1, :Longitude1,
    opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    color_range = ColorBrewer.palette("BuPu",6), thickness = 3)
```
"""
function add_arc_layer!(m::KeplerGLMap, table, latitude0::Symbol, longitude0::Symbol, 
    latitude1::Symbol, longitude1::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantize",
    highlight_color = colorant"#762A83",
    altitude0::Symbol = :null,
    altitude1::Symbol = :null,
    size_field::Symbol = :null,
    size_range = [1,10],
    size_scale = "linear",
    opacity = 1.0,
    thickness = 2.0,
    elevation_scale = 1
)

    if !Tables.istable(table)
        error("Second argument to add_point_layer! must follow the Tables.jl interface.")
    end

    # prepare the data to be uploaded 
    cols = Tables.columns(table)
    df_to_use = DataFrame(:Latitude0 => Tables.getcolumn(cols, latitude0),
        :Longitude0 => Tables.getcolumn(cols, longitude0),
        :Latitude1 => Tables.getcolumn(cols, latitude1),
        :Longitude1 => Tables.getcolumn(cols, longitude1))
    if size_field != :null 
        df_to_use[!,:Size] = Tables.getcolumn(cols, size_field)
    end
    if color_field != :null 
        df_to_use[!,:Color] = Tables.getcolumn(cols, color_field)
    end
    if altitude0 != :null 
        df_to_use[!,:Altitude0] = Tables.getcolumn(cols, altitude0)
    end
    if altitude1 != :null 
        df_to_use[!,:Altitude1] = Tables.getcolumn(cols, altitude1)
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

    col = get_rgb_int(color)
    highlight_col = get_rgb_int(highlight_color)

    # config layer code 
    config_layer_code = """
    {
        "id": "$(id)",
        "type": "arc",
        "config": {
            "dataId": "$(dataset_id)",
            "label": "Line: $(dataset_id)",
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
              "lat0": "Latitude0",
              "lng0": "Longitude0",
              "lat1": "Latitude1",
              "lng1": "Longitude1",
              "alt0": $(altitude0 == :null ? "null" : "\"Altitude0\""),
              "alt1": $(altitude1 == :null ? "null" : "\"Altitude1\"")
            },
            "isVisible": true,
            "visConfig": {
                "opacity": $(opacity),
                "thickness": $(thickness),
                "colorRange": $(color_range_formatted),
                "sizeRange": [
                    $(size_range[1]),
                    $(size_range[2])
                ],
                "targetColor": null,
                "elevationScale": $(elevation_scale)
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
            "sizeField": {
                "name":  $(size_field == :null ? "null" : "\"Size\""),
                "type": "real"
            },
            "sizeScale": "$(size_scale)"
        }
    }
    """

    # add to the map 
    push!(m.datasets, d)
    push!(m.config[:config][:visState][:layers], JSON3.read(config_layer_code))

    return "done"

end