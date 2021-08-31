include("SplitData.jl")

geodata = GeoJSON.read(read("data/vasterbotten.geojson"))

coordinates = Vector{Vector{Float64}}()

for feature in geodata.features
    for coordinate in feature.geometry.coordinates[1]
        push!(coordinates, coordinate)
    end
end

split(coordinates, 3)