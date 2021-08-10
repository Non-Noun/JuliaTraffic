struct Leaf
    value::Float64
    links::Vector{Vector{Float64}}
end

struct Node
    left::Union{Node, Leaf}
    right::Union{Node, Leaf}
    value::Float64
    links::Union{Vector{Vector{Float64}}, Node}
    Node(x::Union{Leaf, Node}, y::Union{Leaf, Node}, value::Float64) = (
        new(x, y, value, vcat(x.links, y.links))
    )
    Node(x::Union{Leaf, Node}, y::Union{Leaf, Node}, value::Float64, subtree::Node) = (
        new(x, y, value, subtree)
    )
end

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
    points::Vector{Vector{Float64}}
    ScaffoldingNode(node::Node, points) = (
        new(node, node.value, points)
    )
    ScaffoldingNode(leaf::Leaf) = (
        new(leaf, leaf.value, leaf.links)
    )
    ScaffoldingNode(node::Node, value::Float64, points::Vector{Vector{Float64}}) = (
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
function combine(l::ScaffoldingNode, r::ScaffoldingNode, level::Int64)
    if level == 1
        node = Node(l.node, r.node, r.value, maketree(vcat(l.points, r.points), 2))
    else
        node = Node(l.node, r.node, r.value)
    end
    return ScaffoldingNode(node, l.value, vcat(l.points, r.points))
end


function find(tree::Node, key::Float64)
    if key < tree.value
        return find(tree.left, key)
    else
        return find(tree.right, key)
    end
end

"""
Returns the points with coordinate between keylower and keyupper.

The search in the tree is done by first looking if keylower is bigger than
the value of the node, and move into the right tree. Or if keyupper is
smaller than the value of the node, and then search in the left subtree.

If either keylower is smaller than or keyupper is bigger than the value,
then call rindright and findleft to get the points.
"""
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

"""
Returns the points greater than keylower from the tree. Can also return
an empty Vector{Float64}, if no such points exist.

If keylower is bigger than the value of the current node, then another
search is done on the right subtree. Because, if the value is smaller
than keylower, then the value must (if it exists) must be in the
right tree.

If keylower is smaller than the value in the current node, then the
left subtree will be searched further. In addition, this also means
that all points in the right subtree should be returned.
"""
function findleft(tree::Node, keylower::Float64)
    if keylower < tree.value
        return vcat(findleft(tree.left, keylower), tree.right.links)
    end

    if keylower >= tree.value
        return findleft(tree.right, keylower)
    end
end

"""
Returns the points stored in the leaves, if keylower is smaller than
the value of the leaf.

Otherwise, an empty Vector{Float64} is returned.
"""
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

function combine(nodes::Vector{ScaffoldingNode}, level)
    new_nodes = Vector{ScaffoldingNode}()

    n = length(nodes)
    num_untouched = 2^ceil(Int, log2(n)) - n
    for i = 1:2:n-num_untouched -1
        push!(new_nodes, combine(nodes[i], nodes[i+1], level))
    end

    for i = n-num_untouched +1 : n
        push!(new_nodes, nodes[i])
    end
    return new_nodes
end

function maketree(points::Vector{Vector{Float64}}, coordinate::Int64)
    construction = Vector{ScaffoldingNode}()
    sort!(points, by=x->x[coordinate])
    for p in points
        push!(construction, ScaffoldingNode(Leaf(p[coordinate], [p])))
    end

    while length(construction) > 1
        if coordinate ==1
            println(length(construction))
        end
        construction = combine(construction, coordinate)
    end

    return construction[1].node
end

function finlizeorsearch(possiblepoints::Vector{Vector{Float64}}, point, radius)
    for i in reverse(1:length(possiblepoints))
        difference = possiblepoints[i] - point
        distance = difference[1]^2 + difference[2]^2
        if distance > radius
            deleteat!(possiblepoints, i)
        end
    end
end

function finalizeorsearch(node::Node, point::Vector{Vector{Float64}}, radius::Float64)
    find()
end

function findradius(tree::Node, point::Vector{Vector{Float64}}, radius::Float64)
    lower = point[1] - radius
    upper = point[1] + radius
    partialresult = find(tree, lower, upper)

    closenodes = Vector{Vector{Float64}}()

    lower = point[2] - radius
    upper = point[2] + radius
    for result in partialresult
        if result isa Node
            secondpoints = find(result, lower, upper)
            for secondpoint in seconpoints
                if distance(secondpoint, point) <= radius^2
                    push!(closenodes, secondpoints)
                end
            end
        else
            for secondpoint in result
                if distance(secondpoint, point) <=radius^2
                    push!(closenodes, secondpoint)
                end
            end
        end
    end
    return closenodes
end

function distance(newpoint::Vector{Vector{Float64}}, point::Vector{Vector{Float64}})
    difference = newpoint - point
    return difference[1]^2 + difference[2]^2
end

using Profile

randompoints = Vector{Vector{Float64}}()
for i = 1:128000
    push!(randompoints, rand(2))
end

tree = maketree(randompoints, 1)
@time find(tree, 0.2, 0.205)