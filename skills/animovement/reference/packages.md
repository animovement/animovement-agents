# animovement packages — key exports

One-line purpose + the exports you'll reach for most. This is a **map, not the full API** —
it is deliberately incomplete and can lag the packages. Confirm against the generated docs
at `https://animovement.dev/<pkg>/llms.txt` (or, if the source is checked out locally, that
package's `R/`, `NAMESPACE` and `NEWS.md`). Where this file and the generated docs disagree,
the generated docs are right.

## animovement — the metapackage

`library(animovement)` attaches the seven packages below and resolves versions and
conflicts. It owns no analysis functions; everything else on this page comes from one of
those seven.

- **Suite management:** `animovement_install()`, `animovement_update()`,
  `animovement_sitrep()`, `animovement_conflicts()`, `animovement_packages()`,
  `animovement_deps()`, `animovement_repos()`, `animovement_extend()`,
  `animovement_detach()`; `animovement_show_suggested()` / `animovement_install_suggested()`
  for the soft dependencies

## anicore — core data structures for movement data

`aniframe` is the parent class; the frames are `anipoint`, `anisegment`, `anijoint` and `anievent`. `set_*` only declares; value-changing operations have their own verbs.

- **Construct / coerce:** `anipoint()`, `as_anipoint()`, `example_anipoint()`, `validate_anipoint()`, `is_anipoint()`, `ensure_is_anipoint()`; `is_aniframe()` / `ensure_is_aniframe()` test for any frame (the old `aniframe()` constructors are soft-deprecated aliases)
- **Column roles:** `get_variables()`, `set_variables()`, `add_variables()`, `remove_variables()` (role and slot arguments), `get_keys()` (the grouping set)
- **Index:** `get_index()` / `set_index()`: the single column the frame is indexed by; never a key
- **Axis roles:** `get_axes()` (which column carries which axis role, so coordinates may be named anything; declare with `set_variables(where = )`), `get_coordinate_system()`
- **Axis directions:** `get_axis_directions()` / `set_axis_directions()` (declares only), `reflect_axis()` (turns an axis over and reflects the data, orientation included), `get_handedness()`, `get_angle_direction()`
- **Entity orientation:** declared in `where$orientation` with `set_variables()` — `yaw` (2D) or a unit quaternion `qw`/`qx`/`qy`/`qz` (3D); the Euler convention a source used goes in `euler_sequence` / `euler_intrinsic` metadata
- **Metadata:** `get_metadata()`, `set_metadata()`, `list_default_metadata()`; flat access over a tree of categories. Units, sampling rate, extents and handedness are declared here
- **Unit conversion:** `convert_unit_space()`, `convert_unit_time()`, `convert_unit_angle()`
- **Sampling:** `get_sampling_interval()`, `is_sampling_regular()` (the rate is `get_metadata(x, "sampling_rate")`)
- **Structures:** `anistructure()`, `example_structure()`, `validate_anistructure()`, `is_anistructure()`, and `set_structure()` / `get_structure()` / `remove_structure()` (several named structures per frame)
- **Segments and joints:** `as_anisegment()`, `as_anijoint()`, `is_anisegment()`, `is_anijoint()`; `as_anipoint(seg, root = )` rebuilds positions
- **Coordinate-system predicates:** `is_cartesian[_1d/_2d/_3d]()`, `is_polar()`, `is_cylindrical()`, `is_spherical()`, `is_spatial()`, and an `ensure_is_*()` for each
- **Events:** `anievent()`, `as_anievent()`, `to_anievent()`, `is_anievent()`, `ensure_is_anievent()`, `validate_anievent()`
- **Angles** (all of the suite's angle utilities): `deg_to_rad()`, `rad_to_deg()`, `angle_to_rad()` / `angle_from_rad()` (values ↔ a frame's `unit_angle`), `wrap_angle()`, `unwrap_angle()`, `angle_between()` (radians)
- **Circular statistics** (radians): `circ_mean()`, `circ_median()`, `circ_sd()`, `circ_mad()`, `circ_difference()`, `circ_successive_difference()`
- **Cleaning values:** `convert_nan_to_na()`, `convert_inf_to_na()`

## aniread — reading & writing movement data

Readers return an anipoint, except `read_boris()`, which returns an anievent (and
`read_dataset()`, which returns whatever the reader it routes to does). Image-plane readers
turn `y` to point up.

- **Read (pose/tracking):** `read_sleap()`, `read_deeplabcut()`, `read_lightningpose()`, `read_anipose()`, `read_trex()`, `read_idtracker()`, `read_octron()`, `read_trackmate()`, `read_fasttrack()`, `read_movement()`, `read_bonsai()`, `read_animalta()`, `read_freemocap()`, `read_c3d()`
- **Read (other):** `read_fictrac()`, `read_trackball()`, `read_boris()`, `read_custom()`, `read_dataset()` (detects the source)
- **Orientation:** `read_fictrac()` and `read_trex()` declare a `yaw`; Bonsai's and Octron's blob angles are axial (no front), so they stay undeclared columns (animovement/anicore#165)
- **Skeletons:** `read_structure()` (detects the tool), `read_structure_deeplabcut()`, `read_structure_sleap()` — each returns an anistructure, attached with `anicore::set_structure()`; the frame readers do not attach one
- **Round-trip:** `write_aniframe()` (parquet keeps metadata; CSV/TSV lose it) / `read_aniframe()` (parquet only; restores an anipoint or an anievent); also `write_intracktive()`
- **Utilities:** `get_supported_sources()`, `detect_source()`, `get_sample_data()`, `calibrate_trackball()`, `validate_trackball()`

## aniprocess — signal processing & filtering

`filter_*` here means **signal filtering**, never row subsetting. Two tiers:

- **Whole frame** (experimental): `filter_na_across()`, `replace_na_across()`, `filter_across()` — take an aniframe and a method name, act on the declared position columns within the frame's grouping, and read the index, `sampling_rate` and `confidence` from the frame
- **Column level** — take a vector or a `pick()`ed data frame, inside `mutate()`; `filter_na_with()`, `replace_na_with()` and `filter_with()` choose the method by name:
  - **NA masking:** `filter_na_confidence()`, `filter_na_excursion()`, `filter_na_speed()`, `filter_na_range()`, `filter_na_roi()`
  - **Gap filling:** `replace_na_linear()`, `replace_na_spline()`, `replace_na_stine()`, `replace_na_locf()`, `replace_na_value()`
  - **Smoothing / filtering:** `filter_sgolay()`, `filter_gaussian()`, `filter_triangular()`, `filter_rollmean()`, `filter_rollmedian()` (both centred by default), `filter_lowpass[_fft]()`, `filter_highpass[_fft]()`, `filter_kalman[_irregular]()`, `filter_ccma()`, `filter_one_euro()`
- **Peaks:** `find_peaks()`, `find_troughs()`

## animetric — movement-based metrics

- **Kinematics:** `calculate_kinematics()` — velocity and acceleration components named by axis role (`v_x`, …), speed, acceleration, path length, and the path-direction measures (`course`, `turning_rate`, …; which dimensions get them is on its reference page); angles in the frame's `unit_angle`. Also `differentiate()`, `compute_gradient()`, `is_aniframe_kin()`
- **Path complexity:** `calculate_tortuosity()`, `compute_sinuosity()`, `compute_straightness()`, `compute_emax()`
- **Spatial relations:** `calculate_nnd()` (needs `across`) / `compute_nnd()` (nearest-neighbour distance)
- **Centroids:** `add_centroid()` appends one as a new member of an identity level; `compute_centroid()` returns a frame holding it alone. Both take `across` to say which level collapses, required once the frame declares more than one
- **Summaries:** `summarise_kinematics()`, `summarise_tortuosity()`, `summarise_aniframe()`, each with a `summarize_*` alias
- Circular statistics are anicore's `circ_*()`; `mean_angle()` and `median_angle()` are removed

## anivis — visualisation

- **Plots:** `plot_trajectory()`, `plot_timeseries()`, `plot_events()`, and the `plot()` methods for anipoints and anievents; `plots()` arranges several side by side
- **Check plots:** the drawing behind `plot()` on anicheck objects; `as_plot_data()` gives the data a check plot draws
- **Themes:** `theme_animovement[_light/_dark]()`, `theme_imputets()`
- **Palettes + scales:** `palette_animovement()`, `palette_material()`, `palette_okabeito()`; the underlying vectors `material_colors()`, `okabeito_colors()`, `oi_colors()`; `scale_[colour|color|fill]_material[_c/_d]()`, `scale_*_okabeito()`, `scale_*_oi()`
- **Event geoms:** `geom_event_point()`, `geom_event_state()`

## anicheck — data-quality diagnostics

- `check_confidence()`, `check_na_timing()`, `check_na_gapsize()` — take an anipoint and return check objects, not frames. anicheck registers their `plot()`, `summary()` and `print()` methods; `plot()` hands off to anivis, and prompts to install it if missing.

## anispace — spatial transformations and quaternions

- **System maps:** `map_to_cartesian()`, `map_to_polar()`, `map_to_cylindrical()`, `map_to_spherical()` — read the declared axes, and `phi` / `theta` in the frame's `unit_angle`
- **Rigid transforms:** `translate_coords()`, `rotate_coords()`, `transform_to_egocentric()` — the reference point is a member of an identity `level`, named with `to`, `align`, `about`, or an offset `by`
- **Component converters** (radians): `cartesian_to_rho/phi/theta()`, `polar_to_x/y()`, `spherical_to_z()`
- **Quaternions** (3D orientation): `quat_multiply()`, `quat_conjugate()`, `quat_normalise()`, `quat_rotate()`, `quat_distance()`; `quat_from_/quat_to_axis_angle()`, `_matrix()`, `_euler()`; `quat_slerp()`, `quat_mean()`, `quat_continuous()`, `quat_angular_velocity()`
- **Orientation on a frame:** `transform_euler_to_quaternion()` declares a quaternion orientation from exported Euler angles and records their convention; `transform_quaternion_to_euler()` gives them back
- No angle utilities live here any more: `wrap_angle()`, `circ_difference()` and the rest are in **anicore**.
