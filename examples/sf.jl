# This example is a bit bigger. We're going to download the building footprints 
# of San Francisco and visualize them.

using KeplerGL
using Colors
using CSV, DataFrames
using ColorBrewer
using Downloads

# note that this is about 200mb, so may take a while
sf_url = "https://data.sfgov.org/api/views/ynuv-fyni/rows.csv?accessType=DOWNLOAD"

http_response = Downloads.download(sf_url);
df = CSV.File(http_response) |> DataFrame

# token = ....
m = KeplerGL.KeplerGLMap(token, center_map=false)
# Switch on 3d, but hide button
m.window[:toggle_3d_show] = false
m.window[:toggle_3d_active] = true

KeplerGL.add_polygon_layer!(m, df, :shape;
    color_range = parse.(Colorant, ["#194266","#194266","#194266","#355C7D","#355C7D","#63617F","#916681","#C06C84","#D28389","#F8B195"]),
    color_field = :hgt_meancm, color_scale = "quantile", opacity = 0.38, 
    height_field = :hgt_meancm, height_scale = "linear",
    enable_3d = true, elevation_scale = 1.0, filled = true, outline = false)

# disable map legend
m.window[:map_legend_show]=false
# disable the labels on the map
m.config[:config][:mapStyle][:visibleLayerGroups][:label]=false
# use a dark basemap
m.config[:config][:mapStyle][:styleType]="dark"

# set camera 
m.config[:config][:mapState][:latitude] = 37.774483242431074
m.config[:config][:mapState][:longitude]= -122.40122776087189
m.config[:config][:mapState][:zoom] = 13.744271777357321
m.config[:config][:mapState][:pitch] = 54.106924511460385
m.config[:config][:mapState][:bearing] = -124.5053380782918
m.config[:config][:mapState][:dragRotate] = true

w = KeplerGL.render(m);

KeplerGL.export_image(w, "sf.png")