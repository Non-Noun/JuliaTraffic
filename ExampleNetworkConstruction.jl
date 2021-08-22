include("NetworkConstruction.jl")

data = Vector{Vector{Float64}}()
for i in 1:1000
    newvec = [rand(), rand()]
    push!(data, newvec)
end
rectangles = splitdata(data, 3)

for r in rectangles
    println(length(r))
end