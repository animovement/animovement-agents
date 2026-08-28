# The aniframe data model

An **aniframe** is a `tibble` subclass (also a `grouped_df`) that carries **metadata**
tagging each column with a role. Everything in the stack consumes and returns aniframes.
The class is `aniframe`; the package that defines it is **anicore**.

## Column roles (metadata)

Set at construction and stored in metadata; retrieved with
`anicore::get_metadata(data)` (e.g. `get_metadata(data, "variables_where")`).

| Role | Metadata key | Recognised columns | Accessor |
|---|---|---|---|
| Index | `variables_index` | exactly one, `time` by default | `get_index()` / `set_index()` |
| Identity | `variables_what` | `model`, `individual`, `subject`, `track`, `keypoint` | `get_variables_what()` / `set_` / `add_` / `remove_` |
| Temporal context | `variables_when` | `observation`, `session`, `trial` | same four verbs |
| Spatial | `variables_where` | derived from `axes` | `get_variables_where()`, or `get_axes()` for the roles |

Plus an optional **`confidence`** column (tracker likelihood).

**The index is not one of the `variables_when`.** `variables_when` is the surrounding
*context* — which session, which trial — and is what the frame is grouped by. The index
positions each row within that context, so it is never a grouping variable. Detection finds
`time` and assigns it as the index, not as temporal context.

**Column names are free; roles are fixed.** A frame indexed by `frame_number` and carrying
coordinates in `u`/`v` is a valid aniframe — the constructor requires *the column with that
role*, not a column with a particular name.

### Axis roles

`axes` maps axis role to column: `c(x = "u", y = "v")`. The **role set is closed** — `x`,
`y`, `z`, `rho`, `phi`, `theta` — which is what keeps transformations between coordinate
systems well defined, while the column names carrying them are free. `variables_where` names
the same columns without their roles, and is derived from this. Read with `get_axes()`,
change with `set_axes()`.

## Construction & role assignment

```r
as_aniframe(
  data,
  variables_what  = NULL,   # NULL -> auto-detect from recognised names
  variables_when  = NULL,
  variables_where = NULL
)
```

- With `NULL`, roles are auto-detected from the recognised names above.
- **`variables_what` is not a requirement to carry `individual` and `keypoint`.** The rule is
  that a frame has at least one identity variable, whichever it happens to be. If none is
  found, `keypoint = "centroid"` is injected for single-point trackers.
- **The order of `variables_what` is not a hierarchy.** Identity variables need not nest, and
  a position in the vector does not mean a level — the order is what detection emits, nothing
  more. Do not infer a "finest" identity from it; ask the caller which level they mean.
- The **coordinate system** is derived from which axis roles are present (x/y → 2D Cartesian,
  +z → 3D, rho/phi → polar, …).
- Required columns are validated; column order is standardised, rows ordered by
  `variables_when` then the index.

## Grouping semantics

The frame is grouped by **`variables_what` + `variables_when`** — identity and temporal
context, not the index. This keeps each trajectory (per individual, per keypoint, per
session, …) as its own group, so operations stay within-track.

The dplyr methods for aniframe (`group_by`, `mutate`, `summarise`, `filter`, `arrange`)
**preserve the aniframe class and metadata**, so you can pipe through standard dplyr without
losing the structure. Regrouping is allowed but warns: the frame's grouping and its
declaration then disagree. Some operations refuse it outright — anything deriving a quantity
from successive rows (speed, path length) needs one trajectory per group, and pooling several
would measure the distance *between* them as movement.

## Metadata beyond roles

`set_metadata()` / `get_metadata()` also carry, among others:

- **Units:** `unit_space`, `unit_time`, `unit_angle` (`set_unit_space()` / `set_unit_time()` /
  `set_unit_angle()`; `set_unit_space(to_unit, calibration_factor)` rescales, factor `1` just
  relabels).
- **Sampling:** `sampling_rate` (`set_sampling_rate()`), `sampling_interval` measured from the
  data (`get_sampling_interval()`), and `is_sampling_regular()`, computed on demand because
  dropping rows changes the answer. Plus `start_datetime`.
- **Orientation** — which way the axes point, and what follows from it:
  - `axis_directions` — one of `"right"`, `"left"`, `"up"`, `"down"`, `"back"`, `"forward"`
    per axis role, read from where the recording was made. `set_axis_directions()` *reflects*
    an axis turned over, it does not merely relabel it.
  - `axis_extents` — how far each axis runs, e.g. the video frame height for `y`. This is what
    an axis is reflected around; an axis with no extent is negated instead.
  - `handedness` and the derived `get_angle_direction()` follow from three declared axis
    directions; `set_handedness()` states the convention without spelling the axes out.

  This is what distinguishes a scene filmed from above from the same scene filmed through a
  glass floor: identical `x` and `y`, opposite rotations.
- **Reference frame:** `reference_frame` — `"allocentric"`, `"egocentric"` or `"none"`.
- **Connections** (the skeleton graph for pose data): `set_connections(data, connections, variable = "keypoint")`,
  read back with `get_connections()`. Connections travel in metadata; note that when written
  to parquet they are R-serialised, so non-R readers can't parse them (supply the skeleton
  separately, e.g. a YAML, if a non-R tool needs it).
- **`spec_version`** — semantic versions of the data contract, one per class.

The spatial fields all have a way of saying "not applicable", because the metadata substrate
is shared with `anievent()`, which has no spatial component: `unit_space`, `unit_angle` and
`reference_frame` take `"none"`, `coordinate_system` takes `"unknown"`, and `axes`,
`axis_directions` and `axis_extents` are empty.

## anievent — the companion class

For discrete events (bouts, states) rather than continuous tracks, anicore provides
**anievent** (`anievent()`, `as_anievent()`, `to_anievent()`), with its own validators and
the `geom_event_*()` / `plot_events()` support in anivis. Event columns are declared through
`variables_event`, a list of `state` (interval-valued) and `point` (instantaneous) columns.

## Persisting

`aniread::write_aniframe()` / `read_aniframe()` round-trip an aniframe (parquet backend,
via the arrow package) including its metadata.
