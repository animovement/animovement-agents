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

| Package | Owns | Verb prefixes |
|---|---|---|
| **animovement** | The metapackage. `library(animovement)` attaches the whole suite and resolves versions; it owns no analysis functions of its own | — |
| **anicore** | The core data structures (aniframe, anievent), metadata, units, axes, connections, grouping | `as_` `is_` `get_` `set_` `add_` `remove_` `ensure_` |
| **aniread** | Reading tracker output into an aniframe + writing it back | `read_` `write_` |
| **aniprocess** | Signal processing: NA masking, gap filling, smoothing/filtering | `filter_` `replace_na_` `find_` |
| **animetric** | Metrics: kinematics, tortuosity/sinuosity, nearest-neighbour, summaries | `calculate_` `compute_` `summarise_`/`summarize_` |
| **anivis** | Plot methods, themes, palettes, colour scales | `plot_` `theme_` `scale_` `geom_` `palette_` |
| **anicheck** | Data-quality diagnostics (return check objects; plotted via anivis) | `check_` |
| **anispace** | Coordinate-system transforms, rotation, translation, egocentric | `map_to_` `transform_` `rotate_` `translate_` |

See `reference/packages.md` for the key exported functions per package.

## A typical pipeline

```r
library(animovement)   # attaches the whole suite

af <- read_sleap(path) |>          # aniread    — into an aniframe
  check_confidence() |>            # anicheck   — inspect before cleaning (returns a check object)
  filter_na_confidence() |>        # aniprocess — mask low-confidence points to NA
  replace_na_linear() |>           # aniprocess — fill the gaps
  filter_sgolay() |>               # aniprocess — smooth
  calculate_kinematics()           # animetric  — speed, acceleration, …

plot_trajectory(af)                # anivis
```

That arc — read → check → clean → transform → measure → plot — is the shape of
nearly every task here. **The arguments above are omitted deliberately**: most of these
functions take parameters with no safe default (thresholds, window sizes), so look each
one up rather than copying this as working code.

## Naming traps

- **`filter_*` means signal filtering, not row subsetting.** `filter_na_confidence()`
  masks bad points to NA and `filter_sgolay()` smooths; neither drops rows. `dplyr::filter()`
  also works on an aniframe and *does* subset rows. Read which one is meant.
- **Angle helpers are split.** `wrap_angle()`, `unwrap_angle()`, `deg_to_rad()` and
  `rad_to_deg()` are in **anicore**; `diff_angle()` and `calculate_angular_difference()` are
  in **anispace**; `mean_angle()` and `median_angle()` are in **animetric**.
- **`calculate_*` and `compute_*` both appear in animetric** and are not interchangeable;
  each function has one spelling (`calculate_nnd()` and `compute_nnd()` both exist, most
  others do not pair up).
- **Both British and American spellings** are exported for much of the suite
  (`summarise`/`summarize`, `colour`/`color`) — but not universally, so check rather than assume.
- **An aniframe stays grouped by identity and temporal context.** Operations run
  within-track by design; if a result looks per-individual when you expected it pooled, that
  is why. Regrouping warns, and operations that derive from successive rows (speed, path
  length) refuse a grouping that pools several trajectories.
- **The identity order is not a hierarchy.** `variables_what` is not ordered coarse to fine,
  identity variables need not nest, and there is no "finest" level to infer. Where a function
  collapses one, it asks which.

## The aniframe data model

An **aniframe** is a `tibble` subclass carrying **metadata** that assigns each column a role:

- **`variables_index`** — the single column the frame is indexed by, `time` by default. Not
  one of the `variables_when`, and never a grouping variable.
- **`variables_what`** — identity: recognised `model`, `individual`, `subject`, `track`, `keypoint`. At least one, in any order.
- **`variables_when`** — temporal *context*: recognised `observation`, `session`, `trial`.
- **`variables_where`** — spatial, derived from `axes`, which maps each axis role (`x`, `y`,
  `z`, `rho`, `phi`, `theta`) to the column carrying it. The role set is closed; the column
  names are free, so coordinates may be called anything.
- Plus an optional `confidence` column.

Roles are set explicitly via `as_aniframe(variables_what=, variables_when=, variables_where=)`
or auto-detected from the recognised names, and can be adjusted afterwards with the
`get_`/`set_`/`add_`/`remove_variables_*()` accessors. An aniframe is **grouped by
`variables_what` + `variables_when`** on construction, and the dplyr methods
(`group_by`/`mutate`/`summarise`/`filter`) **preserve the aniframe class + metadata**.

Metadata also records **which way the axes point** — `axis_directions`, `axis_extents` and
`handedness` — which is what tells a scene filmed from above from the same scene filmed
through a glass floor. Full detail, including units, sampling, connections and anievent, in
`reference/aniframe-model.md`.

## Conventions

- **Verb-first names** (`read_*`, `filter_*`, `calculate_*`, `plot_*`, …); the verb tells you the package (table above), so function names are largely predictable.
- **2D vs 3D** is handled by the presence of a `z` (or third `where`) column — most functions branch on it internally.
- Plot methods dispatch on the object: `plot(aniframe)` → trajectory; check objects have their own `plot()` methods in anivis.

## Verifying against source

The API evolves — **do not rely on remembered signatures**. Every package publishes its
documentation as markdown, generated from the source, so it cannot drift from the installed
package:

- `https://animovement.dev/<package>/llms.txt` — every exported function, grouped, with a
  one-line description. Start here to find out whether a function exists and which package
  owns it.
- `https://animovement.dev/<package>/reference/<function>.md` — the full help page for one
  function, including its exact signature and arguments.

`reference/packages.md` in this skill is a *map* — it is deliberately incomplete and can
lag the packages. Where it and the generated docs disagree, the generated docs are right.

If the source is checked out locally, that package's `R/` and `NAMESPACE` are equally
authoritative. Either way, confirm arguments and defaults before calling something.
