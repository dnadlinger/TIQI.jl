function raw_to_counts(raw)
    x_values = convert(Array{Float64}, unique(sort(raw[:, 2])))

    shots = Array(Array{UInt32, 1}, length(x_values))
    for i in 1:length(x_values)
        shots[i] = UInt32[]
    end

    for i in 1:(size(raw)[1])
        x_index = searchsorted(x_values, raw[i, 2])[1]
        for val in raw[i, 4:end]
            if val == ""
                break
            end

            counts = convert(UInt32, val)
            if counts & (1 << 31) != 0
                continue
            end

            push!(shots[x_index], counts)
        end
    end

    x_values, shots
end

function last_complete_row_2d(raw, y_column)
    lines_per_y = 0
    for (i, y) in enumerate(slice(raw, :, y_column))
        if y != raw[1, y_column]
            lines_per_y = i - 1
            break
        end
    end

    row_count = size(raw)[1]
    if lines_per_y == 0
       lines_per_y = row_count
    end

    if row_count % lines_per_y == 0
        return row_count, lines_per_y
    end

    for (i, y) in enumerate(slice(raw, row_count:-1:1, y_column))
        if y != raw[row_count, y_column]
            current = row_count + 1 - i
            return current, lines_per_y
        end
    end

    error("Dataset has only one y value, cannot determine whether it is complete.")
end

function raw_to_counts_2d(raw, lines_per_y::Int64)
    @assert(size(raw)[1] % lines_per_y == 0, "Inconsistent number of measurements per iterator value")

    y_values = convert(Array{Float64}, sort(raw[1:lines_per_y:end, 3]))
    x_values = convert(Array{Float64}, unique(sortrows(slice(raw, 1:lines_per_y, 1:2))[:, 2]))

    shots = Array(Array{UInt32, 1}, length(x_values), length(y_values))
    for j in 1:length(y_values)
        for i in 1:length(x_values)
            shots[i, j] = UInt32[]
        end
    end

    for i in 1:(size(raw)[1])
        x_index = searchsorted(x_values, raw[i, 2])[1]
        y_index = searchsorted(y_values, raw[i, 3])[1]
        for val in raw[i, 5:end]
            if val == ""
                break
            end

            counts = convert(UInt32, val)
            if counts & (1 << 31) != 0
                continue
            end

            push!(shots[x_index, y_index], counts)
        end
    end

    x_values, y_values, shots
end

function walk_match(dir, prefix, suffix)
    if isempty(dir)
        dir = "."
    end
    entries = readdir(dir)
    for e in entries
        if !startswith(e, prefix)
            continue
        end

        path = joinpath(dir, e)
        if endswith(path, suffix)
            return path
        end

        # Recurse into child directories.
        if isdir(path)
            p = walk_match(path, "", suffix)
            if !isempty(p)
                return p
            end
        end
    end
    return ""
end

function find_file(datapath, suffix)
    if endswith(datapath, suffix)
        return datapath
    end

    dirname, start = splitdir(datapath)
    path = walk_match(dirname, start, suffix)
    if isempty(path)
        error("No file found in '$datapath' ending in '$suffix'.")
    end
    return path
end

function read_shots_log(datapath)
    raw_to_counts(readcsv(find_file(datapath, "_shots_log.txt")))
end

function read_shots_log_2d(datapath; y_reversed=false)
    data = readcsv(find_file(datapath, "_2D_shots_log.txt"))
    last_row, lines_per_y = last_complete_row_2d(data, 3)

    if y_reversed
        clipped_data = data[last_row:-1:1, :]
    else
        clipped_data = data[1:last_row, :]
    end

    raw_to_counts_2d(clipped_data, lines_per_y)
end

function read_thresholded_2d(datapath)
    # Read in file, skipping header line
    data = readcsv(find_file(datapath, "_plot_0.csv"))[2:end, :]

    last_row, lines_per_y = last_complete_row_2d(data, 2)

    y_values = convert(Array{Float64}, sort(data[1:lines_per_y:end, 2]))
    x_values = convert(Array{Float64}, unique(sort(data[1:lines_per_y, 1])))

    signal = zeros(Float64, length(x_values), length(y_values))
    for i in 1:(size(data)[1])
        x_index = searchsorted(x_values, data[i, 1])[1]
        y_index = searchsorted(y_values, data[i, 2])[1]
        signal[x_index, y_index] += data[i, 3]
    end

    signal ./= (lines_per_y / length(x_values))

    x_values, y_values, signal
end
