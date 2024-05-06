# Example script to display a scatter plot

# Kepler.gl with local js files 

using KeplerGL

using Blink
using Test

token = ENV["MAPBOX_KEY"]

# load an existing kepler.gl map (in json form) and show it
m = KeplerGL.KeplerGLMap(token)

example_dir = joinpath(Base.pkgdir(KeplerGLBase), "assets", "example_data")
KeplerGL.load_map_from_json!(m, joinpath(example_dir, "earthquakes.kepler.gl.json"));


# # Testing the exporting requires a mapbox token... don't do this at this point
win = KeplerGL.render(m, show=false);
# # Exporting an image
wait(win.inittask)
mktempdir() do tmpdir
    KeplerGL.export_image(win, joinpath(tmpdir, "earthquakes.png"))
    @test isfile(joinpath(tmpdir, "earthquakes.png"))
end
close(win)
