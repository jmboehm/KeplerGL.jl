"""
    render(map::KeplerGLMap)

Renders a `KeplerGLMap` in a new `Blink.jl` window and returns this window.

# Required Arguments
- `m::KeplerGLMap`: the map that should be rendered
"""
function render(map::KeplerGLMap; blink_options=Dict())

    dispatch_code = KeplerGLBase.make_dispatch_code(map)
    map_html = KeplerGLBase.make_html(map, dispatch_code)

    blink_options = merge(
        Dict(
            "width" => map.window[:width], "height" => map.window[:height], "title" => "KeplerGL.jl",
            "useContentSize" => true # whether the width/height will we use as the canvas size (instead of win size)
        ),
        blink_options
    )

    w = Window(blink_options, async=false)
    assetpath = dirname(dirname(pathof(KeplerGLBase)))
    load!(w, joinpath(assetpath, "assets", "js", "react.production.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "react-dom.production.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "redux.js"))
    load!(w, joinpath(assetpath, "assets", "js", "react-redux.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "styled-components.min.js"))
    load!(w, joinpath(assetpath, "assets", "js", "keplergl.min.js"))

    body!(w, map_html, async=false);

    return w

end