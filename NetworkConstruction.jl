
"""Loops through the data and splits into 2^levels rectangles
"""
function splitdata(data::Vector{Vector{Float64}}, levels::Int64)
    point_references = Vector{Int64}()
    for i in 1:length(data)
        push!(point_references, i)
    end

    containers = Vector{Vector{Int64}}()
    for i = 1:2^levels
        push!(containers, Vector{Int64}())
    end
    containers[1] = point_references

    levelvector = [1 for i = 1:length(containers)]
    levelvector[1] = levels+1
    index = 1
    while index <= length(containers)
        index = splitnext!(containers, data, levelvector, index)
    end

    return containers
end

"""Splits the current container, if it has levels left. Otherwise, the
index is incremented instead.
"""
function splitnext!(
    containers::Vector{Vector{Int64}},
    data::Vector{Vector{Float64}},
    levels::Vector{Int64},
    index::Int64
    )::Int64

    if levels[index] > 1
        rightpos = 2^(levels[index]-2) + index
        (l,r) = split(data[containers[index]], levels[index]%2+1)
        containers[index] = l
        containers[rightpos] = r
        levels[rightpos] = levels[index]-1
        levels[index] = levels[index]-1
    end

    if levels[index] == 1
        return index + 1
    else
        return index
    end
end

"""Splits the provided data by returning the indicies of the upper and
lower half separately.
"""
function split(
    data::Vector{Vector{Float64}},
    index::Int64
    )::Tuple{Vector{Int64}, Vector{Int64}}

    order = sortperm(data, by=x->x[index])
    midpoint = Int(floor(length(order)/2))
    return (order[1:midpoint], order[(midpoint+1):length(order)])
end