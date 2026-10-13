#!/usr/bin/env bash
# A new package in the suite, whose README was rendered without the image-extension setting
set -euo pipefail

cat > DESCRIPTION <<'EOF'
Package: anigait
Title: Gait Analysis for Movement Data
Version: 0.0.0.9000
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Stride detection and gait parameters for movement data held in an
    aniframe.
License: MIT + file LICENSE
URL: https://animovement.dev/anigait/, https://github.com/animovement/anigait/
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9008)
Additional_repositories: https://animovement.r-universe.dev
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > README.qmd <<'EOF'
---
format: gfm
knitr:
  opts_chunk:
    fig.path: "man/figures/README-"
---

<!-- README.md is generated from README.qmd. Please edit that file -->

# anigait

<!-- badges: start -->
[![R-CMD-check](https://github.com/animovement/anigait/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/anigait/actions/workflows/R-CMD-check.yaml)
[![R-universe status badge](https://animovement.r-universe.dev/badges/anigait)](https://animovement.r-universe.dev)
[![Codecov test coverage](https://codecov.io/gh/animovement/anigait/graph/badge.svg)](https://app.codecov.io/gh/animovement/anigait)
[![Chat on Zulip](https://img.shields.io/badge/chat-Zulip-6492FE?logo=zulip&logoColor=white)](https://animovement.zulipchat.com)
<!-- badges: end -->

anigait detects strides and computes gait parameters from movement data.

## Installation

```r
install.packages(
  "anigait",
  repos = c("https://animovement.r-universe.dev", "https://cloud.r-project.org")
)
```
EOF

cat > README.md <<'EOF'
# anigait


<!-- README.md is generated from README.qmd. Please edit that file -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/animovement/anigait/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/animovement/anigait/actions/workflows/R-CMD-check.yaml)
[![R-universe status
badge](https://animovement.r-universe.dev/badges/anigait.png)](https://animovement.r-universe.dev)
[![Codecov test
coverage](https://codecov.io/gh/animovement/anigait/graph/badge.svg)](https://app.codecov.io/gh/animovement/anigait)
[![Chat on
Zulip](https://img.shields.io/badge/chat-Zulip-6492FE?logo=zulip&logoColor=white.png)](https://animovement.zulipchat.com)
<!-- badges: end -->

anigait detects strides and computes gait parameters from movement data.

## Installation

``` r
install.packages(
  "anigait",
  repos = c("https://animovement.r-universe.dev", "https://cloud.r-project.org")
)
```
EOF
