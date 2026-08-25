# animovement packages — key exports

One-line purpose + the exports you'll reach for most. This is a **map, not the full API** —
it is deliberately incomplete and can lag the packages. Confirm against the generated docs
at `https://animovement.dev/<pkg>/llms.txt` (or, if the source is checked out locally, that
package's `R/` and `NAMESPACE`). Where this file and the generated docs disagree, the
generated docs are right.

## animovement — the metapackage

`library(animovement)` attaches the suite below and resolves versions and conflicts. It owns
no analysis functions; everything else on this page comes from one of the seven packages.

## aniframe — core data structures for movement data

- **Construct / coerce:** `aniframe()`, `as_aniframe()`, `example_aniframe()`, `is_aniframe()`, `ensure_is_aniframe()`, `validate_aniframe()`
- **Column roles:** `get_variables_what()` / `set_` / `add_` / `remove_` — and the same four verbs for `variables_when()`, `variables_where()`, `variables_event()`
- **Metadata:** `get_metadata()`, `set_metadata()`, `default_metadata()`
- **Units / geometry:** `set_unit_space()`, `set_unit_time()`, `set_unit_angle()`, `set_origin()`, `set_y_height()`, `set_sampling_rate()`
- **Connections (skeleton):** `set_connections()`, `get_connections()`, `add_connections()`, `remove_connections()`
- **Coordinate-system predicates:** `is_cartesian[_1d/_2d/_3d]()`, `is_polar()`, `is_cylindrical()`, `is_spherical()`, `is_spatial()`, and an `ensure_is_*()` for each
- **Events:** `anievent()`, `as_anievent()`, `to_anievent()`, `is_anievent()`, `ensure_is_anievent()`, `validate_anievent()`
- **Angle conversion:** `deg_to_rad()`, `rad_to_deg()`; also `convert_nan_to_na()`
  — note the angle *manipulation* helpers (`wrap_angle()` etc.) are in **anispace**, not here.

## aniread — reading & writing movement data

- **Read (pose/tracking):** `read_sleap()`, `read_deeplabcut()`, `read_lightningpose()`, `read_anipose()`, `read_trex()`, `read_idtracker()`, `read_octron()`, `read_trackmate()`, `read_fasttrack()`, `read_movement()`, `read_bonsai()`, `read_animalta()`, `read_freemocap()`, `read_c3d()`
- **Read (other):** `read_fictrac()`, `read_trackball()`, `read_boris()`, `read_custom()`, `read_dataset()`
- **Round-trip:** `read_aniframe()` / `write_aniframe()`; also `write_intracktive()`
- **Utilities:** `get_supported_sources()`, `detect_source()`, `get_sample_data()`, `calibrate_trackball()`

## aniprocess — signal processing & filtering

`filter_*` here means **signal filtering**, never row subsetting.

- **NA masking (set bad points to NA):** `filter_na_confidence()`, `filter_na_excursion()`, `filter_na_speed()`, `filter_na_range()`, `filter_na_roi()`; `filter_na_with()` and `filter_na_across()` to apply a rule yourself
- **Gap filling (replace NA):** `replace_na_linear()`, `replace_na_spline()`, `replace_na_stine()`, `replace_na_locf()`, `replace_na_value()`; `replace_na_with()`, `replace_na_across()`
- **Smoothing / filtering:** `filter_sgolay()`, `filter_gaussian()`, `filter_triangular()`, `filter_rollmean()`, `filter_rollmedian()`, `filter_lowpass[_fft]()`, `filter_highpass[_fft]()`, `filter_kalman[_irregular]()`, `filter_ccma()`, `filter_one_euro()`
- **Apply across columns:** `filter_with()`, `filter_across()`
- **Peaks:** `find_peaks()`, `find_troughs()`

## animetric — movement-based metrics

- **Kinematics:** `calculate_kinematics()` (speed, acceleration, …), `differentiate()`, `compute_gradient()`, `is_aniframe_kin()`
- **Path complexity:** `calculate_tortuosity()`, `compute_sinuosity()`, `compute_straightness()`, `compute_emax()`
- **Spatial relations:** `calculate_nnd()` / `compute_nnd()` (nearest-neighbour distance), `compute_centroid()`
- **Circular statistics:** `mean_angle()`, `median_angle()`
- **Summaries:** `summarise_kinematics()`, `summarise_tortuosity()`, `summarise_keypoints()`, `summarise_aniframe()` — `summarize_*` aliases exist for most, but not all, of these

## anivis — visualisation & diagnostics

- **Plots:** `plot_trajectory()`, `plot_timeseries()`, `plot_events()`, `as_plot_data()` — also the `plot()` methods for aniframes and anicheck objects
- **Themes:** `theme_animovement[_light/_dark]()`, `theme_imputets()`
- **Palettes + scales:** `palette_animovement()`, `palette_material()`, `palette_okabeito()`; the underlying vectors `material_colors()`, `okabeito_colors()`, `oi_colors()`; `scale_[colour|color|fill]_material[_c/_d]()`, `scale_*_okabeito()`, `scale_*_oi()`
- **Event geoms:** `geom_event_point()`, `geom_event_state()`

## anicheck — data-quality diagnostics

- `check_confidence()`, `check_na_timing()`, `check_na_gapsize()` — return check objects; call `plot()` on them (methods live in anivis) for the QC figures.

## anispace — spatial transformations *and angles*

- **System maps:** `map_to_cartesian()`, `map_to_polar()`, `map_to_cylindrical()`, `map_to_spherical()`
- **Rigid transforms:** `rotate_coords()`, `translate_coords()`, `transform_to_egocentric()`
- **Component converters:** `cartesian_to_rho/phi/theta()`, `polar_to_x/y()`, `spherical_to_z()`
- **Angles:** `wrap_angle()`, `unwrap_angle()`, `diff_angle()`, `calculate_angular_difference()`
  — these live **only** here, despite reading like metrics.
