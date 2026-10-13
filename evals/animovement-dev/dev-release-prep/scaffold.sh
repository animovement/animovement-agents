#!/usr/bin/env bash
# anicheck at the end of a development cycle
set -euo pipefail

cat > DESCRIPTION <<'EOF'
Package: anicheck
Title: Diagnose Movement Data Quality
Version: 0.3.0.9004
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Diagnostics for movement data held in an aniframe: confidence,
    missing values and segment lengths.
License: MIT + file LICENSE
URL: https://animovement.dev/anicheck/, https://github.com/animovement/anicheck/
BugReports: https://github.com/animovement/anicheck/issues
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9003),
    cli,
    dplyr,
    rlang
Suggests:
    anivis (>= 0.2.1.9003),
    testthat (>= 3.0.0)
Additional_repositories: https://animovement.r-universe.dev
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > CITATION.cff <<'EOF'
cff-version: 1.2.0
message: "If you use this software, please cite it as below."
title: "anicheck: Diagnose Movement Data Quality"
version: 0.3.0
date-released: 2026-08-28
authors:
  - family-names: Roald-Arbøl
    given-names: Mikkel
license: MIT
repository-code: https://github.com/animovement/anicheck
EOF

mkdir -p inst
cat > inst/CITATION <<'EOF'
citHeader("To cite anicheck in publications use:")

bibentry(
  bibtype  = "Manual",
  title    = "anicheck: Diagnose Movement Data Quality",
  author   = person("Mikkel", "Roald-Arbøl"),
  year     = format(Sys.Date(), "%Y"),
  version  = meta$Version,
  url      = "https://animovement.dev/anicheck/"
)
EOF

cat > NEWS.md <<'EOF'
# anicheck (development version)

## Added

* `check_segment_length()` reports how much each segment of a structure varies
  from its usual length (#39).

## Fixed

* The checks handle an aniframe with no rows (#32).

# anicheck 0.3.0 (2026-08-28)

## Changed

* Check objects carry the frame's declarations (#27).
EOF

cat > README.qmd <<'EOF'
---
format:
  gfm:
    default-image-extension: ""
knitr:
  opts_chunk:
    fig.path: "man/figures/README-"
---

# anicheck

<!-- badges: start -->
[![R-CMD-check](https://github.com/animovement/anicheck/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/anicheck/actions/workflows/R-CMD-check.yaml)
[![R-universe status badge](https://animovement.r-universe.dev/badges/anicheck)](https://animovement.r-universe.dev)
<!-- badges: end -->

anicheck diagnoses the quality of movement data.
EOF
