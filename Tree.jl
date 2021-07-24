struct Leaf
    value::Float64
    links::Vector{Float64}
end

struct Node
    left::Union{Node, Leaf}
    right::Union{Node, Leaf}
    value::Float64
    links::Vector{Float64}
    Node(x::Union{Leaf, Node}, y::Union{Leaf, Node}, value::Float64) = (
        new(x, y, value, vcat(x.links, y.links))
    )
end

struct ScaffoldingNode
    node
    value
    ScaffoldingNode(node::Node) = (
        new(node, node.value)
    )
    ScaffoldingNode(leaf::Leaf) = (
        new(leaf, leaf.value)
    )
    ScaffoldingNode(node::Node, value::Float64) = (
        new(node, value)
    )
end

function combine(l::ScaffoldingNode, r::ScaffoldingNode)
    node = Node(l.node, r.node, r.value)
    return ScaffoldingNode(node, l.value)
end

function find(tree::Node, key::Float64)
    if key < tree.value
        return find(tree.left, key)
    else
        return find(tree.right, key)
    end
end

function find(tree::Node, keylower::Float64, keyupper::Float64)
    if keylower >= tree.value
        return find(tree.right, keyupper, keylower)
    end

    if keyupper < tree.value
        return find(tree.left, keyupper, keylower)
    end

    return vcat(findleft(tree.left, keylower), findright(tree.right, keyupper))
end

function find(leaf::Leaf, keylower::Float64, keyupper::Float64)
    return leaf.links
end

function findleft(tree::Node, keylower::Float64)
    if keylower < tree.value
        return vcat(findleft(tree.left, keylower), tree.right.links)
    end

    if keylower >= tree.value
        return findleft(tree.right, keylower)
    end
end

function findleft(leaf::Leaf, keylower::Float64)
    if keylower < leaf.value
        return leaf.links
    end

    return Vector{Float64}()
end

function findright(tree::Node, keyupper::Float64)
    if keyupper >= tree.value
        return vcat(tree.left.links, findright(tree.right, keyupper))
    end

    if keyupper < tree.value
        return findright(tree.left, keyupper)
    end
end

function findright(leaf::Leaf, keyupper::Float64)
    if leaf.value <= keyupper
        return leaf.links
    end

    return Vector{Float64}()
end

function transformpoints(points::Vector{Float64})
    sortedpoints = sort(points)
    middles = Vector{Float64}(undef, length(points)-1)
    for i = 1:(length(points)-1)
        middles[i] = (sortedpoints[i+1] + sortedpoints[i])/2
    end
    return (middles, sortedpoints)
end

function combine(nodes::Vector{ScaffoldingNode})
    new_nodes = Vector{ScaffoldingNode}()

    n = length(nodes)
    num_untouched = 2^ceil(Int, log2(n)) - n
    for i = 1:2:n-num_untouched -1
        push!(new_nodes, combine(nodes[i], nodes[i+1]))
    end

    for i = n-num_untouched +1 : n
        push!(new_nodes, nodes[i])
    end
    return new_nodes
end

function maketree(points::Vector{Float64})
    construction = Vector{ScaffoldingNode}()
    for p in points
        push!(construction, ScaffoldingNode(Leaf(p, [p])))
    end

    while length(construction) > 1
        construction = combine(construction)
    end

    return construction[1].node
end

using Profile

randompoints = sort(rand(128000))

tree = maketree(randompoints)
@time find(tree, 0.2, 0.8)