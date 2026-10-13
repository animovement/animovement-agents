# animovement packages: key exports

Read this when looking for the function that does something, or the package that owns a name.
It is a **map, not the API**: deliberately incomplete, and it can lag the packages. Confirm each
name and signature at `https://animovement.dev/<package>/llms.txt` (or, with the source checked
out, that package's `NAMESPACE`, `R/` and `NEWS.md`); where they disagree with this file, they are
right. Names here are those of the development builds; `versions.md` maps older ones.

## animovement: the metapackage

`library(animovement)` attaches the seven packages below and reports conflicts. It exports no
analysis functions, so `animovement::read_dataset()` fails: call through the owning package.

- **Suite management:** `animovement_sitrep()` (versions, and whether any are behind),
  `animovement_update()` (prints the install command; `install = TRUE` runs it),
  `animovement_install()`, `animovement_packages()`, `animovement_deps()`,
  `animovement_repos()` (R-universe added to `getOption("repos")`), `animovement_conflicts()`,
  `animovement_extend()`, `animovement_detach()`
- **Optional dependencies:** `animovement_show_suggested()`, `animovement_install_suggested()`
  (rhdf5 from Bioconductor for `.h5`, arrow for Parquet, signal for some filters, …)

## anicore: classes, metadata, units, angles

`aniframe` is the parent class; the frames are `anipoint` (positions), `anisegment`,
`anijoint` and `anievent`. `set_*` only declares; changing values has its own verbs.

- **Construct and test:** `anipoint()`, `as_anipoint()`, `example_anipoint()`,
  `validate_anipoint()`, `is_anipoint()`, `ensure_is_anipoint()`; `is_aniframe()` is true for
  any frame. The `aniframe()` constructors are soft-deprecated aliases
- **Column roles:** `get_variables()`, `set_variables()`, `add_variables()`,
  `remove_variables()` (role, then slot); `get_keys()` (the grouping columns); `get_index()`,
  `set_index()`; `get_axes()` (which column carries which axis role)
- **Metadata:** `get_metadata()`, `set_metadata()`, `list_default_metadata()`; flat field names
  over categories. `print(get_metadata(x), all = TRUE)` shows unset fields too
- **Units:** `convert_unit_space()`, `convert_unit_time()`, `convert_unit_angle()`
- **Sampling:** `get_sampling_interval()`, `is_sampling_regular()`; the rate is
  `get_metadata(x, "sampling_rate")`, the device's own `source_sampling_rate`
- **Axes:** `get_axis_directions()`, `set_axis_directions()` (declares), `reflect_axis()`
  (turns an axis and its data over), `get_handedness()`, `get_angle_direction()`,
  `get_coordinate_system()`, `is_cartesian_2d()` and the other `is_*()` / `ensure_is_*()`
- **Structures (skeletons):** `anistructure()`, `example_structure()`, `set_structure()`,
  `get_structure()`, `remove_structure()`; `as_anisegment()`, `as_anijoint()` (experimental)
- **Events:** `anievent()`, `as_anievent()`, `to_anievent()` (per-frame labels to bouts),
  `is_anievent()`, `validate_anievent()`
- **Angles:** `deg_to_rad()`, `rad_to_deg()`, `angle_to_rad()` / `angle_from_rad()` (values
  and a frame's `unit_angle`), `wrap_angle()` (to `(-pi, pi]`; `"2pi"` for `[0, 2*pi)`),
  `unwrap_angle()`, `angle_between()`
- **Circular statistics** (radians): `circ_mean()`, `circ_median()`, `circ_sd()`,
  `circ_mad()`, `circ_difference()`, `circ_successive_difference()`
- **Cleaning values:** `convert_nan_to_na()`, `convert_inf_to_na()`

## aniread: reading and writing

- **Entry points:** `read_dataset()` (detects the tool), `write_dataset()` (format from the
  suffix; `by =` for one file per group), `detect_source()`, `get_supported_sources()`
- **Pose and tracking readers:** `read_deeplabcut()`, `read_sleap()`, `read_lightningpose()`,
  `read_idtracker()`, `read_trex()`, `read_movement()`, `read_anipose()`, `read_freemocap()`,
  `read_c3d()`, `read_trackmate()`, `read_bonsai()`, `read_animalta()`, `read_fasttrack()`,
  `read_octron()`, `read_fictrac()`, `read_trackball()`, `read_custom()`
- **Events:** `read_boris()` returns an anievent
- **Skeletons:** `read_structure()`, `read_structure_deeplabcut()`, `read_structure_sleap()`
  (experimental); attach with `anicore::set_structure()`
- **Saved frames:** `write_aniframe()` / `read_aniframe()` (Parquet keeps class and metadata;
  CSV doesn't), `write_intracktive()`
- **Utilities:** `get_sample_data()` (an example file per source), `calibrate_trackball()`

Per-tool notes: `readers.md`.

## anicheck: data-quality reports

`check_confidence()`, `check_na_gapsize()`, `check_na_timing()`, `check_segment_length()`
(needs a skeleton; experimental). Each takes an anipoint and returns a check object with
`print()`, `summary()` and `plot()` methods; `plot()` uses anivis.

## aniprocess: masking, filling, smoothing

`filter_` is signal filtering, never row subsetting; `mask_na_` sets values to `NA` and keeps
rows. Two tiers:

- **Whole frame** (experimental): `mask_na_across()`, `replace_na_across()`, `filter_across()`.
  Each takes a method name, works on the declared position columns within the frame's groups,
  and reads the index, `sampling_rate` and `confidence` from the frame
- **Vectors**, inside `mutate()`; `mask_na_with()`, `replace_na_with()`, `filter_with()` take
  the method by name:
  - **Masking:** `mask_na_confidence()`, `mask_na_roi()`, `mask_na_range()`,
    `mask_na_speed()`, `mask_na_excursion()`, `mask_na_hampel()`; and
    `mask_na_segment_length()`, which takes a whole anipoint with a skeleton
  - **Filling:** `replace_na_linear()`, `replace_na_spline()`, `replace_na_stine()`,
    `replace_na_locf()`, `replace_na_value()`
  - **Smoothing:** `filter_sgolay()`, `filter_gaussian()`, `filter_triangular()`,
    `filter_rollmean()`, `filter_rollmedian()`, `filter_lowpass()`, `filter_highpass()` (and
    `_fft`), `filter_kalman()` (and `_irregular`), `filter_one_euro()`, `filter_ccma()`,
    `filter_deadband()` (holds a still point still)
- **Peaks:** `find_peaks()`, `find_troughs()`

## animetric: metrics

`add_*()` returns the frame with something added, `compute_*()` are primitives (mostly on
vectors), `summarise_*()` gives one row per group.

- **Kinematics:** `add_kinematics()` (velocity, `speed`, `acceleration`,
  `cumulative_distance`, `course`, turning measures; `vertical =` in 3D, `min_step =`);
  `compute_min_step()`; `differentiate()`, `compute_gradient()`
- **Path shape:** `add_tortuosity()` (windowed `straightness_<w>`, `sinuosity_<w>`,
  `e_max_<w>`); `compute_straightness()`, `compute_sinuosity()`, `compute_emax()`
- **Neighbours:** `add_nnd()` (needs `across`), `compute_nnd()`
- **Derived points:** `add_point()` (`across`, `method = "centroid"`, `"median"`,
  `"weighted"` or a function), `compute_point()`
- **Orientation:** `add_orientation()` (`from`, `to`; `plane` in 3D; `perpendicular`,
  `attach_to`, `level`) declares `heading` or a quaternion
- **Summaries:** `summarise_aniframe()` (distribution of per-row measures; methods for anipoints,
  anisegments, anijoints) and `summarise_path()` (whole-trajectory geometry), with
  `summarize_*()` aliases
- **Deprecated:** `calculate_kinematics()`, `calculate_tortuosity()`, `calculate_nnd()`,
  `summarise_kinematics()`, `summarise_tortuosity()`, `add_centroid()`, `compute_centroid()`,
  `is_aniframe_kin()`

## anivis: plots

- **Plots:** `plot()` methods for anipoints and anievents, `plot_trajectory()`,
  `plot_timeseries()`, `plot_events()`, `plot_circular()` (experimental rose diagram), `plots()`
  (side by side)
- **Check plots:** the drawing behind `plot()` on anicheck objects; `as_plot_data()` gives
  their data
- **Look:** `theme_animovement()` (`_light`, `_dark`), `palette_animovement()`,
  `palette_okabeito()`, `palette_material()`, `scale_colour_okabeito()` and the other
  `scale_[colour|color|fill]_*()`; `geom_event_point()`, `geom_event_state()`

## anispace: coordinates and orientation

- **Coordinate systems:** `map_to_cartesian()`, `map_to_polar()`, `map_to_cylindrical()`,
  `map_to_spherical()`; component converters `cartesian_to_rho()`, `cartesian_to_phi()`,
  `polar_to_x()`, … (radians)
- **Rigid transforms:** `translate_coords()`, `rotate_coords()`, `transform_to_egocentric()`;
  the reference is a member of an identity `level`, named by `to`, `align`, `about` or an
  offset `by`
- **Quaternions** (3D orientation): `quat_multiply()`, `quat_rotate()`, `quat_from_euler()`,
  `quat_to_euler()`, `quat_from_vectors()`, `quat_slerp()`, `quat_mean()`, … ;
  `transform_euler_to_quaternion()` declares an orientation from exported Euler angles
- No angle utilities live here any more: they are anicore's
