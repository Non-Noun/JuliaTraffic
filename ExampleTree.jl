import Pkg
Pkg.activate("Tree")

using Tree
using Profile

randompoints = Vector{Vector{Float64}}()
point_refs = Vector{Int64}()
for i = 1:128000
    push!(randompoints, rand(2))
    push!(point_refs, i)
end

tree = maketree(randompoints, point_refs, 1)
# result = find(tree, 0.2, 0.205)

@time findradius(tree, randompoints[1], 0.1)