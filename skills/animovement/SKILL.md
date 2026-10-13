---
name: animovement
description: >-
  Use when analysing animal movement or pose-tracking data in R with the
  animovement packages (animovement, anicore, aniread, aniprocess, anicheck,
  animetric, anivis, anispace): reading output from DeepLabCut, SLEAP,
  LightningPose, idtracker.ai, TRex, Anipose, FreeMoCap, TrackMate, Bonsai,
  FicTrac, BORIS, C3D or the movement Python package; anipoints and other
  aniframes; masking low-confidence points, filling gaps and smoothing tracks;
  speed, distance, turning and path summaries in real units; trajectory plots;
  or fixing code that calls read_dataset(), mask_na_*(), add_kinematics() or
  other ani* functions, including old names that no longer run. Not for work on
  the packages themselves (CI, releases, NEWS, pull requests: use
  animovement-dev), nor for R data with no tracking in it.
---

# animovement

A suite of R packages for animal movement and pose data. Each package owns one stage (read,
check, clean, measure, plot), and all pass one structure along: the **anipoint**, a tibble of
positions whose metadata says which columns are identity, time and position, and in what units.
It is one of the **aniframe** classes. `library(animovement)` attaches the seven working
packages; the metapackage itself exports only `animovement_*()` helpers.

Working *on* the packages (CI, releases, `NEWS.md`, commits) is the **animovement-dev** skill.

## Rules

1. **Find out which API is installed.** The 2026-08-28 releases predate a large rename, and
   R-universe and the conda channel build `main`, so a new install gets development versions
   (`0.8.0.9xxx`); animovement.dev documents those. Check `packageVersion("anicore")` or
   `animovement::animovement_sitrep()`, or read `renv.lock`, `pixi.lock` or the error.
   anicore 0.8.0 or older (aniprocess or animetric 0.5.0 or older) has the old names:
   `reference/versions.md` maps them. Can't tell? Write for the development API and say so.
2. **Verify every name before writing it.** The suite was split out of one package in 2025 and
   largely renamed in 2026, so remembered names are often wrong or in another package. Look it
   up (*Verifying*). If you can't fetch the docs or run R, say which names you couldn't check
   and give the user the check, e.g. `args(aniprocess::mask_na_across)`.
3. **Call through the owning package, or attach the suite.** `animovement::read_dataset()`
   fails ("not an exported object"): use `library(animovement)` and bare names, or
   `aniread::read_dataset()`. `library(animovement)` doesn't attach dplyr or ggplot2.
4. **Put real units on the data before measuring.** Video trackers give pixels and frames, most
   with no frame rate, and animetric measures per unit of the index in the frame's spatial
   unit: speeds come out in px/frame unless converted. `set_metadata()` only *declares*
   (`unit_space = "mm"` relabels pixels); `convert_unit_time()` and `convert_unit_space()`
   rescale. Ask for the frame rate and the scale; never guess them.
5. **Mask, then fill, then smooth, and keep every row.** `mask_na_across()` turns untrusted
   points into `NA`, `replace_na_across()` fills gaps of up to `max_gap` rows (its default fills
   every gap), `filter_across()` smooths. `filter_*()` here is signal filtering. Never drop
   low-confidence rows with `dplyr::filter()`: the gaps vanish, can't be filled or seen, and
   speeds jump across them.
6. **Keep one trajectory per group.** A frame stays grouped by identity (`individual`,
   `keypoint`, …) and context (`trial`, `session`), and everything is computed per group;
   speed, distance and path measures refuse groups that pool trajectories. For one row per
   animal, pick a keypoint or derive one (`add_point(across = "keypoint")`), then summarise.
   Never `group_by(individual)` first.
7. **Go through anicore's accessors** (`get_metadata()`, `get_axes()`, `get_index()`,
   `get_keys()`): never `attr(x, "metadata")`, never assume columns named `x`, `y`, `time`.
8. **Treat directions as circular**: `circ_mean()`, `circ_median()` or `summarise_aniframe()`,
   never `mean()`. `course` is where the animal travels; `heading` is where the body faces,
   and exists only once declared (`add_orientation()`). Angles come in the frame's
   `unit_angle`, written in `(-pi, pi]`.
9. **Say which tuning values you chose.** Thresholds, `max_gap`, window widths and `min_step`
   have defaults, none safe for unseen data. Take them from the user or the check plots, and
   state what you assumed.
10. **Install from R-universe, not CRAN**: `repos = c("https://animovement.r-universe.dev",
    "https://cloud.r-project.org")`; update with `animovement_update()`. Pixi:
    `r-animovement` from `https://prefix.dev/animovement`.

## The packages

| Package | Owns | Look for |
|---|---|---|
| **aniread** | Reading tracker output (BORIS gives an anievent), skeletons, writing | `read_dataset()`, `read_<tool>()`, `read_structure()`, `write_dataset()` |
| **anicore** | The classes, metadata, units, column roles, structures, all angle utilities | `get_`/`set_metadata()`, `convert_unit_*()`, `get_`/`set_variables()`, `circ_*()` |
| **anicheck** | Quality reports: check objects, not frames; `plot()` them | `check_confidence()`, `check_na_gapsize()`, `check_na_timing()` |
| **aniprocess** | Masking to `NA`, gap filling, smoothing, peaks | `mask_na_*()`, `replace_na_*()`, `filter_*()`, `find_peaks()` |
| **animetric** | Kinematics, path shape, neighbours, derived points, orientation, summaries | `add_*()` (frame plus columns), `compute_*()` (primitives), `summarise_*()` |
| **anispace** | Coordinate systems, rigid and egocentric transforms, quaternions | `map_to_*()`, `rotate_coords()`, `transform_to_egocentric()`, `quat_*()` |
| **anivis** | Plots, themes, palettes | `plot()`, `plot_trajectory()`, `plot_timeseries()`, `plot_circular()` |
| **animovement** | The metapackage: attaches the seven, manages versions | `animovement_sitrep()`, `animovement_update()` |

