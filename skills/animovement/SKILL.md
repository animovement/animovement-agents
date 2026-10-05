---
name: animovement
description: >-
  Use when reading, cleaning, analysing, or plotting animal movement / pose
  tracking data with the animovement R stack (anicore, aniread, aniprocess,
  animetric, anivis, anicheck, anispace). Explains which package owns what, the
  aniframe data model, and the naming conventions, so functions can be located
  and their signatures verified rather than guessed.
---

# animovement

animovement is a modular R stack for animal movement & pose data, built around one
shared data structure — the **aniframe**. Each package owns one stage of the
pipeline. When a task involves any `ani*` package, use this map to decide *where*
a function lives, then **verify its signature against the generated docs** before
calling it (see *Verifying against source*).

For contributing to these packages rather than using them — releases, `NEWS.md`,
licensing, CI, commit conventions — use the **animovement-dev** skill instead.

## The packages (where things live)

Eight packages. `anipoint`, `anisegment`, `anijoint`, `anievent` and `anistructure` are
**classes defined in anicore**, not packages.

| Package | Owns | Verb prefixes |
|---|---|---|
| **animovement** | The metapackage. `library(animovement)` attaches the seven below and resolves versions; it owns no analysis functions | `animovement_` (install, update, conflicts, sitrep) |
| **anicore** | The frame classes, metadata, units, axes, orientation, structures, grouping, and **every angle utility** | `as_` `is_` `ensure_` `get_` `set_` `add_` `remove_` `convert_` `reflect_` `validate_` `example_` `list_` `to_` `circ_` `angle_`, constructors `anipoint()` `anievent()` `anistructure()` |
| **aniread** | Reading tracker output into an anipoint (BORIS into an anievent), skeletons into an anistructure, writing frames back; `read_dataset()` detects the source and is the entry point | `read_` `write_` `detect_` `get_` `calibrate_` `validate_` |
| **aniprocess** | Signal processing: NA masking, gap filling, smoothing/filtering, peaks | `mask_na_` `replace_na_` `filter_` `find_` |
| **animetric** | Metrics: kinematics, tortuosity, nearest-neighbour, derived points, orientation from points, summaries | `add_` `compute_` `summarise_`/`summarize_`, plus `differentiate()` |
| **anivis** | Plot methods, themes, palettes, colour scales, figure layout | `plot_` `theme_` `scale_` `geom_` `palette_`, plus `as_plot_data()` `*_colors()` `plots()` |
| **anicheck** | Data-quality diagnostics on an anipoint: confidence, missing data, segment lengths (return check objects) | `check_` |
| **anispace** | Coordinate-system maps, rigid transforms, egocentric frames, quaternions | `map_to_` `transform_` `rotate_` `translate_` `quat_` `cartesian_to_` `polar_to_` `spherical_to_` |

**A prefix narrows the search; it does not settle it.** `add_`, `get_`, `is_`, `as_` and
`validate_` each occur in more than one package — `add_variables()` (anicore) and
`add_point()` (animetric), `get_metadata()` (anicore) and `get_sample_data()` (aniread),
`as_anipoint()` (anicore) and `as_plot_data()` (anivis). Look the name up.

See `reference/packages.md` for the key exported functions per package.

## A typical pipeline

```r
library(animovement)                          # attaches the seven packages

af <- read_dataset(path)                      # aniread    — detects the source; an anipoint
af <- set_metadata(af, sampling_rate = fps)   # anicore    — if the reader recorded none

plot(check_confidence(af))                    # anicheck   — a side branch: returns a check object, not a frame

af <- af |>
  mask_na_across("confidence") |>             # aniprocess — mask low-confidence points to NA
  replace_na_across("linear") |>              # aniprocess — fill the gaps
  filter_across("sgolay") |>                  # aniprocess — smooth; sampling_rate is read from metadata
  add_kinematics()                            # animetric  — speed, acceleration, course, …

summarise_path(af)                            # animetric  — one row per trajectory
plot_trajectory(af)                           # anivis
```

That arc — read → check → clean → transform → measure → plot — is the shape of nearly every
task here. **The tuning arguments are omitted deliberately**: thresholds, gap lengths and
window widths have defaults, but none is a safe choice for unseen data, so look each one up
rather than copying this as working code. The `*_across()` verbs are marked experimental.

**aniprocess has two tiers.** `mask_na_across()`, `replace_na_across()` and
`filter_across()` take a whole frame, work on its declared position columns within its
grouping, and fill in what the frame knows (index, `sampling_rate`, `confidence`). The
specific functions — `mask_na_confidence()`, `replace_na_linear()`, `filter_sgolay()`, … —
and the `*_with()` dispatchers take a vector or a `pick()`ed data frame, for use inside
`mutate()`; they are not frame-level verbs.

