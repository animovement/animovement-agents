# animovement packages — key exports

One-line purpose + the exports you'll reach for most. This is a **map, not the full API** —
it is deliberately incomplete and can lag the packages. Confirm against the generated docs
at `https://animovement.dev/<pkg>/llms.txt` (or, if the source is checked out locally, that
package's `R/` and `NAMESPACE`). Where this file and the generated docs disagree, the
generated docs are right.

## animovement — the metapackage

`library(animovement)` attaches the suite below and resolves versions and conflicts. It owns
no analysis functions; everything else on this page comes from one of the seven packages.

## anicore — core data structures for movement data

`aniframe` is the parent class; the frames are `anipoint`, `anisegment`, `anijoint` and `anievent`. `set_*` only declares; value-changing operations have their own verbs.

- **Construct / coerce:** `anipoint()`, `as_anipoint()`, `example_anipoint()`, `validate_anipoint()`, `is_anipoint()`, `ensure_is_anipoint()`; `is_aniframe()` / `ensure_is_aniframe()` test for any frame (the old `aniframe()` constructors are soft-deprecated aliases)
- **Column roles:** `get_variables()`, `set_variables()`, `add_variables()`, `remove_variables()` (role and slot arguments), `get_keys()` (the grouping set)
- **Index:** `get_index()` / `set_index()`: the single column the frame is indexed by; never a key
- **Axis roles:** `get_axes()` (which column carries which axis role, so coordinates may be named anything; declare with `set_variables(where = )`), `get_coordinate_system()`
- **Orientation:** `get_axis_directions()` / `set_axis_directions()` (declares only), `reflect_axis()` (turns an axis over and reflects the data), `get_handedness()`, `get_angle_direction()`; orientation columns (`yaw`, quaternion) go in `where$orientation`
- **Metadata:** `get_metadata()`, `set_metadata()`, `list_default_metadata()`; flat access over a tree of categories. Units, sampling rate, extents and handedness are declared here
- **Unit conversion:** `convert_unit_space()`, `convert_unit_time()`, `convert_unit_angle()`
- **Sampling:** `get_sampling_interval()`, `is_sampling_regular()` (the rate is `get_metadata(x, "sampling_rate")`)
- **Structures:** `anistructure()`, `example_structure()`, `validate_anistructure()`, `is_anistructure()`, and `set_structure()` / `get_structure()` / `remove_structure()` (several named structures per frame)
- **Segments and joints:** `as_anisegment()`, `as_anijoint()`, `is_anisegment()`, `is_anijoint()`, `angle_between()`; `as_anipoint(seg, root = )` rebuilds positions
- **Coordinate-system predicates:** `is_cartesian[_1d/_2d/_3d]()`, `is_polar()`, `is_cylindrical()`, `is_spherical()`, `is_spatial()`, and an `ensure_is_*()` for each
- **Events:** `anievent()`, `as_anievent()`, `to_anievent()`, `is_anievent()`, `ensure_is_anievent()`, `validate_anievent()`
- **Angles:** `deg_to_rad()`, `rad_to_deg()`, `wrap_angle()`, `unwrap_angle()`, `circ_*()`; also `convert_nan_to_na()`, `convert_inf_to_na()`

## aniread — reading & writing movement data

- **Read (pose/tracking):** `read_sleap()`, `read_deeplabcut()`, `read_lightningpose()`, `read_anipose()`, `read_trex()`, `read_idtracker()`, `read_octron()`, `read_trackmate()`, `read_fasttrack()`, `read_movement()`, `read_bonsai()`, `read_animalta()`, `read_freemocap()`, `read_c3d()`
- **Read (other):** `read_fictrac()`, `read_trackball()`, `read_boris()`, `read_custom()`, `read_dataset()`
- **Round-trip:** `read_aniframe()` / `write_aniframe()` (any frame class); also `write_intracktive()`
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
- **Spatial relations:** `calculate_nnd()` / `compute_nnd()` (nearest-neighbour distance)
- **Centroids:** `add_centroid()` appends one as a new member of an identity level; `compute_centroid()` returns it alone. Both take `across` to say which level collapses
- **Circular statistics:** `mean_angle()`, `median_angle()`
- **Summaries:** `summarise_kinematics()`, `summarise_tortuosity()`, `summarise_aniframe()` — `summarize_*` aliases exist for most, but not all, of these

## anivis — visualisation & diagnostics

- **Plots:** `plot_trajectory()`, `plot_timeseries()`, `plot_events()`, `as_plot_data()` — also the `plot()` methods for anipoints, anievents and anicheck objects
- **Themes:** `theme_animovement[_light/_dark]()`, `theme_imputets()`
- **Palettes + scales:** `palette_animovement()`, `palette_material()`, `palette_okabeito()`; the underlying vectors `material_colors()`, `okabeito_colors()`, `oi_colors()`; `scale_[colour|color|fill]_material[_c/_d]()`, `scale_*_okabeito()`, `scale_*_oi()`
- **Event geoms:** `geom_event_point()`, `geom_event_state()`

## anicheck — data-quality diagnostics

- `check_confidence()`, `check_na_timing()`, `check_na_gapsize()` — return check objects; call `plot()` on them (methods live in anivis) for the QC figures.

## anispace — spatial transformations *and angles*

- **System maps:** `map_to_cartesian()`, `map_to_polar()`, `map_to_cylindrical()`, `map_to_spherical()`
- **Rigid transforms:** `rotate_coords()`, `translate_coords()`, `transform_to_egocentric()`
- **Component converters:** `cartesian_to_rho/phi/theta()`, `polar_to_x/y()`, `spherical_to_z()`
- **Angles:** `diff_angle()`, `calculate_angular_difference()` — but `wrap_angle()` and
  `unwrap_angle()` are in **anicore**, not here.
