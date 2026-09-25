# The aniframe data model

**aniframe** is the abstract parent class of every animovement frame. Each concrete class is
a `tibble` subclass (usually a `grouped_df`) whose rows sit at one **grain**, and which
carries **metadata** describing its columns. The package that defines them is **anicore**.

| Class | One row per | Value columns | Made by |
|---|---|---|---|
| `anipoint` | point × time | coordinates (`x`, `y`, `z`, or polar), optional orientation | `anipoint()`, `as_anipoint()`, readers |
| `anisegment` | segment × time | `length`, unit direction `ux`, `uy` (`uz`) | `as_anisegment()` |
| `anijoint` | joint × time | `angle` | `as_anijoint()` |
| `anievent` | event (bout or instant) | `channel`, `type`, `label`, `start`, `stop` | `anievent()`, `as_anievent()`, `to_anievent()` |

Class vectors are `c("anipoint", "aniframe", ...)` and so on. `is_aniframe()` is TRUE for
**any** of them, including an anievent. Code that needs coordinates must test the grain,
`is_anipoint()` / `ensure_is_anipoint()`, not the family. When branching, test the specific
class first.

## Column roles: the `variables` category

Roles are declared in metadata, as lists of named **slots**:

| Role | Slots | Recognised columns |
|---|---|---|
| `what` (identity) | `keys` | `model`, `individual`, `subject`, `track`, `keypoint` |
| `when` (time) | `index` (anipoint, anisegment, anijoint) or `interval` (anievent: `start`, `stop`), plus `keys` (context) | `time`; `observation`, `session`, `trial` |
| `where` (space) | anipoint: `position`, optional `orientation`; anisegment: `length`, `direction`; anijoint: `angle` | `x`, `y`, `z`, `rho`, `phi`, `theta` |
| `event` (anipoint only) | `state`, `point` | per-frame event columns, encoded by `to_anievent()` |

One family of accessors reads and declares them:

```r
get_variables(x)                       # the whole category
get_variables(x, "when")               # a role's columns (index + keys)
get_variables(x, "when", "keys")       # one slot
get_keys(x)                            # the grouping set: what$keys + when$keys
set_variables(x, when = list(keys = "trial"))    # replaces the named slots
add_variables(x, what = "id")                     # a character vector = the main slot
remove_variables(x, what = "keypoint")
get_index(x); set_index(x, "frame")
get_axes(x)                            # where$position, named by axis role
```

- **The index is not a key.** `when$keys` is the surrounding *context* (which session, which
  trial) and is part of what the frame is grouped by. The index places each row within that
  context, and is never a grouping variable.
- **Column names are free; roles are fixed.** A frame indexed by `frame_number`, with
  coordinates in `u`/`v`, is valid. `set_variables(x, where = c(x = "u", y = "v"))` says
  which column carries which **axis role**. The role set (`x`, `y`, `z`, `rho`, `phi`,
  `theta`) is closed, and the coordinate system is derived from which roles are present.
- **Declaring restructures.** Columns are retyped, reordered and regrouped, so the metadata
  and the frame cannot drift. A column must exist before it is declared. `set_metadata()`
  refuses the `variables` category for this reason.
- **The order of the `what` keys is not a hierarchy.** It is only the order detection emits.
  Do not infer a "finest" identity from it; ask which level is meant.
- **Orientation** goes in `where$orientation`: `c(yaw = "heading")` in 2D, or a unit
  quaternion `c(qw = , qx = , qy = , qz = )` (Hamilton, scalar first) in 3D. Direction of
  travel is not orientation; keep it as an ordinary derived column.

## Construction

```r
as_anipoint(data, metadata = list(), variables_what = NULL, variables_when = NULL,
            variables_where = NULL, index = NULL)
```

- With `NULL`, roles are detected from the recognised names. A frame needs at least one
  identity variable; if none is found, `keypoint = "centroid"` is injected.
- Rows are ordered by the keys, then the index.

## Grouping semantics

The frame is grouped by `get_keys()`: identity plus temporal context, never the index. Each
trajectory is its own group, so operations stay within a track. The dplyr methods preserve
the class and metadata. Regrouping is allowed but warns. Operations that derive a quantity
from successive rows (speed, path length) need one trajectory per group.

