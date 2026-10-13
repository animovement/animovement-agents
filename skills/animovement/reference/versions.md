# Versions, renames and silent changes

Read this when a function is missing or deprecated, a script was written against an older
install, the user's versions are releases rather than development builds, or re-running an
analysis gives different numbers. `NEWS.md` in each package is the full record; this is the map.

## Release or development?

| Package | Latest release (2026-08-28) | Development builds |
|---|---|---|
| anicore | 0.8.0 | 0.8.0.9xxx |
| aniread | 0.7.0 | 0.7.0.9xxx |
| aniprocess | 0.5.0 | 0.5.0.9xxx |
| animetric | 0.5.0 | 0.5.0.9xxx |
| anivis | 0.2.1 | 0.2.1.9xxx |
| anicheck | 0.3.0 | 0.3.0.9xxx |
| anispace | 0.3.0 | 0.3.0.9xxx |
| animovement | 0.8.0 | 0.8.0.9xxx |

- R-universe builds each package's `main`, and the conda packages on prefix.dev are built from
  R-universe, so installing now gives development builds. animovement.dev documents `main` too.
- The release numbers are git tags. Someone who installed around the release, or pinned it in
  `renv.lock` or `pixi.lock`, has the API in the left-hand column of the tables below.
- Development builds differ from each other as well: most renames landed in late September and
  early October 2026. When a name is missing from a `.9xxx` install, look for it in the
  installed `NEWS.md` (`news(package = "aniprocess")`), or update.
- `animovement_sitrep()` lists the installed versions; `animovement_update()` prints the
  command that updates them (in a Pixi project, `pixi update`).
- Updating or rewriting is the user's call: an analysis being reproduced may need its versions
  kept. Either way, use one API throughout a script.

A deprecated function still runs, warns, and returns what it did before its replacement
arrived, old column names included; it is removed after the next release. A removed function
fails with `could not find function`.

## Old name → new name (2026-08-28 releases → development)

### anicore

| Release | Development |
|---|---|
| `aniframe()`, `as_aniframe()`, `example_aniframe()`, `validate_aniframe()` for positions | `anipoint()`, `as_anipoint()`, `example_anipoint()`, `validate_anipoint()`. The old names are soft-deprecated aliases; `aniframe` is now the parent class |
| `is_aniframe()` to test for positions | `is_anipoint()`. `is_aniframe()` is now true for every frame, an anievent included |
| `get_`/`set_`/`add_`/`remove_variables_what()` (`_when`, `_where`, `_event`), `set_axes()` | `get_variables()`, `set_variables()`, `add_variables()`, `remove_variables()`, by role and slot; the grouping columns are `get_keys()`. Removed |
| `set_unit_space(x, "mm", calibration_factor)`, `set_unit_time()`, `set_unit_angle()` | `convert_unit_space()`, `convert_unit_time()`, `convert_unit_angle()` to rescale; `set_metadata(unit_space = )` only declares. Removed |
| `set_sampling_rate(x, 30)`, which also converted time to seconds | `set_metadata(x, sampling_rate = 30) \|> convert_unit_time("s")`. Removed |
| `get_sampling_rate()`, `get_unit_space()`, `get_unit_time()`, `get_unit_angle()` | `get_metadata(x, "sampling_rate")` and so on. Removed |
| `get_`/`set_axis_extents()`, `set_handedness()`, `set_angle_direction()` | `get_metadata()` / `set_metadata()`; `reflect_axis()` to turn an axis and its data over. Removed |
| `set_connections()` and the other `*_connections()` | `anistructure()`, `set_structure()`, `get_structure()`, `remove_structure()`. Removed |
| `attr(x, "metadata")$field` | `get_metadata(x, "field")`; the raw attribute is now a tree |

### aniread

| Release | Development |
|---|---|
| Readers return class `aniframe` | They return an `anipoint` |
| `get_supported_sources()$reader` | `$fun`, with a `direction` column (`"read"`, `"write"`) |
| `get_sample_data("idtracker")`, `("trackball")` | `"idtrackerai"`, `"trackball_bonsai"` (old names deprecated) |
| `read_animalta(detailed = TRUE)` / `FALSE` | `format = "variable"` / `"fixed"` |
| (none) | `write_dataset()`, the writer matching `read_dataset()` |

### aniprocess

| Release | Development |
|---|---|
| `filter_na_across()`, `filter_na_with()`, `filter_na_confidence()`, `filter_na_excursion()`, `filter_na_range()`, `filter_na_roi()`, `filter_na_speed()` | `mask_na_across()`, `mask_na_with()`, `mask_na_confidence()`, … (deprecated) |
| (none) | `mask_na_hampel()`, `mask_na_segment_length()`, `filter_deadband()`, `mask_na_confidence(missing = )` |

### animetric

| Release | Development |
|---|---|
| `calculate_kinematics()` | `add_kinematics()` (deprecated) |
| `calculate_tortuosity()` | `add_tortuosity()`, which no longer adds the kinematic columns (deprecated) |
| `calculate_nnd()` | `add_nnd()` (deprecated) |
| `summarise_kinematics()` | `summarise_aniframe()` (deprecated) |
| `summarise_tortuosity()` | `summarise_path()` (deprecated) |
| `add_centroid()`, `compute_centroid()` | `add_point()`, `compute_point()`, `method = "centroid"` by default (deprecated) |
| `is_aniframe_kin()`, class `aniframe_kin` | check for the columns you need (deprecated; class gone) |
| `mean_angle()`, `median_angle()` | `anicore::circ_mean()`, `circ_median()`. Removed; the median gives different numbers |

