using PyPlot

function plot_histogram_fit(histo, λ0, λ1, bright_ratio)
    ns = collect(0:(length(histo) - 1))
    model = sum(histo) * bipoisson(ns, λ0, λ1, bright_ratio)

    figure()
    plot(0:length(histo) - 1, histo, "ro")
    plot(ns, model, "-k")
    axvline(count_threshold(λ0, λ1), color="r", linestyle="dotted")
    xlim(-length(histo) / 100.0, length(histo))

    figure()
    relative_histo = histo ./ sum(histo)
    semilogy(0:length(histo) - 1, relative_histo, "ro")
    semilogy(ns, model ./ sum(histo), "-k")
    axvline(count_threshold(λ0, λ1), color="r", linestyle="dotted")
    xlim(-length(histo) / 100.0, length(histo))
end

function plot_01_2d_raw(data, xs, ys; diverging=false, ax=nothing, min=0, max=1)
    if ax == nothing
        ax = gca()
    end

    x_offset = (xs[2] - xs[1]) / 2
    corner_xs = [xs - x_offset; xs[end] + x_offset]

    y_offset = (ys[2] - ys[1]) / 2
    corner_ys = [ys - y_offset; ys[end] + y_offset]

    img = ax[:pcolormesh](corner_xs, corner_ys, data', cmap=(diverging ? "coolwarm" : plasma()), vmin=min, vmax=max)
    ax[:set_xlim](corner_xs[1], corner_xs[end])
    ax[:set_ylim](corner_ys[1], corner_ys[end])
    return img
end

function plot_01_2d(data, xs, ys, label=""; diverging=false, ax=nothing, min=0, max=1)
    img = plot_01_2d_raw(data, xs, ys, diverging=diverging, ax=ax, min=min, max=max)

    cb = colorbar(img, aspect=30)
    cb[:set_label](label)
    return img, cb
end
