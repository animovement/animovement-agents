# Evals for the animovement skill

Cases for the `animovement` skill: analysing movement data with the packages. Every case name
starts with `user-`, so `--case 'user-*'` runs this suite alone. How to run the cases, and how
the graders are written, is in [`../README.md`](../README.md). For one case:

```sh
claude plugin eval . --scaffold --runs 1 --ablation none --no-publish --case user-read-deeplabcut
```

| Case | Request | A correct agent |
|---|---|---|
| `user-read-deeplabcut` | Load one mouse's DeepLabCut CSV and plot it | `library(animovement)`, `read_dataset()` or `read_deeplabcut(video_height = 720)`, `plot()` or `plot_trajectory()`; mentions frames and pixels. Nothing through `animovement::`, no invented names |
| `user-mask-low-confidence` | Drop likelihood < 0.9, fill gaps up to 10 frames, smooth; 50 fps | `mask_na_across("confidence", threshold = 0.9)`, `replace_na_across(max_gap = 10)`, `set_metadata(sampling_rate = 50)` before `filter_across("sgolay")`, in that order. No `dplyr::filter()` on confidence, no `filter_na_*()` |
| `user-speed-units` | Median speed "about 10", wanted in cm/s; 25 fps, 1000 px = 50 cm | Says it is px per frame; `set_metadata(sampling_rate = 25) \|> convert_unit_time("s") \|> convert_unit_space("cm", calibration_factor = 0.05)` before `add_kinematics()` (about 12.5 cm/s) |
| `user-renamed-functions` | A script from the August 2026 releases stops with `could not find function "set_unit_space"` | Rewrites every step: `set_metadata()` + `convert_unit_time()`, `convert_unit_space()`, `mask_na_across()`, `add_kinematics()`, `summarise_aniframe()`, and plots `course` instead of `heading` |
| `user-per-animal-summary` | One row per mouse (of three): total distance and median speed | One trajectory per mouse (the `centre` keypoint, or `add_point(across = "keypoint")`), then `summarise_path()` and `add_kinematics()` + `summarise_aniframe()`, joined. Never `group_by(individual)` across keypoints |
| `user-metapackage-namespace` | `'read_dataset' is not an exported object from 'namespace:animovement'` in a Quarto report | The metapackage exports no analysis functions: `library(animovement)` and bare calls, or `aniread::`, `anicheck::`, `anivis::`, `animetric::` for each. No reinstall |
| `user-body-weights-negative` | Mean and SE of body weight per genotype and week, plus growth curves | dplyr and ggplot2; the skill doesn't load |
| `user-package-work-negative` | In an aniprocess checkout: format-suggest fails, what PR title? | air, and a `feat(aniprocess): …` title; the user skill doesn't load, `animovement-dev` does |

The positive cases also report whether the skill fired (`skill-used`).
`user-package-work-negative` reports whether `animovement-dev` fired (`dev-skill-used`), an
indicator of the split between the two skills; its answer graders check conventions that skill
and the checkout's `AGENTS.md` teach. In `user-per-animal-summary`, `one-trajectory-per-mouse`
checks the recommended route: averaging per-keypoint summaries passes the rubric but not that
grader.

## Fixtures

The scaffolds write small, plain-text files in the layout each reader expects: single- and
multi-animal DeepLabCut CSVs (header rows `scorer`, `individuals` for multi-animal, `bodyparts`,
`coords`), an idtracker.ai `trajectories.csv`, and a table of body weights. They are synthetic,
20 to 40 frames each, and all read with `read_dataset()`. The script in `user-renamed-functions`
runs on the 2026-08-28 releases and fails on current builds with the error its prompt quotes. Check
any new fixture the same way: read it with its reader, and run the expected answer.
