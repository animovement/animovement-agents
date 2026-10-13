# Analysis workflows

Read this when writing or reviewing an analysis: setting units, choosing what to mask, how far
to fill and how much to smooth, and recipes for common requests. Argument names are given where
a choice hangs on them; confirm the rest on each function's page. The worked example is the
Get Started guides at <https://animovement.dev/get-started/> (read, check, process, measure).

## Units

- **Frame rate**: from the user, the video's own metadata, or the tracker's settings. Never
  assume 30. `set_metadata(sampling_rate = 50)` declares it; `convert_unit_time("s")` turns
  frame numbers into seconds. A wrong rate: `convert_unit_time("frame")`, declare the right
  one (and `source_sampling_rate` if it was the camera's), convert forward again.
- **Scale**: `calibration_factor` is the target unit per current unit: a 400 mm arena spanning
  800 px gives `convert_unit_space("mm", calibration_factor = 400 / 800)`. Measure an object in
  the plane the animal moves in. Between metric units the factor is derived.
- **Angles**: derived angles follow `unit_angle`; `convert_unit_angle("deg")` gives degrees
  throughout.
- **Already right but mislabelled**: `set_metadata(unit_space = "mm")` relabels, no rescaling.
- Unit codes are short: `unit_space` `px`, `nm`, `um`, `mm`, `cm`, `m`, `km`; `unit_time`
  `frame`, `ns`, `us`, `ms`, `s`, `m` (minutes), `h`. `list_default_metadata()` lists them.
- Results are only as right as these two numbers: say what you assumed.

## Check before cleaning

- `check_confidence()`, `check_na_gapsize()`, `check_na_timing()` and, with a skeleton,
  `check_segment_length()` print a summary; `plot()` them to see the distribution.
- Choose the confidence threshold from `plot(check_confidence(x))`. Scores are whatever the
  tool emits (SLEAP's exceed 1), so a threshold from another paper or tool doesn't transfer.
- With many keypoints, check one at a time: `dplyr::filter(x, keypoint == "centre")`.
- Check again after each step: it shows what the step did.

## Mask (`mask_na_across(method = )`)

| Method | Masks | Key arguments |
|---|---|---|
| `"confidence"` | points scored below a threshold | `threshold`; `missing = "mask"` also masks unscored rows (default keeps them) |
| `"roi"` | points outside a region | `x_min`, `x_max`, `y_min`, `y_max`, or `x_center`, `y_center`, `radius` |
| `"range"` | values outside bounds, per column | `min_value`, `max_value`; `on_deltas` for integrated data |
| `"speed"` | jumps too fast to be real | `threshold`, `"auto"` per track |
| `"excursion"` | a point that leaps away and comes back | `outlier_sd`, `return_sd` |
| `"hampel"` | single-frame spikes, against the local median | `window_width`, `k`, `min_distance` |

- Combine criteria: confidence catches what the tracker doubted, `"roi"` and `"speed"` catch
  confident mistakes.
- `mask_na_across()` also blanks `confidence` on the rows it masks.
- `mask_na_segment_length()` takes a whole frame with a skeleton attached and masks the point
  that stretches a segment, such as a mismatched joint in 3D.

## Fill (`replace_na_across(method = , max_gap = )`)

- Always set `max_gap`, in rows: the default fills every gap, inventing movement across long
  absences. At 30 fps, `max_gap = 5` bridges a sixth of a second.
- `"linear"` by default; `"spline"`, `"stine"` for smoother curves; `"locf"`, `"value"`.
- Gaps longer than `max_gap` stay `NA`, and measures skip them; that is correct.

## Smooth (`filter_across(method = )`)

- `"sgolay"` (`window_width`, odd, in rows; `order`) keeps the shape of real movement;
  `"rollmedian"` resists spikes; `"gaussian"`, `"triangular"` are gentle; `"lowpass"`
  (`cutoff_freq`, Hz) and `"kalman"` for more control. Savitzky-Golay, low/high-pass, Kalman
  and one-euro need `sampling_rate`.
- Wider windows smooth more and erase real detail: a window should be shorter than the
  quickest movement of interest.
- `filter_rollmean()` and `filter_rollmedian()` centre their window, so the ends are `NA`.
- Smooth before `add_kinematics()`: differentiating amplifies jitter.

## Measure

- `add_kinematics()` adds `v_*`, `a_*`, `speed`, `acceleration` (signed, along the path) and
  `cumulative_distance`; `turning_speed` and `cumulative_turning` in 2D and 3D; `course` and
  `turning_rate` in 2D, or in 3D given `vertical =` (the axis pointing up in the world). Speed
  is in the frame's spatial unit per unit of the index.
- `min_step` (`"auto"`, from each track's noise) blanks `course` for steps too short to have a
  direction. After smoothing, or for coarse sampling (GPS), set it from the known precision;
  `compute_min_step()` reports what `"auto"` chose.
- `add_tortuosity()` adds windowed `straightness_<w>`, `sinuosity_<w>`, `e_max_<w>`.
- `add_nnd(across = "individual")` adds distance to the nearest other individual
  (`nnd_1_distance`, `nnd_1_individual`); `n = 2` for the second nearest.
- `add_orientation(from = "tailbase", to = "snout", level = "keypoint")` declares `heading`,
  where the body points. 3D needs a third point, `plane`.
- anispace changes frames: `transform_to_egocentric()` (positions relative to the animal),
  `map_to_polar()` and friends, `translate_coords()`, `rotate_coords()`.

## Summarise

- `summarise_aniframe(x)`: per group, the median and MAD of each per-row measure (`measures =
  "mean_sd"` for mean and SD; `cols =` to choose). Angles get circular statistics.
- `summarise_path(x)`: per trajectory, `total_distance`, `net_displacement`, `straightness`,
  `sinuosity`, `e_max`, `total_turning`. Works on positions; no `add_kinematics()` needed.
- **One row per animal** from pose data, where each keypoint is its own trajectory:
  - one keypoint stands for the animal: `x |> dplyr::filter(keypoint == "centre")`, then
    summarise; or
  - derive a point: `add_point(x, across = "keypoint")` appends a `centroid` member per
    individual (`method = "median"` resists a stray keypoint; `include =` picks members), then
    filter to it and summarise.
  - Never `group_by(individual)` over several keypoints: distance and speed then measure the
    jumps between keypoints, and animetric refuses.
- Join the two summaries by the identity columns (`dplyr::left_join()`), or pivot as needed:
  summaries are ordinary tibbles.

## Several recordings

- Read each file and give it its context before combining: `dplyr::mutate(x, trial = 1L)`.
- `dplyr::bind_rows()` returns a plain tibble **without metadata**. Re-cast and re-declare in one
  step, or the units silently revert to the defaults (`frame`, `px`):
  `as_anipoint(combined, variables_when = "trial", metadata = list(sampling_rate = 30,
  unit_time = "s", unit_space = "mm"))`.
- Recordings with different frame rates or scales: convert each to seconds and the same
  spatial unit first.
- `trial`, `session` and `observation` are recognised context keys; the frame is then grouped
  by them too, so tracks never join across recordings.

## Plot

- `plot(x)` draws the trajectories; `plot_trajectory(x)` is the stable function behind it.
  `plot_timeseries(x, variable = "speed")` draws a column against time; `plot_circular(x,
  variable = "course", weight = "speed")` a rose diagram; `plots(p1, p2)` side by side.
- They return ggplot (or patchwork) objects, so `+ ggplot2::labs()` and themes work;
  `theme_animovement()` and the `scale_*_okabeito()` scales are anivis's.
- An anipoint is a tibble: plain ggplot2 works too, with `y` already pointing up.

## Save

- `write_dataset(x, "clean.parquet")` keeps class and metadata; `read_dataset()` restores them.
- CSV for other tools loses the metadata: record units in the file name or a README.