## Naming traps

- **`filter_*` means signal filtering, not row subsetting.** `filter_across()` smooths and
  `mask_na_across()` masks bad points to NA; neither drops rows. `dplyr::filter()` also works
  on an aniframe and *does* subset rows. Read which one is meant. The masking functions were
  called `filter_na_*()` until aniprocess 0.5.0; the old names still work, with a deprecation
  warning, until the release after.
- **Every angle utility is in anicore**: `wrap_angle()`, `unwrap_angle()`, `deg_to_rad()`,
  `rad_to_deg()`, `angle_to_rad()` / `angle_from_rad()` (values ↔ a frame's `unit_angle`),
  `angle_between()`, and the circular statistics `circ_mean()`, `circ_median()`, `circ_sd()`,
  `circ_mad()`, `circ_difference()`, `circ_successive_difference()`. Of the angle maths,
  anispace keeps only quaternions (`quat_*()`). Gone: animetric's `mean_angle()` /
  `median_angle()` (use `circ_mean()` / `circ_median()` — the median gives **different
  numbers**, since the old one was not rotation-equivariant) and anispace's
  `calculate_angular_difference()` / `diff_angle()` (now `circ_difference()` /
  `circ_successive_difference()`).
- **Course is not heading.** animetric's velocity-derived angles describe the *path*: `course`
  (direction of travel), `course_unwrapped`, `turning_rate`, `turning_speed`,
  `turning_acceleration`, `cumulative_turning`; the summaries are `*_course`, `*_turning_*` and
  `total_turning`. `heading` and angular velocity are reserved for the *body* — where the animal
  faces, declared as orientation. The old names (`heading`, `angular_velocity`, …) were renamed
  in animetric's development version; which measures exist for which dimensionality is in the
  `add_kinematics()` reference page. In 3D, `course`, `course_elevation` and the signed
  `turning_rate` need `add_kinematics(vertical = "z")` (or whichever axis points up in the
  world): `axis_directions` are relative to the camera and cannot say which way gravity is.
  A step shorter than `min_step` (`"auto"`: from the tracking noise of each trajectory) has no
  `course` and adds no turning; `min_step = 0` counts every step.
- **Two kinds of summary.** `summarise_aniframe()` gives the *distribution* of per-row measures
  (median speed, circular mean course, `median_straightness_11` from windowed straightness), one
  row per group at any grouping; it is an S3 generic with methods for anipoints, anisegments
  (`length`) and anijoints (`angle`, circular). `summarise_path()` gives whole-trajectory
  geometry (`total_distance`, `net_displacement`, whole-path `straightness`, `sinuosity`,
  `e_max`, `total_turning`) and needs one trajectory per group. Neither needs `add_kinematics()`
  run first.
- **animetric's prefixes say what comes back.** `add_*()` returns the frame with something
  added: columns (`add_kinematics()`, `add_tortuosity()`, `add_nnd()`), a derived member (`add_point()`) or
  a declared orientation (`add_orientation()`). `compute_*()` are lower-level primitives: most
  take vectors (`compute_nnd()`, `compute_straightness()`, `compute_gradient()`);
  `compute_point()` returns a frame holding only the derived point. `summarise_*()` returns one
  row per group. No `calculate_` function is left.
- **Renamed in animetric's development version.** Agents that learned the old names will reach
  for them; they still run, with a deprecation warning and their old output, until the next
  release:
  - `calculate_kinematics()` is now `add_kinematics()`, whose `path_length` is
    `cumulative_distance`.
  - `calculate_tortuosity()` is now `add_tortuosity()`, which adds only `straightness_<w>`,
    `sinuosity_<w>` and `e_max_<w>`, named by the window width (`straightness_11` by default),
    and no longer the kinematic columns.
  - `summarise_kinematics()` is now `summarise_aniframe()`, and `summarise_tortuosity()` is
    `summarise_path()`, where `total_path_length` and `emax` are `total_distance` and `e_max`.
  - `add_centroid()` / `compute_centroid()` are now `add_point()` / `compute_point()`
    (`method = "centroid"` by default).
  - `calculate_nnd()` is now `add_nnd()`. Its columns carry the neighbour rank:
    `nnd_<n>_<across>`, `nnd_<n>_<variable>` and `nnd_<n>_distance` (e.g. `nnd_1_individual`),
    so calls with different `n` can sit side by side; split them with `^nnd_(\d+)_(.+)$`.
  - `is_aniframe_kin()` is deprecated and the `aniframe_kin` class retired: check for the
    columns you need instead of a class.
- **Say which identity level you mean.** `add_nnd()` always needs `across`;
  `add_point()` / `compute_point()` need `across` once the frame declares more than one
  identity variable; anispace's `translate_coords()`, `rotate_coords()` and
  `transform_to_egocentric()` then need `level`, naming the variable their reference point
  belongs to, and take `to` / `align` / `about` / `by` (formerly `to_keypoint`,
  `alignment_points`, `to_x` …).
- **Both British and American spellings** are exported for much of the suite
  (`summarise`/`summarize`, `colour`/`color`) — but not universally, so check rather than assume.
- **An aniframe stays grouped by identity and temporal context.** Operations run
  within-track by design; if a result looks per-individual when you expected it pooled, that
  is why. Regrouping warns, and operations that derive from successive rows (speed, path
  length) refuse a grouping that pools several trajectories.
- **The identity order is not a hierarchy.** The `what` keys are not ordered coarse to fine,
  identity variables need not nest, and there is no "finest" level to infer. Where a function
  collapses one, it asks which.

## Changes that alter results without an error

Worth knowing when re-running an older analysis on current packages; `NEWS.md` has the rest.

- `filter_rollmean()` / `filter_rollmedian()` centre their window by default (they were
  right-aligned, which lagged the signal). The ends are now `NA`; `align = "right"` restores
  the old behaviour.
- `read_sleap()` names individuals by the track names an h5 file records, not
  `individual1`, `individual2`, ….
- animetric's angular measures come back in the frame's `unit_angle`; a frame declared in
  degrees used to get radians.
- `median_course` (formerly `median_heading`) is computed with `circ_median()`; the old value
  could be 180 degrees off when tied directions straddled zero.
- `add_kinematics()` (and the deprecated `calculate_kinematics()`) return a plain anipoint: the
  `aniframe_kin` class is gone, so code testing `inherits(x, "aniframe_kin")` now gets `FALSE`.
- Directions are signed, in `(-pi, pi]`: `wrap_angle()` defaults to `modulo = "pi"`, and
  `circ_mean()` / `circ_median()`, and so summaries such as `median_course`, return that range
  where they gave `[0, 2*pi)`. anispace's `map_to_polar()`, `map_to_cylindrical()` and
  `map_to_spherical()` write `phi` in that range too. `wrap_angle(x, "2pi")` gives the old range.
- `add_kinematics()` and `summarise_path()` drop the direction of steps shorter than `min_step`
  (`"auto"` by default), so `course` has more `NA` and `total_turning` is lower than
  `calculate_kinematics()` gave; `min_step = 0` restores it.
- `summarise_path()`'s and `add_tortuosity()`'s `sinuosity` and `e_max` come from the path
  rediscretised to a constant step length, so they differ from the deprecated functions'.
- Subsetting a frame so that it loses a key, index or interval column (`select()`, `[`,
  `distinct()`) returns a plain tibble, not a frame with metadata naming missing columns.
- anispace's `rotate_coords()` and `transform_to_egocentric()` turn a declared orientation with
  the positions; it used to be left stale.

## The aniframe data model

**aniframe** is the parent class of the frames: **anipoint** (positions, what readers return),
**anisegment** (length + direction per segment), **anijoint** (an angle per joint) and
**anievent** (bouts). `is_aniframe()` is TRUE for all of them; test `is_anipoint()` when
coordinates are needed. Each frame's metadata declares column roles as slots:

- **`what$keys`**: identity, recognised `model`, `individual`, `subject`, `track`, `keypoint`. At least one, in any order.
- **`when$index`**: the single column the frame is indexed by, `time` by default. Never a grouping variable.
- **`when$keys`**: temporal *context*, recognised `observation`, `session`, `trial`.
- **`where$position`**: maps each axis role (`x`, `y`, `z`, `rho`, `phi`, `theta`) to the
  column carrying it. The role set is closed; the column names are free.
- **`where$orientation`** (optional): which way the entity faces — `yaw` in 2D, or a unit
  quaternion `qw`, `qx`, `qy`, `qz` in 3D. Declared, never detected from column names.
- Plus an optional `confidence` column.

Roles are detected from the recognised names, or set with
`as_anipoint(variables_what=, variables_when=, variables_where=)`, and adjusted with
`get_`/`set_`/`add_`/`remove_variables()`. A frame is **grouped by `get_keys()`**
(`what$keys` + `when$keys`), and the dplyr methods **preserve the class + metadata**, renames
included, unless a subset drops a key or the index: that gives a plain tibble.

Metadata is read and declared through `get_metadata()` / `set_metadata()`, with flat field
names; never read `attr(x, "metadata")`. **`set_*` only declares.** Changing values uses
`convert_unit_*()` and `reflect_axis()`. Metadata also records **which way the axes point**
(`axis_directions`, `axis_extents`, `handedness`), which is what tells a scene filmed from
above from the same scene filmed through a glass floor. Named **structures** (skeletons,
teams) relate the levels of a variable. Full detail in `reference/aniframe-model.md`.

## Conventions

- **Coordinates are found by role, not by name.** The coordinate system follows from the
  declared axis roles (`get_axes()`, `get_coordinate_system()`, `is_cartesian_2d()`, …), and
  functions read the axes and the index from the frame, so columns may be called anything.
  Do not branch on whether a column is called `z`.
- **Units of angles.** Angles a function derives come back in the frame's `unit_angle`:
  animetric's kinematics and summaries, `as_anijoint()`, anispace's `map_to_*()`. The
  primitives work in radians: `angle_between()`, the `circ_*()` family, `wrap_angle()`, and
  anispace's component converters (`cartesian_to_phi()`, `polar_to_x()`, …). Code that
  computes angles from a frame reads them with `angle_to_rad()` and writes them back with
  `angle_from_rad()`; `convert_unit_angle()` converts the frame and its metadata, declared
  orientation included.
- **Sign of angles.** Directions are written in `(-pi, pi]`, the range `atan2()` gives, and
  signed angles run from `x` toward `y`. `get_angle_direction()` says whether that is
  clockwise or counter-clockwise as viewed. aniread's image-plane readers reflect `y` to point
  up, so their angles run counter-clockwise. To change convention, change
  the coordinates with `reflect_axis()`; the angles follow.
- **Plot methods dispatch on the object**: `plot(anipoint)` → trajectory, `plot(anievent)` →
  events; `plot_circular()` draws an angle column (`course`, a declared `heading`) as a rose
  diagram. Check objects get `plot()`, `summary()` and `print()` methods from anicheck; its
  `plot()` hands off to anivis, and prompts to install it if missing. The checks accept an
  anipoint only.
- **Skeletons are mostly read separately**: `aniread::read_structure()` (or `_deeplabcut()` /
  `_sleap()`) gives an anistructure, attached with `anicore::set_structure()`. A frame reader
  attaches one only when the data file carries it, which today means a SLEAP analysis `.h5`:
  `read_sleap()` attaches it as the `keypoint` structure. DeepLabCut keeps its skeleton in the
  project's `config.yaml`, so its frames still need `read_structure()`. `read_boris()` returns
  an anievent, not an anipoint.
- **Persisting**: `write_aniframe()` to parquet keeps the metadata; CSV and TSV lose it.
  `read_aniframe()` reads parquet only, and restores an anipoint or an anievent — not an
  anisegment or anijoint.
- **Installing**: the packages are on R-universe, not CRAN:
  `install.packages("animovement", repos = c("https://animovement.r-universe.dev", "https://cloud.r-project.org"))`.

## Verifying against source

The API evolves — **do not rely on remembered signatures**. Every package publishes its
documentation as markdown, generated from the source:

- `https://animovement.dev/<package>/llms.txt` — every exported function, grouped, with a
  one-line description and a link to its help page. Start here to find out whether a
  function exists and which package owns it.
- `https://animovement.dev/<package>/reference/<topic>.md` — the full help page, including
  exact signatures and arguments. The topic is usually the function name, but not always:
  `set_variables()` is on `variables.md`, `angle_from_rad()` on `angle_to_rad.md`, the
  `quat_*()` functions on `quaternions.md`. Follow the link in `llms.txt` rather than
  constructing the URL.

**A reference page loading does not mean the function exists.** The site is deployed without
deleting old pages, so pages for removed functions are still served (animetric's
`mean_angle.md`, anispace's `diff_angle.md`). Existence is settled by `llms.txt` or the
package's `NAMESPACE`.

**The site can lag `main`.** On a development install, the installed package's `NAMESPACE`
and the development section of its `NEWS.md` win. Renames and removals are recorded in
`NEWS.md`, so read it when a name you expected is missing.

`reference/packages.md` in this skill is a *map* — it is deliberately incomplete and can
lag the packages. Where it disagrees with the generated docs or the installed package, they
are right.
If the source is checked out locally, that package's `R/`, `NAMESPACE` and `NEWS.md` are
equally authoritative. Either way, confirm arguments and defaults before calling something.
