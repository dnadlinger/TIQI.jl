using PyPlot

function plot_histogram_fit(histo, λ0, λ1, bright_ratio)
    ns = collect(0:(length(histo) - 1))
    model = sum(histo) * bipoisson(ns, λ0, λ1, bright_ratio)

    figure()
    plot(0:length(histo) - 1, histo, "ro")
    plot(ns, model, "-k")
    axvline(count_threshold(λ0, λ1), color="r", linestyle="dotted")
    xlim(0, length(histo))

    figure()
    semilogy(0:length(histo) - 1, histo, "ro")
    semilogy(ns, model, "-k")
    axvline(count_threshold(λ0, λ1), color="r", linestyle="dotted")
    xlim(0, length(histo))
end

function plot_01_2d_raw(data, xs, ys; diverging=false, ax=nothing)
    if ax == nothing
        ax = gca()
    end

    img = ax[:imshow](data', cmap=(diverging ? "coolwarm" : plasma()),
        origin="lower", interpolation="none", vmin=0, vmax=1, aspect="auto",
        extent=(xs[1], xs[end] + (xs[2] - xs[1]), ys[1], ys[end] + (ys[2] - ys[1])))
    return img
end

function plot_01_2d(data, xs, ys, label=""; diverging=false, ax=nothing)
    img = plot_01_2d_raw(data, xs, ys, diverging=diverging, ax=ax)

    cb = colorbar(img)
    cb[:set_label](label)
    return img, cb
end
