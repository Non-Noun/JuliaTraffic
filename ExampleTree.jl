using Profile
include("Tree.jl")

randompoints = Vector{Vector{Float64}}()
for i = 1:128000
    push!(randompoints, rand(2))
end

tree = maketree(randompoints, 1)
# result = find(tree, 0.2, 0.205)

@time findradius(tree, randompoints[1], 0.1)