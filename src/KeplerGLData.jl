"""
    abstract type AbstractKeplerGLData end

Abstract type for datasets.
"""
abstract type AbstractKeplerGLData end

"""
    struct FieldsRowsData <: AbstractKeplerGLData
        id::String
        json::String
    end

Concrete type for [`AbstractKeplerGLData`](@ref), which contains 
data in the fields-rows format that Kepler.gl uses natively. Used for data 
that is loaded from KeplerGL maps in JSON format.
"""
struct FieldsRowsData <: AbstractKeplerGLData
    id::String
    json::String
end

"""
    struct GeoJSONData <: AbstractKeplerGLData
        id::String
        json::String
    end

Concrete type for [`AbstractKeplerGLData`](@ref), which contains 
data in GeoJSON format.
"""
struct GeoJSONData <: AbstractKeplerGLData
    id::String
    json::String
end

"""
    struct CSVData <: AbstractKeplerGLData
        id::String
        csvstring::String
    end

Concrete type for [`AbstractKeplerGLData`](@ref), which contains 
data in CSV format. Used also when bringing data in via a `DataFrame`.
"""
struct CSVData <: AbstractKeplerGLData
    id::String
    csvstring::String
end