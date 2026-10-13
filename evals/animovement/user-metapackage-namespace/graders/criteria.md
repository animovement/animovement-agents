---
type: llm
---

PASS if it explains that animovement is a metapackage that attaches the other packages but does not export their functions (only its own `animovement_*()` helpers), and fixes report.qmd in either of these ways:

- `library(animovement)` in the first chunk, with the functions called without a prefix;
- each function called through the package that owns it: `aniread::read_dataset()`, `anicheck::check_na_gapsize()`, `anivis::plot_trajectory()`, `animetric::add_kinematics()` and `animetric::summarise_path()`.

Mixing the two, or also suggesting units or a frame rate, is fine.

FAIL if its fix is to reinstall or update animovement, or to install it from CRAN; if it leaves any analysis function behind `animovement::`; or if it names the wrong package for a function, such as `anicore::read_dataset()`, `animetric::plot_trajectory()` or `aniprocess::add_kinematics()`.
