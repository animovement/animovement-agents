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
| Opening a pull request | `reference/pull-request-template.md` | [PULL_REQUEST_TEMPLATE.md](https://github.com/animovement/.github/blob/main/.github/PULL_REQUEST_TEMPLATE.md) |
| Opening an issue | `reference/issue-templates.md` | [the issue forms](https://github.com/animovement/.github/tree/main/.github/ISSUE_TEMPLATE) |
| Per-package API | — | `https://animovement.dev/<package>/llms.txt` |
| Which package owns what | — | the **animovement** skill |

These `reference/` files are **generated copies**, vendored so they can be read without
fetching a URL. Each carries the commit it came from in a header comment. They are synced by
a workflow in `animovement/.github` and must never be edited here — a change belongs in the
source, which then flows back. If a detail is load-bearing, or the header looks old, check
the canonical source.

## Invariants — cheap to get wrong, expensive to undo

- **Format with [air](https://posit-dev.github.io/air/), not styler.** Formatting is checked
  on every pull request and blocks merging. `/style` as a pull request comment applies it —
  but the comment commands only run for organisation members and owners, so an outside
  contributor runs `air format .` themselves.
- **Never push to `main`.** It is protected. Open a pull request; checks must pass.
- **The pull request title must be a Conventional Commit** — merges squash by convention, so
  the title becomes the commit on `main`. See *Commit messages* below. The package
  repositories do not run the `pr-title` check (see `reference/packaging.md`), so no workflow
  checks the title there; get it right before merging.
- **`NEWS.md` is written by hand, for users**, in the
  [tidyverse style](https://style.tidyverse.org/news.html) — not generated from commits, and
  not a commit log. Every user-facing change gets a bullet under
  `# <package> (development version)` — e.g. `# anicore (development version)`.
- **`man/` is generated.** Edit the roxygen comments, never the `.Rd` files. `/document` as a
  pull request comment regenerates them (members and owners only, like `/style`).
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

## Opening issues and pull requests through the API

**Templates are a web-UI feature.** An issue or pull request created with `gh` or through
the API gets none of their structure — which is exactly how the first issue and several
pull requests in this organisation came to ignore them. Nothing warns you; the body is
simply whatever you passed.

So reproduce the fields by hand:

- **Pull requests** — `reference/pull-request-template.md` is the template verbatim. Fill in
  its sections rather than replacing them with prose of your own; that applies specifically
  to AI-assisted contributions, and the AI policy says so.
- **Issues** — `reference/issue-templates.md` renders the bug and feature *forms* as markdown
  skeletons, since their YAML cannot be passed as a body. It also gives the value for
  `gh issue create --type Bug|Feature|Task`, which has to be set explicitly.

## Writing documentation

Roxygen documentation has its own style section in `reference/contributing.md`
([Documentation style](https://github.com/animovement/.github/blob/main/CONTRIBUTING.md#documentation-style)).
It is short, and the rules are not the usual ones — the house style is deliberately terse. Read it
before writing `@param`, `@return` or `@examples`; it covers namespacing `example_aniframe()` in
examples, naming what changed in `@return`, and when `\dontrun{}` is and is not acceptable.

One habit it does not cover, because it is an assistant failure mode rather than a style
preference:

- **Do not pad.** No "This function…", no restating the function name in prose, no closing
  summary repeating the description, no comments in examples narrating what the next line does.
  **A one-sentence description is finished, not unfinished** — the instinct to keep going is the
  thing to resist.

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
- **CI** — seven reusable workflows in `animovement/.github`, six of them called by
  trigger-only stubs in each package; the required checks; the metadata-contract job; Codecov.
- **Distribution** — R-universe rather than CRAN, why `Additional_repositories` exists, the
  conda builds on prefix.dev, and the R version that WASM builds are pinned to.
- **Adding a package** — the checklist of places a new package has to be registered.

## Releases

Open a **Release checklist** issue from the template and work through it — `reference/release-checklist.md`
is the same content, for reading rather than ticking off. The thing worth knowing in advance is that the version appears
in five places that go stale independently: `DESCRIPTION`, `CITATION.cff`, `inst/CITATION`,
the `NEWS.md` heading, and the rendered `README.md` (the version is embedded in the startup
banner and the citation block, so it must be re-rendered). After the release, `DESCRIPTION`
goes to `<next>.9000` and `NEWS.md` opens a fresh `# <package> (development version)`.

## Development versions across packages

The packages depend on each other's **development** versions, installed from R-universe, so
code another package needs is usable only once it is there under a new version number.

- **anicore bumps in the feature pull request** when downstream will require the new code:
  animovement/anicore#163 took it to `0.8.0.9003`, #171 to `0.8.0.9004`.
- **The other packages bump in a pull request of their own**, touching only `DESCRIPTION`:
  `chore(<pkg>): bump development version to <x>` (animovement/animetric#75,
  animovement/anispace#46). The conda builds depend on it too: the animovement-forge
  nightly publishes a package only when R-universe shows a new version (see
  `reference/packaging.md`), so commits merged without a bump do not reach prefix.dev until
  the next one.
- **Downstream raises its dependency floor** in the pull request that starts using the new
  code — `anicore (>= 0.8.0.9004)` in `Imports`.
- **Then wait for R-universe.** CI installs `ani*` dependencies from
  `animovement.r-universe.dev`, so a downstream check fails to resolve the new floor until
  R-universe has rebuilt the upstream package (about ten minutes after the merge, as
  observed). Re-run the checks once
  `https://animovement.r-universe.dev/api/packages/<pkg>` reports the version.

## Stacked pull requests

A large change can land as a stack, each pull request based on the branch of the one below
(the anicore restructure was animovement/anicore#156–#163). Each layer lands on `main` as its
own squash commit.

- **Squashing rewrites the lower layer.** Its commits reach `main` as one new commit, while
  the upper branch still carries the originals. Replay only the upper layer's own commits:
  `git rebase --onto origin/main <lower-branch> <upper-branch>`, then force-push.
- **Retarget the upper pull request to `main`** if it still points at the merged branch.
  GitHub retargets dependent pull requests only when the merged branch is deleted, and these
  repositories do not delete branches on merge.
- Every required check runs on a stacked pull request: those stubs trigger on all pull
  requests, whatever their base.
