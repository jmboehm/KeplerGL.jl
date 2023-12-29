"""
    mutable struct KeplerGLMap 
        datasets::Vector{AbstractKeplerGLData}
        config::Dict{Symbol, Any}
        info::Dict{Symbol, Any}
        window::Dict{Symbol, Any}
    end

Type that contains all the information to render a map. 
`config` and `info` are of the same structure as the map JSON 
serialization that Kepler.gl uses internally. `datasets` are instances of
[`AbstractKeplerGLData`](@ref) that contain the data that the layers draw from. 
`window` is additional information not used by Kepler.gl that contains information
on window size, whether the map should be centered, and so on. 
""" 
mutable struct KeplerGLMap 
    datasets::Vector{AbstractKeplerGLData}
    config::Dict{Symbol, Any}
    info::Dict{Symbol, Any}
    window::Dict{Symbol, Any}
end

"""
    KeplerGLMap(token::String;
        width::Int64 = 1200,
        height::Int64 = 900,
        center_map = true,
        read_only = false,
        config = KeplerGL.make_static_config())

Creates a new `KeplerGLMap`.

# Required Arguments
- `token::String`: the mapbox token to be used for displaying the map.

# Optional Arguments
- `width:Int64 = 1200`: width of the map window
- `height:Int64 = 900`: height of the map window
- `center_map - true`: whether the map should automatically be centered
- `read_only = false`: whether the map should be read-only (not editable)
- `config = KeplerGL.make_static_config()`: initial configuration
"""
function KeplerGLMap(token::String;
    width::Int64 = 1200,
    height::Int64 = 900,
    center_map = true,
    read_only = false,
    config = KeplerGL.make_static_config())

    info = Dict(:app => "KeplerGL.jl", 
        :description => "", 
        :created_at  => Dates.format(Dates.now(),"e u d yyyy HH:MM:SS", locale="english"),
        :title => "keplergl_$(randstring(6))",
        :source => "KeplerGL.jl")

    window = Dict(:token => token,
        :width => width,
        :height => height,
        :read_only => read_only,
        :center_map => center_map,
        :visible_layers_show => true,
        :visible_layers_active => true,
        :map_legend_show => true,
        :map_legend_active => true,
        :toggle_3d_show => false,
        :toggle_3d_active => false,
        :split_map_show => false,
        :split_map_active => false
        )

    return KeplerGLMap(Vector{Dict{Symbol, Any}}(), config, info, window)
end

"""
    get_html(m::KeplerGLMap)

Gets the html + js code to render the map in Blink

# Required Arguments
- `m::KeplerGLMap`: the map to get the HTML code for.
"""
function get_html(m::KeplerGLMap)
    dispatch_code = make_dispatch_code(m)
    return make_html(m, dispatch_code)
end

"""
    load_map_from_json!(m::KeplerGLMap, json_map_file::String)

Loads a kepler.gl map file from `json_map_file` into the map `m`.
Overwrites any existing map config and datasets.

# Required Arguments
- `m::KeplerGLMap`: the map to which the config and data should be applied.
- `json_map_file::String`: the path to the kepler.gl JSON map file.
"""
function load_map_from_json!(m::KeplerGLMap, json_map_file::String)

    mapjson = copy(JSON3.read(json_map_file))
    try
        m.config = mapjson[:config]
        m.info = mapjson[:info]
        m.datasets = []

        # add the datasets as FieldsRowsData
        for d in mapjson[:datasets]
            dat = KeplerGL.FieldsRowsData(d[:data][:id], JSON3.write(d))
            push!(m.datasets, dat)
        end
    catch ex
        if isa(ex,KeyError)
            error("Error loading map from json. Make sure the map json has valid :datasets, :config, and :info entries.")
        else 
            throw(ex)
        end
    end

    # only copy over the window information if it's present
    if haskey(mapjson, :window)
        m.window = mapjson[:window]
    end

    return m
end

