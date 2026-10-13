---
type: llm
---

PASS if the response reads the file with aniread's reader, `read_dataset()` or `read_deeplabcut()` (with or without `video_height`), after `library(animovement)` or as `aniread::read_dataset()`, and plots the trajectories with anivis: `plot()` on the frame it read, or `plot_trajectory()`. Declaring the 30 fps frame rate or converting units from notes.md, checking the data first (such as `check_confidence()`), or adding a ggplot2 alternative are all fine but not required.

FAIL if its main route parses the DeepLabCut header by hand (`read.csv()` or readr with skipped rows) instead of using the reader; calls an analysis function through `animovement::`, such as `animovement::read_dataset()`; tells the user to install animovement from CRAN with a plain `install.packages("animovement")`; or uses a function the packages do not have, such as `read_dlc()`, `plot_tracks()`, `set_sampling_rate()` or `set_unit_space()`.
