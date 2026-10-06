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

The jobs are **reusable workflows** in `animovement/.github`; each package carries
trigger-only stubs that call them. There are seven:

| Workflow | Does | Stub in the packages |
|---|---|---|
| `R-CMD-check` | `R CMD check`, plus the `anicore-metadata-contract` job | yes |
| `pkgdown` | builds the site; deploys only outside pull requests | yes |
| `test-coverage` | reports coverage to Codecov | yes |
| `format-suggest` | suggests air formatting fixes on the pull request, and fails while any remain | yes |
| `pr-commands` | the `/document` and `/style` comment commands, for organisation members and owners only | yes |
| `release-to-zulip` | announces a GitHub release in Zulip | yes |
| `pr-title` | checks the pull request title is a Conventional Commit | **no** — called by `animovement/.github` and `animovement-agents`, by none of the eight packages |

**`R-CMD-check` matrix.** A pull request runs R release on Ubuntu, macOS and Windows, plus
Ubuntu `oldrel-1`. A push to `main` adds Ubuntu R-devel, which has no binaries.

**`anicore-metadata-contract`** runs in every package except anicore. It greps `R/` for raw
metadata access — `attr(..., "metadata")`, `$variables_*`, `[["variables_*"]]` — and fails
on any hit outside a comment line. A line that genuinely needs the raw attribute opts out
with a trailing `# anicore: allow-metadata` on the same line. air moves a comment that trails
`{`, so put such a read in an assignment of its own.

**Required checks.** Each package's `Protect main` ruleset requires the four R-CMD-check
configurations, `pkgdown / pkgdown`, `test-coverage / test-coverage` and
`format-suggest / format-suggest`. The metadata-contract job and the Codecov statuses are not
required. The ruleset allows merge, squash and rebase; squashing is a convention, not a
setting.

**Codecov.** One configuration covers every package: Codecov's organisation-wide Global
YAML, whose canonical copy is `codecov/codecov.yml` in `animovement/.github`. Codecov does not
read that file, so after changing it an org admin pastes it into the Global YAML setting on
app.codecov.io. It sets project and patch status at `target: auto`, `threshold: 1%`,
`informational: true` — reported, never blocking — and `comment: require_changes: true`, so
Codecov comments only on pull requests that change coverage. Packages carry no `codecov.yml`;
one would override the Global YAML key by key. Recent pull requests have landed with every
changed line covered.

**The stubs.** The canonical copy of each lives in
[`workflows/stubs/`](https://github.com/animovement/.github/tree/main/workflows/stubs) in
`animovement/.github`. Its **Sync workflow stubs** workflow opens a pull request wherever a
package's copy differs — but it only updates a stub that already exists and never creates
one, so a new package copies them in once. A stub declares only the trigger and delegates:

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

Change the shared workflow or the canonical stub, never a package's copy — the next sync
puts it back. `format-suggest` uses `pull_request_target` rather than `pull_request`
deliberately, so that `pull-requests: write` is available for pull requests from forks — it
only reads and reformats the code, never executes it. The stubs behind the required checks
trigger on every pull request whatever its base, so stacked pull requests run them all.

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

### Conda (prefix.dev)

The packages are also built for conda, as `r-<pkg>` in the
[animovement channel on prefix.dev](https://prefix.dev/channels/animovement), from
rattler-build recipes in
[animovement-forge](https://github.com/animovement/animovement-forge).

- A **nightly job** reads each package's `Version` and `RemoteSha` from the R-universe API
  and pins its recipe to that commit. When any recipe changes, every package is rebuilt, but
  the upload skips versions the channel already holds, so **only a version change publishes**. Commits merged
  without a version bump do not reach prefix.dev until the next one.
- **Recipes list their dependencies by hand.** The nightly updates only the version and
  commit, so a dependency added to `DESCRIPTION` must also be added to the recipe, or the
  conda build breaks.

## Adding a package

A new package has to be registered in each of these. Copy from an existing package rather
than starting fresh.

- **`DESCRIPTION`** — MIT licence; `Additional_repositories` if it depends on another
  `ani*` package; `Config/Needs/website: animovement/animovementtemplate`.
- **`_pkgdown.yml`** — point it at `animovementtemplate`.
- **Workflow stubs** — copy all six from `workflows/stubs/` in `animovement/.github`; the
  sync will not create them.
- **Branch protection** — a `Protect main` ruleset requiring the same seven checks.
- **`agents/packages.tsv`** in `animovement/.github` — one line, name and role. It drives
  both **Sync AGENTS.md** and **Sync workflow stubs**.
- **`AGENTS_SYNC_TOKEN`** — the token those syncs use is set up for selected repositories
  only (`agents/README.md` in `animovement/.github`), so grant it the new one.
- **The package table in `CONTRIBUTING.md`** (*Which repository?*), in
  `animovement/.github`.
- **R-universe** — add it to `packages.json` in
  [animovement/animovement.r-universe.dev](https://github.com/animovement/animovement.r-universe.dev).
- **Conda** — a recipe in animovement-forge, its dependencies mirroring `DESCRIPTION`.
- **The metapackage** — `animovement`'s `Imports`, and the package lists in `R/attach.R`
  (what `library(animovement)` attaches) and `R/install_suggested.R`.
- **This plugin** — the package table in the **animovement** skill, and `reference/packages.md`.