"""
    load_map_from_json(token::String, json_map_file::String)

Returns a `KeplerGLMap` whose data and config has been loaded from `json_map_file`.

# Required Arguments
- `token::String`: mapbox token to use with the map.
- `json_map_file::String`: the path to the Kepler.gl map JSON file which should be loaded.
"""
function load_map_from_json(token::String, json_map_file::String)
    m = KeplerGLMap(token)
    load_map_from_json!(m, json_map_file)
    return m
end

"""
    load_config_from_json!(m::KeplerGLMap, json_map_file::String)

Loads the config from a json file `json_map_file` and applies it to the map `m`.

# Required Arguments
- `m::KeplerGLMap`: the map to which the config should be applied.
- `json_map_file::String`: the path to the JSON file from which the config should be loaded.
"""
function load_config_from_json!(m::KeplerGLMap, json_map_file::String)

    mapjson = read(json_map_file, String)
    
    try 
        m.config = mapjson[:config]
    catch ex 
        if isa(ex,KeyError)
            error("Error loading map config from json. Make sure the json has a valid :config entry.")
        end
    end

    return m
end

"""
    get_json(m::KeplerGLMap)

Returns the map in JSON format, which is also the format which Kepler.gl uses 
intrinsically to save map files.

# Required Arguments
- `m::KeplerGLMap`: the map of which the JSON code should be returned.
"""
function get_json(m::KeplerGLMap)
    j = Dict{Symbol, Any}(
        :config => m.config,
        :info => m.info,
        :window => m.window
    )
     # :datasets => m.datasets,
    return JSON3.write(j)
end

"""
    make_dispatch_code(m::KeplerGLMap)

This function makes the dispatch code for `m`. It is called by [`render()`](@ref) 
but is sometimes also useful to call directly for debugging purposes

# Required Arguments
- `m::KeplerGLMap`: the map of which the dispatch code should be returned.
"""
function make_dispatch_code(m::KeplerGLMap)

    dispatchcode = "" 

    for d in m.datasets
        n = generate_process_string(m, d)
        dispatchcode = string(dispatchcode, "\n", n)
    end

    start = """
        let newDatasets = [];
    """

    loadcode = """

        const configstring = `$(JSON3.write(m.config))`

        const config = JSON.parse(configstring);

        const loadedData = keplerGl.KeplerGlSchema.load(
            newDatasets,
            config
        );

        loadedData['options'] = {centerMap: $(m.window[:center_map]), readOnly: $(m.window[:read_only])};

        store.dispatch(keplerGl.addDataToMap(loadedData));
    """

    return string(start, "\n", dispatchcode, "\n", loadcode)
end

function make_initial_state(m::KeplerGLMap)
    return """keplerGl.keplerGlReducer.initialState({
            uiState: {
                readOnly: $(m.window[:read_only]),
                activeSidePanel: null, 
                currentModal: null,
                mapControls: {
                    visibleLayers: {
                        show: $(m.window[:visible_layers_show]),
                        active: $(m.window[:visible_layers_active])
                    },
                    mapLegend: {
                        show: $(m.window[:map_legend_show]),
                        active: $(m.window[:map_legend_active])
                    },
                    toggle3d: {
                        show: $(m.window[:toggle_3d_show]),
                        active: $(m.window[:toggle_3d_active])
                    },
                    splitMap: {
                        show: $(m.window[:split_map_show]),
                        active: $(m.window[:split_map_active])
                    }
                }
            }
        })
    """
end

