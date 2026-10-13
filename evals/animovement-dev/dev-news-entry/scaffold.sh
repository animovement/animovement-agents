#!/usr/bin/env bash
# aniprocess partway through a development cycle
set -euo pipefail

cat > DESCRIPTION <<'EOF'
Package: aniprocess
Title: Signal Processing and Filtering of Movement Data
Version: 0.5.0.9003
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Filtering, smoothing and gap-filling for movement data held in an
    aniframe.
License: MIT + file LICENSE
URL: https://animovement.dev/aniprocess/, https://github.com/animovement/aniprocess/
BugReports: https://github.com/animovement/aniprocess/issues
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9003),
    cli,
    dplyr,
    rlang
Suggests:
    signal,
    testthat (>= 3.0.0)
Additional_repositories: https://animovement.r-universe.dev
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > NEWS.md <<'EOF'
# aniprocess (development version)

## Added

* `filter_deadband()` holds a point where it is until it moves more than
  `threshold` away, so tracking noise on a still animal no longer adds to its
  path (#104).

## Changed

* `filter_across()` refuses `on_deltas = TRUE` for the `"ccma"` and
  `"deadband"` methods, which need positions; it used to ignore it (#105).

# aniprocess 0.5.0 (2026-08-28)

## Changed

* Interpolation works on the index rather than on row position (#78).

## Fixed

* `filter_sgolay()` trims the reflection padding by the width actually
  applied (#82).
EOF

mkdir -p R
cat > R/filter_kalman.R <<'EOF'
#' Smooth a trajectory with a Kalman filter
#'
#' @param data An aniframe.
#' @param q Process noise (default `1e-3`).
#' @return An aniframe with the coordinates smoothed.
#' @export
filter_kalman <- function(data, q = 1e-3) {
  anicore::ensure_is_anipoint(data)
  metadata <- anicore::get_metadata(data)
  out <- kalman_smooth(data, q)
  anicore::set_metadata(out, metadata = metadata)
}
EOF