| Column (release) | Column (development) |
|---|---|
| `heading`, `heading_unwrapped` | `course`, `course_unwrapped` (direction of travel) |
| `angular_velocity`, `angular_speed`, `angular_acceleration` | `turning_rate`, `turning_speed`, `turning_acceleration` |
| `angular_path_length` | `cumulative_turning` |
| `path_length` | `cumulative_distance` |
| `straightness`, `sinuosity`, `emax` | `straightness_11`, `sinuosity_11`, `e_max_11` (suffix = window width) |
| `median_heading`, `*_angular_velocity`, … | `median_course`, `*_turning_rate`, … |
| `total_path_length`, `emax`, `total_angular_path_length` | `total_distance`, `e_max`, `total_turning` |
| `nnd_individual`, `nnd_distance` | `nnd_1_individual`, `nnd_1_distance` (neighbour rank in the name) |

`heading` now means where the body faces: `add_orientation()` adds a `heading` column as the
frame's declared orientation (the `yaw` role), the FicTrac and TRex readers declare theirs as
`yaw`, and `summarise_aniframe()` reports a declared orientation as `*_heading`. The deprecated
`calculate_kinematics()` in a development build already returns `course`, so old code reading
`heading` fails there.

### anispace and anivis

| Release | Development |
|---|---|
| `anispace::calculate_angular_difference()`, `diff_angle()` | `anicore::circ_difference()`, `circ_successive_difference()`. Removed |
| `cartesian_to_phi(centered = FALSE)` | `wrap_angle(cartesian_to_phi(x, y), "2pi")` (deprecated argument) |
| (none) | `quat_*()`, `transform_to_egocentric(align = "orientation")`, anivis's `plot_circular()`, anicheck's `check_segment_length()` |

## Older names still circulating

- **Before animovement 0.7.0 (2024–2025)** everything lived in the one `animovement` package:
  `smooth_movement()`, `calculate_statistics()`, `set_framerate()`, `filter_by_speed()`,
  `read_trackball_data()`; older still, the `trackballr` package. None of these exists now, and
  the metapackage exports no analysis functions. Find what the task needs in the owning
  package's `llms.txt`.
- **`aniframe` the package** became **anicore** in 0.8.0: `library(aniframe)` and `aniframe::`
  are now `anicore`. The class name `aniframe` stayed.
- **aniprocess 0.3.0** removed `filter_aniframe()`: the frame-level verb is `filter_across()`.
- **anispace 0.3.0** (a release) changed the transforms' arguments: `to_keypoint`,
  `alignment_points` and `to_x`/`to_y` became `to`, `align` and `by`, with `level` naming the
  identity variable; `wrap_angle()` and `unwrap_angle()` moved to anicore.
- Tutorials, answers and blog posts written before the rename use `set_sampling_rate()`,
  `filter_na_*()` and `calculate_kinematics()`: translate them with the tables above.

## Changes that alter results without an error

When re-running an older analysis on development builds:

- `filter_rollmean()` and `filter_rollmedian()` centre their window (they lagged the signal);
  the ends are now `NA`. `align = "right"` restores the old behaviour.
- `time` is elapsed time since the video's first frame, counted from 0. SLEAP (`.h5` and CSV),
  idtracker.ai (`.h5`, and exports without a frame rate), BORIS image indices and trimmed C3D
  files moved; frame `n` of a SLEAP file is now `time == n - 1`, so code that subtracted 1 to
  align sources no longer should. `?read_dataset` lists every source's convention.
- `read_sleap()` names individuals by the file's track names, not `individual1`, ….
- Readers that mislabelled units now state them: TRex positions are `cm`; idtracker.ai CSV,
  AnimalTA and Bonsai times are `s`. Values are unchanged, but anything that reads the unit
  (conversions, speeds) differs.
- animetric's angles come in the frame's `unit_angle`: a degrees frame used to get radians.
- Directions are written in `(-pi, pi]`: `wrap_angle()` defaults to it, and `circ_mean()`,
  `circ_median()`, `median_course` and anispace's `phi` use it. `wrap_angle(x, "2pi")` gives
  `[0, 2*pi)`.
- `median_course` comes from `circ_median()`; the old median could be 180 degrees off when tied
  directions straddled zero. Stored `median_heading` values may need recomputing.
- `add_kinematics()` and `summarise_path()` drop the direction of steps shorter than `min_step`
  (`"auto"`), so `course` has more `NA` and `total_turning` is lower; `min_step = 0` restores it.
- `sinuosity` and `e_max` come from the path rediscretised to a constant step.
- `add_tortuosity()`'s windowed straightness is `NA` where the window holds a missing point.
- Subsetting that loses a key, the index or the interval (`select()`, `[`, `distinct()`) returns
  a plain tibble rather than a frame.
- `rotate_coords()` and `transform_to_egocentric()` turn a declared orientation along with the
  positions.
