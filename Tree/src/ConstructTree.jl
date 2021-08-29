"""
The scaffolding node is used while constructing the orthogonal tree.

The value of the scaffolding node is expected to be the smallest value
in the tree contained in node. This is never checked.

The points should be a vector of all points contained in the tree in
node.
"""
struct ScaffoldingNode
    node
    value
    points::Vector{Int64}
    ScaffoldingNode(node::Node, points) = (
        new(node, node.value, points)
    )
    ScaffoldingNode(leaf::Leaf) = (
        new(leaf, leaf.value, leaf.links)
    )
    ScaffoldingNode(node::Node, value::Float64, points::Vector{Int64}) = (
        new(node, value, points)
    )
end

"""
This function combines two scaffolding nodes into a new scaffolding node.

To do this, the contained nodes are merged into a new node, with the left
node as the left subtree and the right node as the right subtree. The new
node will be given the value of the right subtree.

The new scaffolding node will inherit the value from the left subtree. Thus,
the property of keeping the lowest value in the tree as the value of the
scaffolding node.

If combine is done on the first level of the tree, then a subtree based on
the second coordinate should be constructed and attached to the node. Else,
if the combination is done on the second level, then the node will not
have a subtree constructed.
"""
function combine(l::ScaffoldingNode, r::ScaffoldingNode, level::Int64, points::Vector{Vector{Float64}})
    if level == 1
        node = Node(l.node, r.node, r.value, maketree(points, vcat(l.points, r.points), 2))
    else
        node = Node(l.node, r.node, r.value)
    end
    return ScaffoldingNode(node, l.value, vcat(l.points, r.points))
end

"""
"""
function combine(nodes::Vector{ScaffoldingNode}, level, points::Vector{Vector{Float64}})
    new_nodes = Vector{ScaffoldingNode}()

    n = length(nodes)
    num_untouched = 2^ceil(Int, log2(n)) - n
    for i = 1:2:n-num_untouched -1
        push!(new_nodes, combine(nodes[i], nodes[i+1], level, points))
    end

    for i = n-num_untouched +1 : n
        push!(new_nodes, nodes[i])
    end
    return new_nodes
end

"""
"""
function maketree(
    points::Vector{Vector{Float64}},
    point_references::Vector{Int64},
    active_coordinate::Int64
    )::Node
    construction = Vector{ScaffoldingNode}()
    sorted_points = sort(point_references, by=x->points[x][active_coordinate])
    for p in sorted_points
        push!(construction, ScaffoldingNode(Leaf(points[p][active_coordinate], [p])))
    end

    while length(construction) > 1
        if active_coordinate ==1
            println(length(construction))
        end
        construction = combine(construction, active_coordinate, points)
    end

    return construction[1].node
end