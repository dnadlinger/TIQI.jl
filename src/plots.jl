using PyPlot

function plot_histogram_fit(histo, λ0, λ1, bright_ratio)
    ns = [0:(length(histo) - 1)]
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

function plot_01_2d(data, xs, ys, label="")
    img = imshow(data', cmap=parula(), origin="lower", interpolation="none",
        vmin=0, vmax=1, aspect="auto", extent=(xs[1], xs[end], ys[1], ys[end]))
    cb = colorbar()
    cb[:set_label](label)
    return img, cb
end
