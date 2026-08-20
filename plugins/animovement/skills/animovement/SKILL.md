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
a function lives, then **verify its signature in the source** before calling it
(see *Verifying against source*).

## The packages (where things live)

| Package | Owns | Verb prefixes |
|---|---|---|
| **aniframe** | The core data structures (aniframe, anievent), metadata, units, connections, grouping | `as_` `is_` `get_` `set_` `ensure_` |
| **aniread** | Reading tracker output into an aniframe + writing it back | `read_` `write_` |
| **aniprocess** | Signal processing: NA masking, gap filling, smoothing/filtering | `filter_` `replace_na_` `find_` |
| **animetric** | Metrics: kinematics, tortuosity/sinuosity, nearest-neighbour, angles, summaries | `calculate_` `compute_` `summarise_`/`summarize_` |
| **anivis** | Plot methods, themes, palettes, colour scales | `plot_` `theme_` `scale_` `geom_` `palette_` |
| **anicheck** | Data-quality diagnostics (return check objects; plotted via anivis) | `check_` |
| **anispace** | Coordinate-system transforms (Cartesian/polar/…), rotation, translation, egocentric | `map_to_` `transform_` `rotate_` `translate_` |

A typical flow: `read_*` (aniread) → `filter_*`/`replace_na_*` (aniprocess) →
`calculate_*` (animetric) → `plot_*` (anivis) / `check_*` (anicheck), with
`aniframe` providing the object + metadata throughout.

See `reference/packages.md` for the key exported functions per package.

## The aniframe data model

An **aniframe** is a `tibble` subclass carrying **metadata** that assigns each column a role:

- **`variables_what`** — identity: recognised `model`, `individual`, `track`, `keypoint`.
- **`variables_when`** — temporal: `time` (required) plus recognised `observation`, `session`, `trial`.
- **`variables_where`** — spatial: `x`/`y`/`z` (Cartesian) or `rho`/`phi`/`theta` etc.; the coordinate system is inferred from which are present.
- Plus an optional `confidence` column.

Roles are set explicitly via `as_aniframe(variables_what=, variables_when=, variables_where=)`
or auto-detected from the recognised names. An aniframe is **grouped by identity**
(all `what` + non-time `when`) on construction, and the dplyr methods
(`group_by`/`mutate`/`summarise`/`filter`) **preserve the aniframe class + metadata**.
Full detail — metadata keys, units, connections, anievent — in `reference/aniframe-model.md`.

## Conventions

- **Verb-first names** (`read_*`, `filter_*`, `calculate_*`, `plot_*`, …); the verb tells you the package (table above), so function names are largely predictable.
- **Both spellings** are often exported (`summarise`/`summarize`, `colour`/`color`).
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

If the source is checked out locally, that package's `R/` and `NAMESPACE` are equally
authoritative. Either way, confirm arguments and defaults before calling something.
