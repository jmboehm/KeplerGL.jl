"""
    add_hexagon_layer!(m::KeplerGLMap, table, latitude::Symbol, longitude::Symbol;
        color = colorant"#762A83",
        color_field::Symbol = :null,
        color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
        color_scale = "quantile",
        color_aggregation = "average",
        highlight_color = colorant"#762A83",
        radius = 0.6,
        coverage = 0.95,
        resolution = 8,
        opacity = 1.0,
        height_field::Symbol = :null,
        height_scale = "sqrt",
        height_percentile = [0,100],
        height_aggregation = "average",
        elevation_percentile = [0,100],
        elevation_scale = 5,
        enable_elevation_zoom_factor = true,
        enable_3d = false)

Adds a hexbin layer to the map `m`, drawing data from `table`.
# Required Arguments
- `m::KeplerGLMap`: the map that the layer should be added to
- `table`: a `Tables.jl`-compatible table that contains the data to draw from 
- `latitude::Symbol`: name of the column of `table` that contains the latitude of the points to be aggregated into the hexbin
- `longitude::Symbol`: name of the column of `table` that contains the longitude of the points to be aggregated into the hexbin

# Optional Arguments
- `id = randstring(7)`: the string id of the layer
- `color = colorant"#762A83"`: a `Colors.jl`-compatible color that the hexagons should have (if fixed)
- `color_field::Symbol = :null`: the name of the column of `table` that should be used to color the hexagons
- `color_range`: a vector of `Colors.jl`-compatible colors. Use `colorant"xyz"` to generate.
- `color_scale = "quantize"`: either `"quantize"` or `"quantile"` depending on whether values or quantiles should be used for the color.
- `highlight_color = colorant"#762A83"`: highlight color.
- `radius = 10.0`: fixed radius value of the hexagons on the map
- `coverage = 0.95`: fraction of the hexagon area that should be covered
- `resolution = 8`
- `opacity = 1.0`: opacity of the hexagons, between `0.0` and `1.0`
- `height_field::Symbol = :null`: name of the column of `table` that should be used to determine the height of the hexagons
- `height_scale = "sqrt"`: how `height_field` should be converted into the actual height 
- `height_percentile = [0,100]`:
- `height_aggregation = "average"`:
- `height_range = [0,500]`: range of the height of columns
- `elevation_percentile = [0,100]`:
- `elevation_scale = 5`: scaling factor for the height
- `enable_elevation_zoom_factor = true`
- `enable_3d = false`: nable 3d on the layer  

# Examples
```julia
m = KeplerGL.KeplerGLMap(token)
df = CSV.read("assets/example_data/data.csv", DataFrame)
KeplerGL.add_hexagon_layer!(m, df, :Latitude, :Longitude, opacity = 0.5, color_field = :Magnitude, color_scale = "quantile",
    radius = 20.0, color_range = ColorBrewer.palette("BuPu",6), color_aggregation = "average", coverage = 0.95,
    height_field = :Magnitude )
```
"""
function add_hexagon_layer!(m::KeplerGLMap, table, latitude::Symbol, longitude::Symbol;
    id::String = randstring(7),
    color = colorant"#762A83",
    color_field::Symbol = :null,
    color_range = [colorant"#762A83",colorant"#AF8DC3",colorant"#E7D4E8",colorant"#D9F0D3",colorant"#7FBF7B",colorant"#1B7837"],
    color_scale = "quantile",
    color_aggregation = "average",
    highlight_color = colorant"#762A83",
    radius = 0.6,
    coverage = 0.95,
    resolution = 8,
    opacity = 1.0,
    height_field::Symbol = :null,
    height_scale = "sqrt",
    height_percentile = [0,100],
    height_aggregation = "average",
    height_range = [0,500],
    elevation_percentile = [0,100],
    elevation_scale = 5,
    enable_elevation_zoom_factor = true,
    enable_3d = false
)

    if !Tables.istable(table)
        error("Second argument to add_hexagon_layer! must follow the Tables.jl interface.")
    end

    # prepare the data to be uploaded 
    cols = Tables.columns(table)
    df_to_use = DataFrame(:Latitude => Tables.getcolumn(cols, latitude),
        :Longitude => Tables.getcolumn(cols, longitude))
    if color_field != :null 
        df_to_use[!,:Color] = Tables.getcolumn(cols, color_field)
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

    col = get_rgb_int(color)
    highlight_col = get_rgb_int(highlight_color)

    # config layer code 
    config_layer_code = """
    {
        "id": "$(id)",
        "type": "hexagon",
        "config": {
            "dataId": "$(dataset_id)",
            "label": "Hexagon: $(dataset_id)",
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
                "lng": "Longitude"
            },
            "isVisible": true,
            "visConfig": {
                "opacity": $(opacity),
                "worldUnitSize": "$(radius)",
                "resolution": $(resolution),
                "colorRange": $(color_range_formatted),
                "coverage": $(coverage),
                "sizeRange": [
                    $(height_range[1]),
                    $(height_range[2])
                ],
                "percentile": [
                    $(height_percentile[1]),
                    $(height_percentile[2])
                ],
                "elevationPercentile": [
                    $(elevation_percentile[1]),
                    $(elevation_percentile[2])
                ],
                "elevationScale": $(elevation_scale),
                "enableElevationZoomFactor": $(enable_elevation_zoom_factor),
                "colorAggregation": "$(color_aggregation)",
                "sizeAggregation": "$(height_aggregation)",
                "enable3d": $(enable_3d)
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
                    "alignment": "center",
                    "outlineWidth": 0,
                    "outlineColor": [
                        255,
                        0,
                        0,
                        255
                    ],
                    "background": false,
                    "backgroundColor": [
                        0,
                        0,
                        200,
                        255
                    ]
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
                "name":  $(height_field == :null ? "null" : "\"Height\""),
                "type": "real"
            },
            "sizeScale": "$(height_scale)"
        }
    }
    """

    # add to the map 
    push!(m.datasets, d)
    push!(m.config[:config][:visState][:layers], JSON3.read(config_layer_code))

    return "done"

end