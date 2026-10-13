#!/usr/bin/env bash
# anispace, with the fix for #61 on the branch
set -euo pipefail

cat > DESCRIPTION <<'EOF'
Package: anispace
Title: Spatial Transformations for Movement Data
Version: 0.3.0.9006
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Coordinate systems and spatial transformations for movement data
    held in an aniframe.
License: MIT + file LICENSE
URL: https://animovement.dev/anispace/, https://github.com/animovement/anispace/
BugReports: https://github.com/animovement/anispace/issues
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9004),
    cli,
    dplyr
Suggests:
    testthat (>= 3.0.0)
Additional_repositories: https://animovement.r-universe.dev
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > NEWS.md <<'EOF'
# anispace (development version)

## Added

* `quat_from_vectors()` builds the rotation that takes one vector onto another
  (#55).

## Fixed

* `map_to_polar()` keeps the frame's metadata, including its units and sampling
  rate, instead of returning a frame without any (#61).

# anispace 0.3.0 (2026-08-28)

## Changed

* The transforms read the coordinate system from the frame's metadata (#41).
EOF

mkdir -p R tests/testthat
cat > R/map_to_polar.R <<'EOF'
#' Map Cartesian coordinates to polar
#'
#' @param data An aniframe with `x` and `y`.
#' @return An aniframe with `rho` and `phi` in place of `x` and `y`.
#' @examples
#' af <- anicore::example_anipoint(n_obs = 5, n_individuals = 1, n_keypoints = 1)
#' map_to_polar(af)
#' @export
map_to_polar <- function(data) {
  anicore::ensure_is_anipoint(data)
  metadata <- anicore::get_metadata(data)
  out <- dplyr::mutate(
    data,
    rho = sqrt(x^2 + y^2),
    phi = atan2(y, x),
    .keep = "unused"
  )
  anicore::set_metadata(out, metadata = metadata)
}
EOF

cat > tests/testthat/test-map_to_polar.R <<'EOF'
test_that("map_to_polar() keeps the frame's metadata", {
  af <- anicore::example_anipoint(n_obs = 5, n_individuals = 1, n_keypoints = 1)
  af <- anicore::set_metadata(af, sampling_rate = 30)
  expect_equal(anicore::get_metadata(map_to_polar(af), "sampling_rate"), 30)
})
EOF
