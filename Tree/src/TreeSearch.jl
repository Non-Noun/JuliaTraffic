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



function finlizeorsearch(possiblepoints::Vector{Vector{Float64}}, point, radius)
    for i in reverse(1:length(possiblepoints))
        difference = possiblepoints[i] - point
        distance = difference[1]^2 + difference[2]^2
        if distance > radius
            deleteat!(possiblepoints, i)
        end
    end
end


"""
Finds all points in a given radius around the given point.
"""
function findradius(tree::Node, point::Vector{Float64}, radius::Float64)
    lower = point[1] - radius
    upper = point[1] + radius
    partialresult = find(tree, lower, upper)

    closenodes = Vector{Vector{Float64}}()

    lower = point[2] - radius
    upper = point[2] + radius
    for result in partialresult
        if result isa Node
            secondpoints = find(result, lower, upper)
            for secondpoint in secondpoints
                if distance(secondpoint, point) <= radius^2
                    push!(closenodes, secondpoint)
                end
            end
        else
            if distance(result, point) <=radius^2
                push!(closenodes, result)
            end
        end
    end
    return closenodes
end

function distance(newpoint::Vector{Float64}, point::Vector{Float64})
    difference = newpoint - point
    return difference[1]^2 + difference[2]^2
end