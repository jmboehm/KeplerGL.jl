"""
    add_polygon_layer!(m::KeplerGLMap, table, geojson::Symbol;
        color = colorant"#762A83",
        color_field::Symbol = :null,
        color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
        color_scale = "quantize",
        highlight_color = colorant"#762A83",
        filled = true,
        opacity = 1.0,
        outline = false,
        outline_opacity = 1.0,
        outline_thickness = 2.0,
        outline_color = colorant"#000000",
        outline_color_field::Symbol = :null,
        outline_color_range = [colorant"#FFFFFF", colorant"#000000"],
        outline_color_scale = "quantile",
        outline_width_field::Symbol = :null,
        outline_width_scale = "linear",
        height_field::Symbol = :null,
        height_scale = "linear",
        elevation_scale = 1.0,
        enable_elevation_zoom_factor = true,
        enable_3d = false)  

Adds a polygon layer to the map `m`, drawing data from `table`.
# Required Arguments
- `m::KeplerGLMap`: the map that the layer should be added to
- `table`: a `Tables.jl`-compatible table that contains the data to draw from 
- `geojson::Symbo`: name of the column of `table` that contains the feature in GeoJSON format

# Optional Arguments
- `id = randstring(7)`: the string id of the layer
- `color = colorant"#762A83"`: a `Colors.jl`-compatible color that the shapes should have (if fixed)
- `color_field::Symbol = :null`: the name of the column of `table` that should be used to color the shapes
- `color_range`: a vector of `Colors.jl`-compatible colors. Use `colorant"xyz"` to generate.
- `color_scale = "quantize"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the color.
- `highlight_color = colorant"#762A83"`: highlight color.
- `filled = true`: whether the polygon is filled or not.
- `opacity = 1.0`: opacity of the points, between `0.0` and `1.0`
- `outline = false`: whether the point markers should have an outline
- `outline_thickness = 2.0`: thickness of the outline
- `outline_color = colorant"#000000"`: a `Colors.jl`-compatible color that the point outlines should have (if fixed)
- `outline_color_field::Symbol = :null`: the name of the column of `table` that should be used to color the point outlines
- `outline_color_range = [colorant"#FFFFFF", colorant"#000000"]`: a vector of `Colors.jl`-compatible colors for the outlines. Use `colorant"xyz"` to generate.
- `outline_color_scale = "quantile"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the outline color
- `outline_width_field::Symbol = :null`: name of the column of `table` that should be used to determine the width of the polygon outline
- `outline_width_scale = "linear"`: how the values in `outline_width_field` should be converted into the with of the outline
- `height_field::Symbol = :null`: name of the column of `table` that should be used to determine the height of the feature
- `height_scale = "linear"`: how `height_field` should be converted into the actual height 
- `elevation_scale = 1.0`: scaling factor for the height
- `enable_elevation_zoom_factor = true`
- `enable_3d = false`: enable 3d on the layer  

# Examples
```julia
m = KeplerGL.KeplerGLMap(token, center_map=false, read_only=true)
df = CSV.read("assets/example_data/counties-unemployment.csv", DataFrame)
KeplerGL.add_polygon_layer!(m, df, :_geojson ,
    color = colorant"red", color_field = :unemployment_rate, color_range = ColorBrewer.palette("RdPu", 9),
    color_scale = "quantile", opacity = 0.8)
```
"""
function add_polygon_layer!(
    m::KeplerGLMap, table, geojson::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantize",
    highlight_color = colorant"#762A83",
    filled = true,
    opacity = 1.0,
    outline = false,
    outline_opacity = 1.0,
    outline_thickness = 2.0,
    outline_color = colorant"#000000",
    outline_color_field::Symbol = :null,
    outline_color_range = [colorant"#FFFFFF", colorant"#000000"],
    outline_color_scale = "quantile",
    outline_width_field::Symbol = :null,
    outline_width_scale = "linear",
    height_field::Symbol = :null,
    height_scale = "linear",
    elevation_scale = 1.0,
    enable_elevation_zoom_factor = true,
    enable_3d = false
    
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
    if outline_color_field != :null 
        df_to_use[!,:OutlineColor] = Tables.getcolumn(cols, outline_color_field)
    end
    if outline_width_field != :null 
        df_to_use[!,:OutlineWidth] = Tables.getcolumn(cols, outline_width_field)
    end
    if height_field != :null 
        df_to_use[!,:Height] = Tables.getcolumn(cols, height_field)
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
        "type": "geojson",
        "config": {
            "dataId": "$(dataset_id)",
            "label": "Polygon: $(dataset_id)",
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
                "strokeOpacity": $(outline_opacity),
                "thickness": $(outline_thickness),
                "strokeColor": [
                    $(outline_col[1]),
                    $(outline_col[2]),
                    $(outline_col[3])
                ],
                "colorRange": $(color_range_formatted),
                "strokeColorRange": $(outline_color_range_formatted),
                "radius": 10,
                "sizeRange": [
                    0,
                    10
                ],
                "radiusRange": [
                    0,
                    50
                ],
                "heightRange": [
                    0,
                    500
                ],
                "elevationScale": $(elevation_scale),
                "enableElevationZoomFactor": $(enable_elevation_zoom_factor),
                "stroked": $(outline),
                "filled": $(filled),
                "enable3d": $(enable_3d),
                "wireframe": false
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
                "name":  $(outline_width_field == :null ? "null" : "\"OutlineWidth\""),
                "type": "real"
            },
            "sizeScale": "$(outline_width_scale)",
            "heightField": {
              "name": $(height_field == :null ? "null" : "\"Height\""),
              "type": "real"
            },
            "heightScale": "$(height_scale)"
        }
    }
    """

    # add to the map 
    push!(m.datasets, d)
    push!(m.config[:config][:visState][:layers], JSON3.read(config_layer_code))

    return "done"

end