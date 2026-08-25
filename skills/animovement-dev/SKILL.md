---
name: animovement-dev
description: >-
  Use when contributing to or maintaining the animovement R packages themselves —
  cutting a release, writing NEWS.md entries, commit messages and pull request
  titles, setting up or debugging CI, adding a new package to the suite, or
  questions about licensing, README/badge conventions and how the packages are
  distributed. For *using* the packages to analyse movement data, use the
  animovement skill instead.
---

# animovement-dev

Conventions for working **on** the animovement packages, as opposed to with them.
The suite is eight repositories under [animovement](https://github.com/animovement),
sharing one set of workflows, one documentation theme, and one release process.

## The canonical documents

Most of what governs a contribution is written down, and is maintained in
[animovement/.github](https://github.com/animovement/.github) rather than here.
**Read the relevant one rather than relying on this file** — this skill covers what
those files do not, and points at them for everything else.

| For | Read | Canonical source |
|---|---|---|
| Setup, pull requests, code + documentation style | `reference/contributing.md` | [CONTRIBUTING.md](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md) |
| What is expected of AI-assisted contributions | `reference/ai-policy.md` | [AI.md](https://github.com/animovement/.github/blob/main/AI.md) |
| Cutting a release, step by step | `reference/release-checklist.md` | [the Release checklist template](https://github.com/animovement/.github/blob/main/.github/ISSUE_TEMPLATE/release.md) |
| Per-package API | — | `https://animovement.dev/<package>/llms.txt` |
| Which package owns what | — | the **animovement** skill |

The three `reference/` files are **generated copies**, vendored so they can be read without
fetching a URL. Each carries the commit it came from in a header comment. They are synced by
a workflow in `animovement/.github` and must never be edited here — a change belongs in the
source, which then flows back. If a detail is load-bearing, or the header looks old, check
the canonical source.

## Invariants — cheap to get wrong, expensive to undo

- **Format with [air](https://posit-dev.github.io/air/), not styler.** Formatting is checked
  on every pull request and blocks merging. `/style` as a pull request comment applies it.
- **Never push to `main`.** It is protected. Open a pull request; checks must pass.
- **The pull request title must be a Conventional Commit** — merges squash, so the title
  becomes the commit on `main`. See *Commit messages* below.
- **`NEWS.md` is written by hand, for users**, in the
  [tidyverse style](https://style.tidyverse.org/news.html) — not generated from commits, and
  not a commit log. Every user-facing change gets a bullet under `# (development version)`.
- **`man/` is generated.** Edit the roxygen comments, never the `.Rd` files. `/document` as a
  pull request comment regenerates them.
- **Verify a function exists before referring to it.** This suite went through a package
  split and keeps evolving; a plausible-sounding name may belong to a different package or
  may never have existed. Check `llms.txt`, not recollection.

## The development loop

```r
devtools::load_all()        # the branch, not the installed build
devtools::test()            # testthat, edition 3
devtools::run_examples()    # examples are run in check; run them here first
goodpractice::gp()          # before anything substantial lands
```

- **`library(pkg)` loads the *installed* package**, which is usually the published release
  rather than the branch you are working on. Use `load_all()`, or install the branch first.
  Anything that renders package output — `README.qmd`, vignettes — needs it installed, not
  merely loaded. Say which of the two you tested against when reporting a result.
- **Tests are [testthat](https://testthat.r-lib.org) edition 3.** A contribution that comes
  with tests gets merged faster; a bug fix without a regression test will be asked for one.
- **[goodpractice](https://docs.ropensci.org/goodpractice/)** is expected before a
  substantial change, and appears on the release checklist. CONTRIBUTING.md gives a way to
  mute the checks that are noisy for this suite rather than running the full set every time.
- Setup — repositories, `pak::pak()`, and the note that renv is optional — is in
  [CONTRIBUTING.md](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md#setting-up).

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<optional scope>): <description>
```

`feat` (minor bump) · `fix` (patch) · `docs` · `perf` · `refactor` · `test` · `build` ·
`ci` · `chore` · `revert`. Scope is normally the package name. A breaking change takes a
`!` before the colon plus a `BREAKING CHANGE:` footer, and forces a major bump.

Imperative mood, lower case, no trailing full stop; describe the change rather than the
file — `fix(aniprocess): keep metadata through filter_kalman()`, not `fix: update
filter-kalman.R`. The full table with version effects is in
[CONTRIBUTING.md](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md#commit-messages).

## Packaging, licensing, CI and distribution

The things that are written down nowhere else — and that are hard to reverse if a new
package gets them wrong — are in `reference/packaging.md`:

- **Licensing** — why the metapackage is GPL-3 while the seven analysis packages are MIT,
  and how adapted code is credited.
- **README** — the shared skeleton, the badge set, and the Quarto setting that silently
  breaks every badge without it.
- **CI** — six reusable workflows in `animovement/.github`, called by trigger-only stubs.
  A new package needs the stubs, not copies.
- **Distribution** — R-universe rather than CRAN, why `Additional_repositories` exists, and
  the R version that WASM builds are pinned to.

## Releases

Open a **Release checklist** issue from the template and work through it — `reference/release-checklist.md`
is the same content, for reading rather than ticking off. The thing worth knowing in advance is that the version appears
in five places that go stale independently: `DESCRIPTION`, `CITATION.cff`, `inst/CITATION`,
the `NEWS.md` heading, and the rendered `README.md` (the version is embedded in the startup
banner and the citation block, so it must be re-rendered). After the release, `DESCRIPTION`
goes to `<next>.9000` and `NEWS.md` opens a fresh `# (development version)`.
