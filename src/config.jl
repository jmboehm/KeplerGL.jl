# function create_config()

# end

# # two presets: 

# # interactive window
# function interactive()

# end

# this returns a minimal config for a static map
function make_static_config()
    t = """
        {
            "version": "v1",
            "config": {
                "visState": {
                    "filters": [
                    ],
                    "layers": [
                    ],
                    "interactionConfig": {
                        "tooltip": {
                            "fieldsToShow": {
                            },
                            "compareMode": false,
                            "compareType": "absolute",
                            "enabled": false
                        },
                        "brush": {
                            "size": 0.5,
                            "enabled": false
                        },
                        "geocoder": {
                            "enabled": false
                        },
                        "coordinate": {
                            "enabled": false
                        }
                    },
                    "layerBlending": "normal",
                    "splitMaps": [],
                    "animationConfig": {
                        "currentTime": null,
                        "speed": 1
                    }
                },
                "mapState": {
                    "bearing": 0,
                    "dragRotate": false,
                    "latitude": 37.05881309947238,
                    "longitude": -122.80009283836715,
                    "pitch": 0,
                    "zoom": 8.0,
                    "isSplit": false
                },
                "mapStyle": {
                    "styleType": "light",
                    "topLayerGroups": {},
                    "visibleLayerGroups": {
                        "border": false,
                        "building": true,
                        "label": true,
                        "land": true,
                        "road": true,
                        "water": true
                    },
                    "threeDBuildingColor": [
                        9.665468314072013,
                        17.18305478057247,
                        31.1442867897876
                    ],
                    "mapStyles": {}
                }
            }
        }
        """
    a = JSON3.read(t)
    return copy(a)
end



