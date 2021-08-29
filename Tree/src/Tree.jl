module Tree

export maketree, find

struct Leaf
    value::Float64
    links::Vector{Int64}
end

struct Node
    left::Union{Node, Leaf}
    right::Union{Node, Leaf}
    value::Float64
    links::Union{Vector{Int64}, Node}
    Node(x::Union{Leaf, Node}, y::Union{Leaf, Node}, value::Float64) = (
        new(x, y, value, vcat(x.links, y.links))
    )
    Node(x::Union{Leaf, Node}, y::Union{Leaf, Node}, value::Float64, subtree::Node) = (
        new(x, y, value, subtree)
    )
end

include("ConstructTree.jl")
include("TreeSearch.jl")

end