function make_html(m::KeplerGLMap, dispatch_code::String)
    return """
        <div id="app">
            <!-- Kepler.gl map will be placed here-->
        </div>

        <!-- Load our React component. -->
        <script>
            /* Validate Mapbox Token */
            MAPBOX_TOKEN = '$(m.window[:token])';
            if ((MAPBOX_TOKEN || '') === '' || MAPBOX_TOKEN === 'PROVIDE_MAPBOX_TOKEN') {
            alert(WARNING_MESSAGE);
            }

            /** STORE **/

            const reducers = (function createReducers(redux, keplerGl) {
            return redux.combineReducers({
                // mount keplerGl reducer
                keplerGl: $(make_initial_state(m))
            });
            }(Redux, KeplerGl));

            const middleWares = (function createMiddlewares(keplerGl) {
            return keplerGl.enhanceReduxMiddleware([
                // Add other middlewares here
            ]);
            }(KeplerGl));

            const enhancers = (function createEnhancers(redux, middles) {
            return redux.applyMiddleware(...middles);
            }(Redux, middleWares));

            const store = (function createStore(redux, enhancers) {
            const initialState = {};

            return redux.createStore(
                reducers,
                initialState,
                redux.compose(enhancers)
            );
            }(Redux, enhancers));
            // expose store globally:
            window.store = store;
            /** END STORE **/

            /** COMPONENTS **/
            const KeplerElement = (function (react, keplerGl, mapboxToken) {
            return function(props) {
                return react.createElement(
                'div',
                {style: {position: 'absolute', left: 0, width: '100vw', height: '100vh'}},
                react.createElement(
                    keplerGl.KeplerGl,
                    {
                        mapboxApiAccessToken: mapboxToken,
                        id: 'app',
                        width: props.width || $(m.window[:width]),
                        height: props.height || $(m.window[:height])
                    }
                )
                )
            }
            }(React, KeplerGl, MAPBOX_TOKEN));

            const app = (function createReactReduxProvider(react, reactRedux, KeplerElement) {
            return react.createElement(
                reactRedux.Provider,
                {store},
                react.createElement(KeplerElement, null)
            )
            }(React, ReactRedux, KeplerElement));
            /** END COMPONENTS **/

            /** Render **/
            (function render(react, reactDOM, app) {
                reactDOM.render(app, document.getElementById('app'));
            }(React, ReactDOM, app));

            (function customize(keplerGl, store) {

                $(dispatch_code)
            
            }(KeplerGl, store))
        </script>
    """

end


"""
    render(map::KeplerGLMap)

Renders a `KeplerGLMap` in a new `Blink.jl` window and returns this window.

# Required Arguments
- `m::KeplerGLMap`: the map that should be rendered
"""
function render(map::KeplerGLMap)

    dispatch_code = make_dispatch_code(map)
    map_html = make_html(map, dispatch_code)

    blink_options = Dict("width" => map.window[:width], "height" => map.window[:height], "title" => "KeplerGL.jl", 
        "useContentSize" => true # whether the width/height will we use as the canvas size (instead of win size)
    )

    w = Window(blink_options, async=false)
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "react.production.min.js"))
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "react-dom.production.min.js"))
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "redux.js"))
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "react-redux.min.js"))
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "styled-components.min.js"))
    load!(w, joinpath(dirname(@__FILE__), "..", "assets", "js", "keplergl.min.js"))

    # load!(w, "assets/js/react.production.min.js")
    # load!(w, "assets/js/react-dom.production.min.js")
    # load!(w, "assets/js/redux.js")
    # load!(w, "assets/js/react-redux.min.js")
    # load!(w, "assets/js/styled-components.min.js")
    # load!(w, "assets/js/keplergl.min.js")

    body!(w, map_html, async=false);

    return w

end

"""
    hide_buttons!(m::KeplerGLMap)

Hides all buttons (legend, 3d, etc) on the top right corner of a `KeplerGLMap`

# Required Arguments
- `m::KeplerGLMap`: the map that should be affected
"""
function hide_buttons!(m::KeplerGLMap)
    m.window[:map_legend_show] = false
    m.window[:visible_layers_show] = false
    m.window[:split_map_show] = false
    m.window[:toggle_3d_show] = false
end

"""
    hide_legend!(m::KeplerGLMap)

Hides the legend on the top right corner of a `KeplerGLMap`

# Required Arguments
- `m::KeplerGLMap`: the map that should be affected
"""
function hide_legend!(m::KeplerGLMap)
    m.window[:map_legend_show]=false
end