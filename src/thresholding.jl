using Optim

function count_histogram(counts)
    max_counts = 0
    for e in counts
        max_counts = max(max_counts, maximum(e))
    end
    hist = zeros(max_counts + 1)
    for e in counts
        for c in e
            hist[c + 1] += 1
        end
    end
    hist
end

function bipoisson(n, λ0, λ1, bright_ratio)
    if (bright_ratio < 0 || bright_ratio > 1 || λ0 < 0 || λ1 < 0)
        0.0
    else
        (exp(-λ0) * (1 - bright_ratio) * λ0.^n +
            exp(-λ1) * bright_ratio * λ1.^n) ./ gamma(n + 1)
    end
end

function fit_count_histogram(histo)
    ns = collect(0:(length(histo) - 1))
    function negloglike(params)
       -sum(histo .* log(bipoisson(ns, params...)))
    end

    mle = optimize(negloglike, [2.0, 40.0, 0.5])
    mle.minimum
end

function count_threshold(λ0, λ1)
    round(λ1 / log(1 + λ1 / λ0))
end

function apply_threshold(counts, threshold)
    map(c -> count(n -> n >= threshold, c) / length(c), counts)
end

function auto_threshold(shots)
    λ0, λ1, ratio = fit_count_histogram(count_histogram(shots))
    apply_threshold(shots, count_threshold(λ0, λ1))
end
