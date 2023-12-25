
function get_rgb_int(c)
    return [round(Int64, red(c)*255),round(Int64, green(c)*255),round(Int64, blue(c)*255)]
end

function rand_color()
    return rand(0:255, 3)
end
function rand_color(n::Int64)
    return rand(0:255, n)
end
