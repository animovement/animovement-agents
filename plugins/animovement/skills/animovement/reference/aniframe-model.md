# The aniframe data model

An **aniframe** is a `tibble` subclass (also a `grouped_df`) that carries **metadata**
tagging each column with a role. Everything in the stack consumes and returns aniframes.

## Column roles (metadata)

Set at construction and stored in metadata; retrieved with
`aniframe::get_metadata(data)` (e.g. `get_metadata(data, "variables_where")`).

| Role | Metadata key | Recognised columns |
|---|---|---|
| Identity | `variables_what` | `model`, `individual`, `track`, `keypoint` |
| Temporal | `variables_when` | `time` (required), `observation`, `session`, `trial` |
| Spatial | `variables_where` | `x`, `y`, `z` (Cartesian) or `rho`, `phi`, `theta`, … |

Plus an optional **`confidence`** column (tracker likelihood).

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
- If no `keypoint` column exists, one is added as `"centroid"` (single-point trackers).
- The **coordinate system** is inferred from which `variables_where` are present
  (x/y → 2D Cartesian, +z → 3D, rho/phi → polar, …).
- Required columns are validated; column order is standardised (what, when, where, confidence, rest).

## Grouping semantics

On construction the aniframe is **grouped by identity** — every `variables_what` column
plus every non-`time` `variables_when` column. This keeps each trajectory (per individual,
per keypoint, per session, …) as its own group, so operations stay within-track.

The dplyr methods for aniframe (`group_by`, `mutate`, `summarise`, `filter`, `arrange`)
**preserve the aniframe class and metadata**, so you can pipe through standard dplyr without
losing the structure. Ungrouping is intentionally noisy for *users* (it makes cross-track
mistakes easier) — keep operations grouped unless you have a reason not to.

## Metadata beyond roles

`set_metadata()` / `get_metadata()` also carry, among others:

- **Units:** `unit_space`, `unit_time` (set via `set_unit_space()` / `set_unit_time()`;
  `set_unit_space(to_unit, calibration_factor)` rescales, factor `1` just relabels).
- **`start_datetime`**, **`sampling_rate`** (`set_sampling_rate()`), origin (`set_origin()`), y-height (`set_y_height()`).
- **Connections** (the skeleton graph for pose data): `set_connections(data, connections, variable = "keypoint")`,
  read back with `get_connections()`. Connections travel in metadata; note that when written
  to parquet they are R-serialised, so non-R readers can't parse them (supply the skeleton
  separately, e.g. a YAML, if a non-R tool needs it).

## anievent — the companion class

For discrete events (bouts, states) rather than continuous tracks, aniframe provides
**anievent** (`anievent()`, `as_anievent()`, `to_anievent()`), with its own validators and
the `geom_event_*()` / `plot_events()` support in anivis.

## Persisting

`aniread::write_aniframe()` / `read_aniframe()` round-trip an aniframe (parquet backend,
via the arrow package) including its metadata.
