"""
    add_trip_layer!(m::KeplerGLMap, table, geojson::Symbol;
    m::KeplerGLMap, table, geojson::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantize",
    highlight_color = colorant"#762A83",
    trail_length = 180,
    opacity = 1.0,
    outline_thickness = 2.0,
    outline_width_field::Symbol = :null,
    outline_width_scale = "linear",
    outline_width_range = [0,10])

Adds a polygon layer to the map `m`, drawing data from `table`.
# Required Arguments
- `m::KeplerGLMap`: the map that the layer should be added to
- `table`: a `Tables.jl`-compatible table that contains the data to draw from 
- `geojson::Symbo`: name of the column of `table` that contains the trip in GeoJSON format (as `LineString`, see [here](https://docs.kepler.gl/docs/user-guides/c-types-of-layers/k-trip))

# Optional Arguments
- `id = randstring(7)`: the string id of the layer
- `color = colorant"#762A83"`: a `Colors.jl`-compatible color that the shapes should have (if fixed)
- `color_field::Symbol = :null`: the name of the column of `table` that should be used to color the shapes
- `color_range`: a vector of `Colors.jl`-compatible colors. Use `colorant"xyz"` to generate.
- `color_scale = "quantize"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the color.
- `highlight_color = colorant"#762A83"`: highlight color.
- `trail_length = 180`: number of seconds it takes for the path to fade out.
- `opacity = 1.0`: opacity of the points, between `0.0` and `1.0`
- `outline_thickness = 2.0`: thickness of the outline
- `outline_width_field::Symbol = :null`: name of the column of `table` that should be used to determine the width of the polygon outline
- `outline_width_scale = "linear"`: how the values in `outline_width_field` should be converted into the with of the outline

!!! note

    The trip layer is showing a dynamic visualization of the trips, so exporting the map as 
    a static image is not very meaningful.

# Examples
```julia
using JSON3
t = JSON3.read("assets/example_data/trip_example.geojson")
df = DataFrame(:geometry => string.(t[:features]))
m = KeplerGL.KeplerGLMap(token)
KeplerGL.add_trip_layer!(m, df, :geometry ,
    id = "abc", color = colorant"red")
KeplerGL.render(m)
```
"""
function add_trip_layer!(
    m::KeplerGLMap, table, geojson::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantize",
    highlight_color = colorant"#762A83",
    trail_length = 180,
    opacity = 1.0,
    outline_thickness = 2.0,
    outline_width_field::Symbol = :null,
    outline_width_scale = "linear",
    outline_width_range = [0,10]  
)

    if !Tables.istable(table)
        error("Second argument to add_polygon_layer! must follow the Tables.jl interface.")
    end

    # prepare the data to be uploaded 
    cols = Tables.columns(table)
    df_to_use = DataFrame(:geojson => Tables.getcolumn(cols, geojson))
    if color_field != :null 
        df_to_use[!,:Color] = Tables.getcolumn(cols, color_field)
    end
    if outline_width_field != :null 
        df_to_use[!,:OutlineWidth] = Tables.getcolumn(cols, outline_width_field)
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
        "type": "trip",
        "config": {
            "dataId": "$(dataset_id)",
            "label": "Trip: $(dataset_id)",
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
                "geojson": "geojson"
            },
            "isVisible": true,
            "visConfig": {
                "opacity": $(opacity),
                "thickness": $(outline_thickness),
                "colorRange": $(color_range_formatted),
                "trailLength": $(trail_length),
                "sizeRange": [
                    $(outline_width_range[1]),
                    $(outline_width_range[2])
                ]
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
                "name":  $(outline_width_field == :null ? "null" : "\"OutlineWidth\""),
                "type": "real"
            },
            "sizeScale": "$(outline_width_scale)"
        }
    }
    """

    # add to the map 
    push!(m.datasets, d)
    push!(m.config[:config][:visState][:layers], JSON3.read(config_layer_code))

    return "done"

end