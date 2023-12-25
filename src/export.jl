"""
    export_image(window,filename; 
        width = 1000, height = 800,
        imageDataUri = "data:image/png;base64,2i3u")

Exports an image from `window` to `filename` of the format specified by `imageDataUri`. 

# Required Arguments
- `window`: the window whose current state should be exported. This is returned by [`render()`](@ref).
- `filename`: path to the file to be saved.
- `width`: width of the exported image, in pixels.
- `height`: height of the exported image, in pixels.
- `imageDataUri = "data:image/png;base64,2i3u"`: export image data uri.
"""
function export_image(window,filename; 
    width = 1000, height = 800,
    imageDataUri = "data:image/png;base64,2i3u")

    runjs = """
        (function screenshot(keplerGl, store) {

            keplerGl.setExportImageSetting({exporting: true, processing: true});

            store.dispatch(keplerGl.setExportImageSetting({
            exporting: true, 
            processing: true,
            mapW: 1000,
            mapH: 800,
            imageSize: {
                imageH: $height,
                imageW: $width,
                scale: 1
            },
            legend: false
            }));

            store.dispatch(keplerGl.setExportImageDataUri('$imageDataUri'));

            store.dispatch(keplerGl.startExportingImage());

        }(KeplerGl, store))
    """

    js(window, Blink.JSString(runjs))

    # retrieve image data. Because of JS being asynchronous this can take a bit of time.
    img_base64 = ""
    for i=1:50    
        img_base64 = js(window,Blink.JSString("""window.store.getState().keplerGl.app.uiState.exportImage.imageDataUri"""))

        if isempty(img_base64) & i==10
            error("Error exporting image.")
        elseif isempty(img_base64)
            sleep(0.1)
        else
            @info "Export successful."
            break
        end
    end

    # write image to file
    img = Base64.base64decode(img_base64[23:end])
    write(filename, img)

end