import GeoJSON

function split(data::Vector{Vector{Float64}}, firstcoordinate::Bool)
    if firstcoordinate
        order = sortperm(data, by=x->x[1])
    else
        order = sortperm(data, by=x->x[2])
    end

    midpoint = Int(ceil(length(order)/2))
    return (order[1:midpoint], order[(midpoint+1):length(order)])
end

function split(data::Vector{Vector{Float64}}, cuts::Int)
    references = Vector{Int64}(undef, length(data))

    for i = 1:length(references)
        references[i] = i
    end

    containers = Vector{Vector{Int64}}(undef, 2^cuts)
    cuts_remaining = Vector{Int64}(undef, 2^cuts)

    containers[1] = references
    cuts_remaining[1] = cuts

    position = 1
    while position <= length(containers)
        if cuts_remaining[position] > 0
            next_position = position + (2^(cuts_remaining[position]-1))
            (containers[position], containers[next_position]) =(
                split(data[containers[position]], cuts_remaining[position]%2 == 0)
            )

            (cuts_remaining[position], cuts_remaining[next_position]) = (
                cuts_remaining[position]-1, cuts_remaining[position]-1
            )
        else
            position += 1
        end
    end

    return containers
end