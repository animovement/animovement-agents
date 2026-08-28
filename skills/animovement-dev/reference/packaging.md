# Packaging, licensing, CI and distribution

The conventions that are recorded nowhere else, and that a new package in the suite has to
get right up front. Everything about the *process* of contributing — setup, pull requests,
style, releases — lives in
[animovement/.github](https://github.com/animovement/.github) instead.

## Licensing

**The metapackage is GPL-3. The seven analysis packages are MIT.**

| Package | License |
|---|---|
| `animovement` | GPL-3 |
| `anicore`, `aniread`, `aniprocess`, `animetric`, `anivis`, `anicheck`, `anispace` | MIT + file LICENSE |

The metapackage is GPL-3 because its package-management code — attaching the suite,
resolving conflicts, the startup banner — is adapted from the
[fastverse](https://fastverse.github.io/fastverse/), which is GPL-3. That obligation travels
with the code, so the metapackage cannot be MIT while it carries it.

Adapted code is credited in `Authors@R` with a `ctb` role and a `comment` naming what was
adapted — in `animovement`, Sebastian Krantz for the fastverse and Hadley Wickham for the
tidyverse code it originally derives from.

**A new analysis package is MIT.** Getting this wrong is hard to undo: re-licensing needs
the agreement of everyone who has contributed by then.

## README conventions

Each README is generated: edit `README.qmd`, never `README.md`.

The YAML header must carry `default-image-extension: ""`:

```yaml
---
format:
  gfm:
    # Without this, pandoc appends ".png" to extensionless image URLs and every
    # shields.io / R-universe badge in this README breaks.
    default-image-extension: ""
knitr:
  opts_chunk:
    fig.path: "man/figures/README-"
---
```

Without it, Quarto appends `.png` to the extensionless badge URLs and **every badge breaks
silently** — the README still renders, the images just stop resolving.

The shared badge set, in order: Zenodo DOI, R-CMD-check, the R-universe status badge,
Codecov, and Zulip. Copy the block from an existing package and change the package name.

Re-render the README whenever anything embedded in it changes — the version appears in the
startup banner and the citation block, so it goes stale without any file visibly changing.
Rendering needs the branch **installed**, not merely loaded, or it will pick up the
previously installed build.

## CI

All six workflows are **reusable workflows** in `animovement/.github`, called by trigger-only
stubs in each package:

| Workflow | Does |
|---|---|
| `R-CMD-check` | `R CMD check` on Linux, macOS and Windows |
| `pkgdown` | builds and deploys the package site |
| `test-coverage` | reports coverage to Codecov |
| `format-suggest` | suggests air formatting fixes on the pull request |
| `pr-commands` | the `/document` and `/style` comment commands |
| `release-to-zulip` | announces a GitHub release in Zulip |

A new package needs the **stubs**, not copies of the workflows. A stub declares only the
trigger and delegates:

```yaml
name: format-suggest

on:
  pull_request_target:

jobs:
  format-suggest:
    uses: animovement/.github/.github/workflows/format-suggest.yml@main
    permissions:
      pull-requests: write
    secrets: inherit
```

Change the shared workflow, never the stub. `format-suggest` uses `pull_request_target`
rather than `pull_request` deliberately, so that `pull-requests: write` is available for
pull requests from forks — it only reads and reformats the code, never executes it.

The pkgdown theme comes from
[`animovementtemplate`](https://github.com/animovement/animovementtemplate), so sites stay
visually consistent; a new package points `_pkgdown.yml` at it rather than styling itself.

## Distribution

Packages are published on [R-universe](https://animovement.r-universe.dev), **not CRAN**.
That is why `DESCRIPTION` carries:

```
Additional_repositories: https://animovement.r-universe.dev
```

**Every package that depends on another `ani*` package needs this line** — `anicore` is the
exception, since it depends on none of them. `aniread` adds the Bioconductor r-universe
alongside it for its own dependencies.

The field is not used in ordinary dependency resolution, which works from the installed
library. R reads it in two places: `tools:::.check_Rd_xrefs`, part of a plain `R CMD check`,
so that a `\link[]{}` to a package outside the mainstream repositories resolves instead of
being reported as unavailable; and `tools:::.check_package_CRAN_incoming` under `--as-cran`.
So a missing field shows up as check noise once a cross-package Rd link is added, rather
than as an immediate failure — which is exactly why it tends to go unnoticed.

Install instructions in READMEs therefore look like:

```r
install.packages(
  "aniread",
  repos = c("https://animovement.r-universe.dev", "https://cloud.r-project.org")
)
```

**WASM builds are coupled to the R version webr ships.** R-universe currently builds
emscripten binaries for R 4.6 only, so a package failing to appear in the playground is
usually that, not a fault in the package. Worth checking before debugging a playground
failure.
