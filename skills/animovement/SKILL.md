---
name: animovement
description: >-
  Use when reading, cleaning, analysing, or plotting animal movement / pose
  tracking data with the animovement R stack (aniframe, aniread, aniprocess,
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
| **aniframe** | The core data structures (aniframe, anievent), metadata, units, connections, grouping | `as_` `is_` `get_` `set_` `add_` `remove_` `ensure_` |
| **aniread** | Reading tracker output into an aniframe + writing it back | `read_` `write_` |
| **aniprocess** | Signal processing: NA masking, gap filling, smoothing/filtering | `filter_` `replace_na_` `find_` |
| **animetric** | Metrics: kinematics, tortuosity/sinuosity, nearest-neighbour, summaries | `calculate_` `compute_` `summarise_`/`summarize_` |
| **anivis** | Plot methods, themes, palettes, colour scales | `plot_` `theme_` `scale_` `geom_` `palette_` |
| **anicheck** | Data-quality diagnostics (return check objects; plotted via anivis) | `check_` |
| **anispace** | Coordinate-system transforms, rotation, translation, egocentric, **and all angle helpers** | `map_to_` `transform_` `rotate_` `translate_` |

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
- **Angle helpers live in anispace, not animetric** — `wrap_angle()`, `unwrap_angle()`,
  `diff_angle()`, `calculate_angular_difference()`. This one is easy to get backwards
  because they are used most often alongside metrics.
- **`calculate_*` and `compute_*` both appear in animetric** and are not interchangeable;
  each function has one spelling (`calculate_nnd()` and `compute_nnd()` both exist, most
  others do not pair up).
- **Both British and American spellings** are exported for much of the suite
  (`summarise`/`summarize`, `colour`/`color`) — but not universally, so check rather than assume.
- **An aniframe stays grouped by identity.** Operations run within-track by design; if a
  result looks per-individual when you expected it pooled, that is why.

## The aniframe data model

An **aniframe** is a `tibble` subclass carrying **metadata** that assigns each column a role:

- **`variables_what`** — identity: recognised `model`, `individual`, `track`, `keypoint`.
- **`variables_when`** — temporal: `time` (required) plus recognised `observation`, `session`, `trial`.
- **`variables_where`** — spatial: `x`/`y`/`z` (Cartesian) or `rho`/`phi`/`theta` etc.; the coordinate system is inferred from which are present.
- Plus an optional `confidence` column.

Roles are set explicitly via `as_aniframe(variables_what=, variables_when=, variables_where=)`
or auto-detected from the recognised names, and can be adjusted afterwards with the
`get_`/`set_`/`add_`/`remove_variables_*()` accessors. An aniframe is **grouped by identity**
(all `what` + non-time `when`) on construction, and the dplyr methods
(`group_by`/`mutate`/`summarise`/`filter`) **preserve the aniframe class + metadata**.
Full detail — metadata keys, units, connections, anievent — in `reference/aniframe-model.md`.

## Conventions

- **Verb-first names** (`read_*`, `filter_*`, `calculate_*`, `plot_*`, …); the verb tells you the package (table above), so function names are largely predictable.
- **2D vs 3D** is handled by the presence of a `z` (or third `where`) column — most functions branch on it internally.
- Plot methods dispatch on the object: `plot(aniframe)` → trajectory; check objects have their own `plot()` methods in anivis.

## Writing documentation here

If you are adding or editing roxygen documentation, follow the style guide in
[CONTRIBUTING.md](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md#writing-function-documentation).
It is short, and the rules are not the usual ones — the house style is deliberately terse.

Two habits worth naming, because they are the ones assistants fall into:

- **Do not pad.** No "This function...", no restating the function name in prose, no closing
  summary repeating the description, no comments in examples narrating what the next line does.
  A one-sentence description is finished, not unfinished.
- **Do not reach for `\dontrun{}`** to make an example safe. It hides the example from
  `R CMD check`, so it rots unnoticed. If an example cannot run, that is usually a sign it needs
  smaller inputs, not a wrapper — `aniframe::example_aniframe()` builds a valid frame of any shape
  in one line.

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
