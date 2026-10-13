# Packaging, licensing, CI and distribution

Read this when a package's licence, README, CI, Codecov setup or distribution is in question,
or when adding a package to the suite. These are recorded nowhere else. The process of
contributing (setup, pull requests, style, releases) is in `contributing.md` and
`release-checklist.md`.

## Licensing

**The metapackage is GPL-3. The seven analysis packages are MIT.**

| Package | License |
|---|---|
| `animovement` | GPL-3 |
| `anicore`, `aniread`, `aniprocess`, `animetric`, `anivis`, `anicheck`, `anispace` | MIT + file LICENSE |

The metapackage is GPL-3 because its package-management code (attaching the suite, resolving
conflicts, the startup banner) is adapted from the
[fastverse](https://fastverse.github.io/fastverse/), which is GPL-3. That obligation travels
with the code, so the metapackage cannot be MIT while it carries it.

Adapted code is credited in `Authors@R` with a `ctb` role and a `comment` naming what was
adapted: in `animovement`, Sebastian Krantz for the fastverse and Hadley Wickham for the
tidyverse code it originally derives from.

**A new analysis package is MIT.** Getting this wrong is hard to undo: re-licensing needs the
agreement of everyone who has contributed by then.

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

Without it, Quarto appends `.png` to every image URL without an extension, the R-universe and
shields.io (Zulip) badges among them, and **they break silently**: the README still renders,
the images stop resolving. Badges whose URL ends in `.svg` keep working, so it looks like a
problem with one badge rather than with the header. Fix the header and re-render; editing
`README.md` lasts until the next render.

The badge set, in order: Zenodo DOI, R-CMD-check, R-universe, Codecov, Zulip. Copy the block
from anicore's `README.qmd` and change the package name, and the DOI once Zenodo has minted
one. Some packages' Codecov badges carry a `?token=`; a public repository doesn't need it.

**Only animovement's README embeds versions:** its startup banner lists every suite package's
version, and its citation block its own. It goes stale whenever any suite package's version
moves, with no change to animovement, and is re-rendered by hand (animovement#188; a CI check
is planned in .github#51). Render it with the branch **installed**, not merely loaded, from the
package root with renv's autoloader off, or it shows another build. The other READMEs embed
no version.

A clone may carry usethis's README pre-commit hook, which is local, not part of the
repository. It refuses a commit staging `README.md` without `README.qmd`, which is exactly what
a re-render after a version change is; its message names the override.

## CI

The jobs are **reusable workflows** in `animovement/.github`; each package carries
trigger-only stubs that call them at `@main`, so a change merged there applies to every
package's next run. There are seven:

| Workflow | Does | Stub in the packages |
|---|---|---|
| `R-CMD-check` | `R CMD check`, plus the `anicore-metadata-contract` job | yes |
| `pkgdown` | builds the site; deploys only outside pull requests | yes |
| `test-coverage` | reports coverage to Codecov | yes |
| `format-suggest` | suggests air formatting fixes on the pull request, and fails while any remain | yes |
| `pr-commands` | the `/document` and `/style` comment commands, for organisation members and owners only | yes |
| `release-to-zulip` | announces a GitHub release in Zulip | yes |
| `pr-title` | checks the pull request title is a Conventional Commit | **no**: called by `animovement/.github` and `animovement-agents`, by none of the eight packages |

**`R-CMD-check`.** A pull request runs R release on Ubuntu, macOS and Windows, plus Ubuntu
`oldrel-1`; a push to `main` adds Ubuntu R-devel, which has no binaries. The check runs with
`--as-cran` and fails on any WARNING; NOTEs pass. Dependencies, Suggests included, come from
R-universe and Posit's binary repository, resolved from `DESCRIPTION` with renv's autoloader
off, so the lockfiles play no part; `_R_CHECK_FORCE_SUGGESTS_` is false. A `cache-version` in
the shared workflows invalidates the dependency cache when a stale library survives
(animovement/anicore#127).

**`anicore-metadata-contract`** runs in every package except anicore. It greps `R/` for raw
metadata access (`attr(..., "metadata")`, `$variables_*`, `[["variables_*"]]`) and fails on
any hit outside a comment line. A line that genuinely needs the raw attribute opts out with a
trailing `# anicore: allow-metadata` on the same line. air moves a comment that trails `{`, so
put such a read in an assignment of its own.

**Required checks.** Each package's `Protect main` ruleset requires a pull request (no approving
review) and seven checks: the four R-CMD-check configurations, `pkgdown / pkgdown`,
`test-coverage / test-coverage` and `format-suggest / format-suggest`. A branch need not be up to
date with `main`. The metadata-contract job and the Codecov statuses are not required. Merge,
squash and rebase are all allowed; squashing is a convention, not a setting. A squash commit
takes the PR title only when the PR has several commits, and branches are not deleted on merge.

**Codecov.** One configuration covers every package: Codecov's organisation-wide Global YAML,
whose canonical copy is `codecov/codecov.yml` in `animovement/.github`. Codecov does not read
that file, so after changing it an org admin pastes it into the Global YAML setting on
app.codecov.io. It sets project and patch status at `target: auto`, `threshold: 1%`,
`informational: true` (reported, never blocking) and
`comment: require_changes: "coverage_drop OR uncovered_patch"`, so Codecov comments only when
coverage drops or a pull request adds uncovered lines (`true` would comment on any pull request
that adds code, covered or not). Packages carry no `codecov.yml`: Codecov does not merge one
with the Global YAML, it replaces it outright, dropping the shared settings for that package.
Recent pull requests have landed with every changed line covered.

**The stubs.** The canonical copy of each lives in
[`workflows/stubs/`](https://github.com/animovement/.github/tree/main/workflows/stubs) in
`animovement/.github`. Its **Sync workflow stubs** workflow opens a pull request wherever a
package's copy differs, but it only updates a stub that already exists and never creates one,
so a new package copies them in once. A stub declares only the trigger and delegates:

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

Change the shared workflow or the canonical stub, never a package's copy: the next sync puts
it back. `format-suggest` uses `pull_request_target` rather than `pull_request` deliberately,
so that `pull-requests: write` is available for pull requests from forks; it only reads and
reformats the code, never executes it. The stubs behind the required checks trigger on every
pull request whatever its base, so stacked pull requests run them all.

The pkgdown theme comes from
[`animovementtemplate`](https://github.com/animovement/animovementtemplate), which also carries
the navbar menu listing every package, so sites stay consistent; a new package points
`_pkgdown.yml` at it rather than styling itself. The pkgdown stub installs Quarto.

## Distribution

Packages are published on [R-universe](https://animovement.r-universe.dev), **not CRAN**,
built from each repository's `main`. That is why `DESCRIPTION` carries:

```
Additional_repositories: https://animovement.r-universe.dev
```

**Every package that depends on another `ani*` package needs this line**; `anicore` is the
exception, since it depends on none of them. `aniread` adds the Bioconductor r-universe
alongside it for its own dependencies.

The field is not used in ordinary dependency resolution, which works from the configured
repositories and the installed library. R reads it in two places: `tools:::.check_Rd_xrefs`,
part of a plain `R CMD check`, so that a `\link[]{}` to a package outside the mainstream
repositories resolves instead of being reported as unavailable; and
`tools:::.check_package_CRAN_incoming` under `--as-cran`. So a missing field shows up as check
noise once a cross-package Rd link is added, rather than as an immediate failure, which is
exactly why it tends to go unnoticed.

Install instructions in READMEs therefore look like:

```r
install.packages(
  "aniread",
  repos = c("https://animovement.r-universe.dev", "https://cloud.r-project.org")
)
```

`https://animovement.r-universe.dev/api/packages/<package>` reports what R-universe has built:
`Version`, and `RemoteSha`, the commit.

**WASM builds are coupled to the R version webr ships.** R-universe currently builds
emscripten binaries for R 4.6 only, so a package failing to appear in the playground is
usually that, not a fault in the package. Worth checking before debugging a playground
failure.

### Conda (prefix.dev)

The packages are also built for conda, as `r-<package>` in the
[animovement channel on prefix.dev](https://prefix.dev/channels/animovement), from
rattler-build recipes in [animovement-forge](https://github.com/animovement/animovement-forge).

- A **nightly job** (02:00 UTC) reads each package's `Version` and `RemoteSha` from the
  R-universe API and pins its recipe to that commit. When any recipe changes, every package
  is rebuilt, but the upload skips versions the channel already holds, so **only a version
  change publishes**. Commits merged without a version bump don't reach prefix.dev until the
  next one. Running **Nightly Check** by hand publishes sooner; **Build and Upload** alone
  rebuilds the recipes as they are.
- **Recipes list their dependencies by hand.** The nightly updates only the version and
  commit, so a dependency added to `DESCRIPTION`, or a raised floor, must also go into the
  recipe, under `host` and `run`, or the conda build breaks.

## Adding a package

A new package has to be registered in each of these. Copy from an existing package rather
than starting fresh.

- **`DESCRIPTION`**: MIT licence; `URL` naming `https://animovement.dev/<package>/`, as
  `_pkgdown.yml` does; `Additional_repositories` if it depends on another `ani*` package;
  `Config/Needs/website: animovement/animovementtemplate`.
- **From an existing package**: `.Rbuildignore`, `CITATION.cff`, `inst/CITATION` (reads
  `meta$Version`), `README.qmd`, `_pkgdown.yml` pointing at `animovementtemplate`, and the
  lifecycle setup (*Function lifecycle* in `contributing.md`).
- **Workflow stubs**: copy all six from `workflows/stubs/` in `animovement/.github`, unchanged;
  the sync will not create them.
- **Branch protection**: a `Protect main` ruleset requiring the same seven checks;
  `workflows/README.md` in `animovement/.github` lists their exact names.
- **Secrets**: confirm the repository can see `CODECOV_TOKEN` and `ZULIP_API_KEY`, which the
  stubs pass on with `secrets: inherit`.
- **Zenodo**: switch the repository on in Zenodo's GitHub integration before the first
  release, which then mints the DOI the README badge shows.
- **`agents/packages.tsv`** in `animovement/.github`: one line, name and role. It drives both
  **Sync AGENTS.md** and **Sync workflow stubs**.
- **`AGENTS_SYNC_TOKEN`**: the token those syncs use covers selected repositories only
  (`agents/README.md` in `animovement/.github`), so grant it the new one, including the
  *Workflows* permission the stub sync needs (`workflows/README.md` there).
- **The package table in `CONTRIBUTING.md`** (*Which repository?*), in `animovement/.github`.
- **R-universe**: add it to `packages.json` in
  [animovement/animovement.r-universe.dev](https://github.com/animovement/animovement.r-universe.dev).
- **Conda**: a recipe in animovement-forge, its dependencies mirroring `DESCRIPTION`.
- **The metapackage**: `Imports` in its `DESCRIPTION`, `@import` in `R/animovement.R`, the
  lists in `R/attach.R` (what `library(animovement)` attaches) and `R/install_suggested.R`,
  the package list in `README.qmd`, and the table in `vignettes/animovement.Rmd`.
- **animovementtemplate**: the packages menu in `inst/pkgdown/BS5/_pkgdown.yml`.
- **The website**,
  [animovement/animovement.github.io](https://github.com/animovement/animovement.github.io):
  `packages/index.qmd` with a logo in `assets/logos/`, `index.qmd`, the package list in
  `find/index.qmd`, and the packages `.github/workflows/validate.yml` installs.
- **This plugin**: the package table in the **animovement** skill and its
  `reference/packages.md`, and the package list at the top of this skill.