`anipoint`, `anisegment`, `anijoint`, `anievent` and `anistructure` are anicore classes, not
packages; the `animovement/anievent` repository (formerly `anisegment`) is an empty placeholder
for planned behaviour segmentation, with nothing to install. A prefix narrows the search but
doesn't settle it: `add_variables()` is anicore's, `add_point()` animetric's. Both spellings
are exported for much of the suite (`summarise_`/`summarize_`), not everywhere. Key exports:
`reference/packages.md`.

## The pipeline

```r
library(animovement)

af <- read_dataset("data/mouse1DLC_resnet50.csv") |>  # aniread: detects the tool
  set_metadata(sampling_rate = 30) |>                 # anicore: declare the frame rate,
  convert_unit_time("s") |>                           #   then frames -> seconds
  convert_unit_space("mm", calibration_factor = 0.4)  #   px -> mm, in mm per px

plot(check_confidence(af))                            # anicheck: choose the threshold here

clean <- af |>
  mask_na_across("confidence", threshold = 0.9) |>    # aniprocess: bad points -> NA
  replace_na_across("linear", max_gap = 5) |>         #   fill gaps of up to 5 rows
  filter_across("sgolay", window_width = 11, order = 3)  # smooth; needs sampling_rate

kin <- add_kinematics(clean)                          # animetric: speed, course, ... columns
summarise_aniframe(kin)                               #   median_speed, ... per group
summarise_path(clean)                                 #   total_distance, straightness, ...
plot(clean)                                           # anivis: trajectories
plot_timeseries(kin, variable = "speed")
```

Every number is a placeholder (rule 9). `summarise_aniframe()` describes the distribution of
per-row measures; `summarise_path()` the geometry of each whole trajectory, one per group. The
`*_across()` verbs read the position columns, index, `sampling_rate` and `confidence` from the
frame; `mask_na_confidence()`, `filter_sgolay()` and the like take vectors, inside `mutate()`.
Choosing each value, and recipes for several recordings, one row per animal, orientation and
saving: `reference/workflows.md`.

## Reading a file

`read_dataset(path)` detects the tool and passes other arguments to its reader. If detection
fails, name `source =` from `get_supported_sources()` (`"idtrackerai"`, not `"idtracker"`).

- DeepLabCut, SLEAP and Lightning Pose give `time` in frames from 0, positions in `px`, and no
  frame rate; other tools vary. Readers of video-based tools flip y to point up, so plots match
  the video: pass `video_height` for an exact flip, and never flip again.
- DeepLabCut CSV or `.h5` (a CSV is detected as `"deeplabcut/lightningpose"`); its skeleton is
  in `config.yaml`: `read_structure()`, then `set_structure()`. SLEAP: the analysis `.h5` or
  CSV, not the `.slp`; the `.h5` brings its skeleton.
- `.h5` needs rhdf5 from Bioconductor: `animovement_install_suggested()`, not
  `install.packages("rhdf5")`.
- Anything else: `read_custom()`, or `as_anipoint()` on a data frame.

Tool by tool, what each reader records and what to add: `reference/readers.md`.

## When something goes wrong

- **`could not find function`**: attached (dplyr separately)? renamed (`reference/versions.md`)?
  real (*Verifying*)? **`not an exported object from 'namespace:animovement'`**: rule 3.
- **Deprecation warning, or `object 'heading' not found`**: the script predates the rename;
  `reference/versions.md`.
- **"Cannot determine the sampling rate"**: `set_metadata(sampling_rate = )`; the
  Savitzky-Golay, Butterworth, Kalman and one-euro filters need it.
- **Implausible speeds or distances**: `get_metadata(x, c("unit_time", "unit_space",
  "sampling_rate"))`, then rule 4. **"This needs one trajectory per group"**: rule 6.
- **A dplyr verb returned a plain tibble**: it dropped a key or the index (`select(x, y)`), or
  rows were combined (`bind_rows()`). Keep those columns, or re-cast with `as_anipoint()` and
  declare the metadata again, which re-casting resets.
- **`there is no package called`**: rule 10; `rhdf5` and `arrow` via
  `animovement_install_suggested()`.

## Verifying

- `https://animovement.dev/<package>/llms.txt` lists every export, grouped, each with a
  one-line description and a link to its page: whether a function exists, and who owns it.
- `https://animovement.dev/<package>/reference/<topic>.md` has the signature and arguments.
  Follow the link from `llms.txt`: the topic isn't always the name (`set_variables()` is on
  `variables.md`).
- **A page that loads doesn't prove the function exists**: removed functions keep their pages
  (`set_unit_space.md`, `mean_angle.md`). `llms.txt` or `NAMESPACE` settles it.
- The site documents `main`. For another install, the installed help wins (`?fn`, `args()`),
  and `NEWS.md` records every rename.

This skill is a map, deliberately incomplete; where it disagrees with `llms.txt` or the
installed package, they are right.

## Reference

- `reference/packages.md`: key exports per package. Read when looking for the function that
  does something.
- `reference/readers.md`: per tool, what the reader returns and what to declare after. Read
  when reading a file.
- `reference/workflows.md`: choosing thresholds, gaps, smoothing and units; recipes. Read when
  writing or reviewing an analysis.
- `reference/aniframe-model.md`: roles, metadata, grouping, structures, other grains. Read when
  declaring or repairing a frame, or using skeletons, segments, joints or events.
- `reference/versions.md`: release versus development, old names to new, silent changes. Read
  when a name is missing, a script uses old names, or results changed.
