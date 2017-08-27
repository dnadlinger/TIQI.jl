# TIQI

Julia library for working with data saved from Ionizer.

Currently only tested with Julia 0.4-rc3. Documentation is still
lacking, but the function names should be self-explanatory enough
to be a good starting point.

## Basic example

```
# Read an Ionizer 2D scan shots log (also see read_thresholded_2d()).
x_values, y_values, shots = TIQI.read_shots_log_2d("20160215_214604")

# Plot a histogram of the photon counts. Useful to check the expected
# readout error, background counts, repump laser leakage, etc.
count_histo = TIQI.count_histogram(shots)
λ0, λ1, bright_ratio = TIQI.fit_count_histogram(count_histo)
TIQI.plot_histogram_fit(count_histo, λ0, λ1, bright_ratio)

# Compute the optimal threshold assuming that the distribution is made
# up from two Poissonians. auto_threshold() combines this and all the
# previous steps into one function call if you do not want to manually
# introspect the distribution.
threshold = TIQI.count_threshold(λ0, λ1)
thresholded = TIQI.apply_threshold(shots, threshold)

# Plot the thresholded data using PyPlot. After importing that module,
# you can use all the standard matplotlib functions to customise labels,
# axes, etc.
TIQI.plot_01_2d(thresholded, x_values, y_values, "S state population")
```
