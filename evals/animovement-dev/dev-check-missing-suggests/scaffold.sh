#!/usr/bin/env bash
# A fresh clone of aniread's main, and a local check that failed on this machine
set -euo pipefail

cat > DESCRIPTION <<'EOF'
Package: aniread
Title: Read and Write Movement Data
Version: 0.7.0.9006
Authors@R: person("Mikkel", "Roald-Arbøl", email = "maintainer@example.org", role = c("aut", "cre"))
Description: Readers for pose estimation and tracking formats, returning an
    aniframe, and writers for the formats the suite can write.
License: MIT + file LICENSE
URL: https://animovement.dev/aniread/, https://github.com/animovement/aniread/
BugReports: https://github.com/animovement/aniread/issues
Depends: R (>= 4.1.0)
Imports:
    anicore (>= 0.8.0.9008),
    cli,
    dplyr,
    readr,
    rlang
Suggests:
    arrow,
    c3dr,
    rhdf5,
    jsonlite,
    testthat (>= 3.0.0),
    withr
Additional_repositories: https://animovement.r-universe.dev, https://bioc.r-universe.dev
Config/testthat/edition: 3
Encoding: UTF-8
Roxygen: list(markdown = TRUE)
EOF

mkdir -p tests/testthat
cat > tests/testthat.R <<'EOF'
library(testthat)
library(aniread)

test_check("aniread")
EOF

cat > tests/testthat/test-write_dataset.R <<'EOF'
test_that("write_dataset() writes one file per group", {
  af <- anicore::example_anipoint(n_obs = 10, n_individuals = 2, n_keypoints = 1)
  dir <- withr::local_tempdir()
  write_dataset(af, dir, by = "individual")
  expect_length(arrow::open_dataset(dir)$files, 2)
})
EOF

cat > tests/testthat/test-read_c3d.R <<'EOF'
test_that("read_c3d() reads marker trajectories", {
  af <- read_c3d(test_path("data", "walk.c3d"))
  expect_true(anicore::is_anipoint(af))
})
EOF

cat > check-output.txt <<'EOF'
══ Checking ════════════════════════════════════════════════════════════════════
Setting env vars:
• _R_CHECK_CRAN_INCOMING_REMOTE_: FALSE
• _R_CHECK_CRAN_INCOMING_       : FALSE
• _R_CHECK_FORCE_SUGGESTS_      : FALSE
• NOT_CRAN                      : true
── R CMD check ─────────────────────────────────────────────────────────────────
* using R version 4.6.1 (2026-06-12)
* using platform: aarch64-apple-darwin23
* checking for file ‘aniread/DESCRIPTION’ ... OK
* this is package ‘aniread’ version ‘0.7.0.9006’
* checking package dependencies ... OK
* checking examples ... OK
* checking for unstated dependencies in ‘tests’ ... OK
* checking tests ...
  Running ‘testthat.R’
 ERROR
Running the tests in ‘tests/testthat.R’ failed.
Last 13 lines of output:
  ── Error ('test-write_dataset.R:5:3'): write_dataset() writes one file per group ──
  Error in `loadNamespace(x)`: there is no package called ‘arrow’
  ── Error ('test-read_c3d.R:2:3'): read_c3d() reads marker trajectories ──
  Error in `loadNamespace(x)`: there is no package called ‘c3dr’

  [ FAIL 11 | WARN 0 | SKIP 6 | PASS 655 ]
  Error: Test failures
  Execution halted
* DONE

Status: 1 ERROR

── R CMD check results ──────────────────────────────── aniread 0.7.0.9006 ────
❯ checking tests ...
  See below...

1 error ✖ | 0 warnings ✔ | 0 notes ✔
EOF
