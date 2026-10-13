# Reading tracking data

Read this when reading a file into R: which reader takes it, what the reader records, and what
to declare afterwards. Each reader's page (`https://animovement.dev/aniread/reference/<reader>.md`)
has its arguments, and `?read_dataset` has a *Time* section with every source's convention.
This describes the development builds; `reference/versions.md` covers older ones.

## How to choose

1. **`read_dataset(path)`** detects the tool from the file and returns whatever that reader
   returns; extra arguments pass through to the reader. `detect_source(path)` says what it
   decided without reading.
2. **`read_dataset(path, source = "...")`** when detection can't tell or guesses wrong. The
   names are those in `get_supported_sources()`, which are not always the reader's suffix.
3. **The reader itself** (`read_sleap()`, …) when you know the tool; same result.
4. **Nothing fits**: `read_custom(path, cols, variables_what, variables_when, variables_where,
   index, metadata)` maps columns onto roles, or read the table yourself and `as_anipoint()` it
   (`reference/aniframe-model.md`).

Then **look at what you got**: printing the frame shows identity levels, sampling rate and time
span; `get_metadata(x)` shows `unit_time`, `sampling_rate`, `unit_space` and the axis
directions. Declare what is missing before measuring (`reference/workflows.md`, *Units*).

## By tool

| Tool | Files | Reader (`source =`) | Notes |
|---|---|---|---|
| DeepLabCut | `.csv`, `.h5`, multi-animal, `*_el.h5` tracklets, 3D | `read_deeplabcut()` (`"deeplabcut"`) | Frames, px, no rate. `likelihood` becomes `confidence`. Multi-animal files get `individual`; unique bodyparts are individual `"single"`. A CSV is detected as `"deeplabcut/lightningpose"`. 3D: no flip, `confidence` `NA` |
| Lightning Pose | `.csv` | `read_lightningpose()` (`"lightningpose"`) | DeepLabCut's layout. Ensemble Kalman output: only `x`, `y`, `likelihood` are read |
| SLEAP | analysis `.h5` or analysis `.csv` | `read_sleap()` (`"sleap"`) | Frames (`frame_idx` from 0), px, no rate. Individuals named by track. The `.h5` attaches the skeleton and the SLEAP version. Scores can exceed 1. Not the `.slp` project: export the analysis file |
| idtracker.ai | `.h5`, `trajectories.csv`, `trajectories_tidy.csv`, `.parquet` | `read_idtracker()` (`"idtrackerai"`) | `.h5`: frames, with the rate and frame size from the file. CSV: seconds when idtracker.ai knew the frame rate; pass `video_height`. `path_probabilities` for identity probabilities |
| TRex | `.npz` (one per individual: pass them all), `.csv` | `read_trex()` (`"trex"`) | Seconds; positions in **cm**, by TRex's own `cm_per_pixel` (a 30 cm-wide image unless set). `.npz` has the rate, identities, pose and confidence. Declares `yaw` when the export has TRex's `ANGLE` |
| movement (Python) | `.nc`, `.h5` | `read_movement()` (`"movement"`) | Whatever movement saved: seconds with a rate, or frames |
| Anipose | `.csv` | `read_anipose()` (`"anipose"`) | 3D; `unit_space` argument, `"mm"` by default |
| FreeMoCap | v1 and v2 exports, `.csv`, `.parquet` | `read_freemocap()` (`"freemocap"`) | 3D; identity includes `model`; `format` and `trajectory` arguments |
| C3D motion capture | `.c3d` | `read_c3d()` (`"c3d"`) | 3D; rate and units from the file |
| TrackMate | `.xml` | `read_trackmate()` (`"trackmate"`) | Keyed by `track`; units and frame interval from the file; dividing tracks split, with a `parent` column |
| Bonsai | `.csv` | `read_bonsai()` (`"bonsai"`) | Seconds from the first row; centroid |
| AnimalTA | `.csv` (three layouts) | `read_animalta()` (`"animalta"`) | Seconds; an `arena` identity key; positions in AnimalTA's scale, which the file doesn't record: declare `unit_space` |
| FastTrack | `.txt` | `read_fasttrack()` (`"fasttrack"`) | Head, body and tail keypoints |
| OCTRON | `.csv` | `read_octron()` (`"octron"`) | Centroid; frame height from the file header; its blob angle is axial and stays undeclared |
| FicTrac | `.dat` | `read_fictrac()` (`"fictrac"`) | Seconds; FicTrac's heading declared as `yaw`; `ball_radius` scales the path |
| Trackball (optical-flow sensors) | one `.csv` per sensor | `read_trackball()` (`"trackball_bonsai"`) | Needs `sampling_rate` and `setup`. Positions are integrated steps: smooth, and mask with `"range"`, using `on_deltas = TRUE` |
| BORIS | aggregated or tabular `.csv`, `.tsv` | `read_boris()` (`"boris"`) | Returns an **anievent** (bouts), not positions |
| A frame saved earlier | `.parquet` | `read_aniframe()` (`"aniframe"`) | Restores the class and metadata |

`get_sample_data("<source>")` downloads a real example file for most sources and returns its
path, which is the quickest way to try a reader.

## What readers have in common

- **Time.** `time` is time since the video's first frame: frame numbers from 0, or seconds from 0.
  A file that starts later keeps its offset.
- **Image coordinates.** Readers of video-based tools flip y so it points up (`axis_directions`
  says `y = up`), so a trajectory plot looks like the video. The flip is around the frame
  height: from the file when it records one, else `video_height`, else the largest y, which is
  only approximately right. Don't flip y yourself afterwards.
- **No calibration.** Pixels stay pixels until `convert_unit_space()`, and most video trackers
  record no frame rate either. The exceptions record their own units: TRex (cm), C3D, TrackMate
  and FicTrac (given `ball_radius`); Anipose's are its calibration's (`unit_space`, mm by
  default).
- **Optional packages.** HDF5 readers need rhdf5 (Bioconductor), Parquet needs arrow. A reader
  offers to install what it needs; `animovement_install_suggested()` installs them all. With
  Pixi, `pixi add bioconductor-rhdf5` (bioconda channel).
- **Skeletons.** A frame carries one only when the data file does (a SLEAP `.h5`). Otherwise
  `read_structure("config.yaml")` (DeepLabCut) or `read_structure("project.slp")` (SLEAP), then
  `set_structure(x, skeleton)`. Skeletons are needed by `check_segment_length()`,
  `mask_na_segment_length()`, `as_anisegment()` and `as_anijoint()`.

## Writing

- `write_dataset(x, "file.parquet")` (or `write_aniframe()`) keeps the class and metadata;
  `read_dataset()` or `read_aniframe()` gives the frame back. Saving cleaned data this way
  avoids re-parsing and re-declaring.
- A `.csv` is written as a plain table and loses the metadata. `write_dataset(by = "individual")`
  writes one file per group.
- `write_intracktive()` writes inTRACKtive's CSV (`format = "intracktive"` in
  `write_dataset()`).
