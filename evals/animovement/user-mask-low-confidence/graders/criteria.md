---
type: llm
---

PASS if the cleaning does all three, in this order:

1. Masks the points with likelihood below 0.9 to `NA` while keeping their rows: `mask_na_across("confidence", threshold = 0.9)`, or `mask_na_confidence()` or `mask_na_with()` inside `mutate()`.
2. Fills gaps of up to 10 frames, such as `replace_na_across("linear", max_gap = 10)`, or another `replace_na_*()` method with `max_gap = 10`.
3. Smooths after filling, with any `filter_across()` method or `filter_*()` function. If the smoother is Savitzky-Golay, low-pass, high-pass, Kalman or one-euro, the 50 fps rate is declared first, with `set_metadata(sampling_rate = 50)` (converting time to seconds afterwards is fine) or by passing `sampling_rate = 50`.

Extra steps are fine, such as a region-of-interest or speed mask, or a `check_confidence()` before and after.

FAIL if it removes the low-likelihood rows with `dplyr::filter()` or subsetting instead of masking them; fills gaps without a `max_gap` (which fills every gap), or gives `max_gap` in seconds; smooths before masking; uses the deprecated `filter_na_across()` or `filter_na_confidence()`, or the removed `set_sampling_rate()`; or applies a Savitzky-Golay, low-pass, high-pass, Kalman or one-euro filter without declaring the sampling rate.