## Metadata

Stored as a tree of categories: `recording`, `time`, `space`, `variables`, `structure`, and
`spec_version` (aniframe 3.0.0 / anievent 1.0.0). **Access is flat.**

```r
get_metadata(x, "sampling_rate")      # a field, wherever it lives
get_metadata(x, "space")              # a whole category
md <- get_metadata(x); md$sampling_rate <- 30; set_metadata(x, metadata = md)
set_metadata(x, sampling_rate = 30, unit_space = "mm")
```

- **Never read `attr(x, "metadata")`.** The storage layout is anicore's to change, and the
  shared CI refuses raw reads outside anicore. `names(get_metadata(x))` lists categories,
  not fields.
- **`set_*` only declares; it never changes a value.** Operations that change values have
  their own verbs:
  - **Units:** `unit_space`, `unit_time`, `unit_angle`. Declare with `set_metadata()`. To
    rescale the data use `convert_unit_space()`, `convert_unit_time()` or
    `convert_unit_angle()`. Converting from `px`, `frame` or `unknown` needs a
    `calibration_factor`; converting from `frame` can use a declared `sampling_rate`
    instead.
  - **Sampling:** `sampling_rate` is declared. `get_sampling_interval()` measures the index,
    and `is_sampling_regular()` is computed on demand. Also `start_datetime`.
  - **Orientation of the axes:**
    - `axis_directions` holds one of `right`/`left`/`up`/`down`/`back`/`forward` per role,
      set with `set_axis_directions()`, which only declares.
    - `axis_extents` holds how far each axis runs.
    - `reflect_axis(x, "y")` *turns an axis over*: it reflects the column around its extent
      (or negates it), flips the declared direction, and reflects any orientation columns.
    - `get_handedness()` and `get_angle_direction()` are derived; declare handedness with
      `set_metadata(x, handedness = "right")`.
    - This is what tells a scene filmed from above from the same scene filmed through a
      glass floor.
  - **Reference frame:** `reference_frame`, one of `"allocentric"`, `"egocentric"` or
    `"none"`.
- An **anievent has no `space` category**; its spatial fields read `NULL`.

## Structures

An `anistructure()` records how the levels of one variable relate. It has **points**,
directed **segments** (`from` → `to`, optional expected `length`) and **joints** (pairs of
segments, an optional `axis`, and per-DoF `min`/`max`/`rest` limits). Its `root` names a
point. Limits and lengths are recorded, never enforced against the data.

A frame can hold several **named** structures, including several over the same variable:

```r
x |>
  set_structure(example_structure()) |>                           # name defaults to "keypoint"
  set_structure(anistructure(points = c("1", "2")), variable = "individual", name = "pair")
get_structure(x, "keypoint")$segments
remove_structure(x, "pair")
```

Whether structures grow into full body models (reference pose, rigid bodies, typed joints,
markers) is undecided: animovement/anicore#164.

## Converting between grains

```r
seg <- as_anisegment(af, structure = "keypoint")  # length + unit direction per segment
jnt <- as_anijoint(seg)                           # one angle per joint (or as_anijoint(af))
af2 <- as_anipoint(seg, root = af)                # rebuild positions from the root's trajectory
angle_between(u, v, axis = NULL)                  # the vector maths behind joint angles
```

- **Joint angles** are 0 when the two segments are aligned. In 2D they are signed, turning
  from `a` to `b`. In 3D they are the included angle, or signed about the joint's `axis`.
- **Rebuilding positions** from segments is useful after editing them, e.g. holding lengths
  constant: every point except the root moves to agree.
- **A joint frame is not invertible.** Pose representation and inverse kinematics:
  animovement/anicore#162.

## anievent

For discrete events (bouts, states) rather than continuous tracks. `to_anievent()` encodes
an anipoint's declared `event` columns into bouts. Its `when` role has an `interval` slot
(`start`, `stop`) instead of an index. The `geom_event_*()` and `plot_events()` support is
in anivis.

## Persisting

`aniread::write_aniframe()` / `read_aniframe()` round-trip a frame and its metadata through
parquet (via arrow). Metadata is R-serialised, so non-R readers cannot parse it.
