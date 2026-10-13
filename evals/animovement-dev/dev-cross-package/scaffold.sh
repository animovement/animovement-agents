#!/usr/bin/env bash
# anicore with a new function on a branch, and animetric about to use it
set -euo pipefail

mkdir -p anicore/R animetric/R

cat > anicore/DESCRIPTION <<'EOF'
Package: anicore
Title: Core Data Structures for Movement Data
Version: 0.8.0.9008
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: The aniframe classes and their metadata, on which the animovement
    suite is built.
License: MIT + file LICENSE
URL: https://animovement.dev/anicore/, https://github.com/animovement/anicore/
Depends: R (>= 4.1.0)
Imports:
    cli,
    dplyr,
    lifecycle,
    rlang
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > anicore/R/signed_turn.R <<'EOF'
#' Signed turn between successive headings
#'
#' @param heading Headings in radians.
#' @return The signed change from each heading to the next, in `(-pi, pi]`,
#'   with `NA` for the last.
#' @examples
#' signed_turn(c(0, pi / 2, pi))
#' @export
signed_turn <- function(heading) {
  c(wrap_angle(diff(heading)), NA_real_)
}
EOF

cat > anicore/NEWS.md <<'EOF'
# anicore (development version)

## Added

* `signed_turn()` gives the signed change between successive headings.
EOF

cat > animetric/DESCRIPTION <<'EOF'
Package: animetric
Title: Movement Metrics
Version: 0.5.0.9006
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Kinematics, path measures and summaries for movement data held in
    an aniframe.
License: MIT + file LICENSE
URL: https://animovement.dev/animetric/, https://github.com/animovement/animetric/
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9004),
    anispace (>= 0.3.0.9006),
    cli,
    dplyr,
    rlang
Suggests:
    testthat (>= 3.0.0)
Additional_repositories: https://animovement.r-universe.dev
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

cat > animetric/R/add_kinematics.R <<'EOF'
#' Add velocity, speed and turning angle
#'
#' @param data An aniframe.
#' @return An aniframe with `v_x`, `v_y`, `speed` and `turning_angle` added.
#' @export
add_kinematics <- function(data) {
  anicore::ensure_is_anipoint(data)
  data <- add_velocity(data)
  dplyr::mutate(data, turning_angle = heading_change(v_x, v_y))
}
EOF
