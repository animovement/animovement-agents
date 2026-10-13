---
name: animovement-dev
description: >-
  Use when working on the animovement R packages themselves (anicore, aniread,
  aniprocess, animetric, anivis, anicheck, anispace, the animovement
  metapackage): writing NEWS.md entries, commit messages, issues, pull request
  titles or descriptions; adding, renaming or deprecating an exported function; a failing
  R-CMD-check, pkgdown, test-coverage or format-suggest job, or a local check
  that fails; bumping a development version or using another suite package's
  new code; cutting a release; README badges, Codecov, R-universe or the conda
  builds; licensing; adding a package to the suite. Not for analysing movement
  data with the packages: that is the animovement skill.
---

# animovement-dev

For working **on** the animovement packages. Eight repositories under
[github.com/animovement](https://github.com/animovement) share one CI, one pkgdown theme and
one release process, kept in [animovement/.github](https://github.com/animovement/.github).
anicore is at the bottom: aniread, aniprocess and anispace import it, animetric also imports
anispace, anivis suggests animetric and anicheck, anicheck suggests anivis, and the
animovement metapackage imports all seven. `anievent`, `anisegment` and `anijoint` are
classes in anicore. The `anievent` repository is for a planned package (behaviour and action
segmentation, changepoint detection), still empty, and `animodel` is empty too.

## Where the rules are written

Read the relevant document before acting; this skill adds what they leave out. The first
five are copies of animovement/.github made by its Sync agent docs workflow: never edit them
here, and when a detail matters, check the source URL in their header, since a copy can lag.

| For | Read |
|---|---|
| Setup, PRs (stacked ones too), commit types, NEWS.md, development versions, lifecycle, code and documentation style, what CI runs | `reference/contributing.md` |
| AI-assisted work | `reference/ai-policy.md` |
| Cutting a release | `reference/release-checklist.md` |
| A pull request body | `reference/pull-request-template.md` |
| An issue body | `reference/issue-templates.md` |
| Licensing, README, CI layout, Codecov, R-universe, conda, adding a package | `reference/packaging.md` |
| A check failing, locally or on CI | `reference/checks.md` |
| Issues, PRs and commits through `gh` or the API | `reference/github-api.md` |
| A package's functions and signatures | `https://animovement.dev/<package>/llms.txt` |

## Rules

1. **Verify, don't recall.** Check a function against the package's `llms.txt`, its
   `reference/<topic>.md` page, or the source on `origin/main`: the suite was split and
   renamed (aniframe became anicore, `aniframe()` became `anipoint()`), so a plausible name
   may be wrong. Read a file or log in full before describing it, not its first lines, and
   confirm what a grep suggests by running the code.
2. **Say which build you tested.** `library(pkg)` loads the installed build, usually
   R-universe's, not your branch. Test with `devtools::load_all()`; install the branch
   (`devtools::install()`) before rendering `README.qmd` or a vignette.
3. **Switch renv's autoloader off, as CI does:** `RENV_CONFIG_AUTOLOADER_ENABLED=false` in
   `~/.Renviron`. Otherwise each package's `.Rprofile` activates a project library chosen by
   the directory R starts in, so a check, build or render started elsewhere uses another
   library and fails like a dependency problem.
4. **Never push to `main`;** open a pull request. Fill in every section of the template, say
   that the work was AI-assisted, and leave the last checkbox (read and tested it yourself)
   to the human.
5. **Edit sources, not outputs:** roxygen comments, not `man/`; `README.qmd`, not
   `README.md`; the shared workflow or canonical stub in animovement/.github, not a
   package's `.github/workflows/`, which the next sync puts back.
6. **Format with [air](https://posit-dev.github.io/air/)** (`air format .`), not styler;
   `format-suggest` is a required check. The `/style` and `/document` PR comments work only
   for organisation members and owners.
7. **Outside anicore, touch metadata only through anicore's accessors** (`get_metadata()`,
   `set_metadata()`, `get_variables()`, `get_keys()`, `get_index()`). The
   `anicore-metadata-contract` job fails on `attr(x, "metadata")` and `$variables_*`.
8. **The PR title is a Conventional Commit:** `fix(aniprocess): keep metadata through
   filter_kalman()`, lower-case and imperative, usually the package as scope, no full stop.
   Nothing checks it in the packages. A squash merge uses the title only for a PR with several
   commits; a single-commit PR lands as that commit's message, so make its first line the
   title. A breaking change takes `!` and a `BREAKING CHANGE:` footer in a commit message:
   the PR description never reaches `main`.
9. **NEWS.md is a changelog written by hand**, under `# <package> (development version)`, in
   Keep a Changelog's sections: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`,
   `Security`. Not the tidyverse's (`## Bug fixes`), and no `## Breaking changes`: a breaking
   change goes under `Changed` or `Removed`, saying what breaks and what to do. Give the
   effect a user sees, not the reasoning; end with `(#123)` before the full stop, or
   `(#123, @username)` crediting anyone who isn't a maintainer; no entry for a change nobody
   can observe. Some development sections still have a `## Breaking changes` heading from
   before this rule: don't add to it; point it out.

## Adding an exported function

1. **Roxygen:** sentence-case title; defaults stated in `@param`; a `@return` naming what
   changed; an example `R CMD check` can run, at the smallest shape that makes the point,
   taking its aniframe from `anicore::example_anipoint()` (namespaced, since only the
   documented package is attached; `example_aniframe()` is deprecated); `@export`. A new
   design gets `` `r lifecycle::badge("experimental")` ``.
2. **Check that the example prints:** `withVisible(f(x))$visible`. A function returning
   invisibly where its siblings don't is usually an oversight to fix.
3. **`devtools::document()`** (or `/document`) regenerates `man/` and `NAMESPACE`.
4. **Add the topic to `reference:` in `_pkgdown.yml`**, in its section. pkgdown errors on any
   topic missing there unless it is `@keywords internal`, and as the slowest job it often
   fails after everything else has passed. Topics sharing an `@rdname` are listed once;
   anicheck lists `check_*` with `starts_with("check_")`. `pkgdown::check_pkgdown()` checks
   it in seconds, once `pak::pak("animovement/animovementtemplate")` has installed the theme.
5. **Tests** in `tests/testthat/test-<name>.R`, reaching every new line (Codecov is
   informational, but PRs land fully covered). Give each `expect_error()` a `class` or a
   pattern, or it passes on an error from an earlier guard.
6. **NEWS.md** bullet under `## Added`; PR title `feat(<package>): add <fn>()`.
7. **Another package will call it?** Bump the development version in the same PR (below).

Renaming or removing one follows *Function lifecycle* in `reference/contributing.md`:
deprecate with a forwarding alias for one release, then remove it as a breaking change.

## A check fails: is it yours?

Stop at the first step that explains it. Symptoms and commands: `reference/checks.md`.

1. **Read the failing step's log**, not the job's name: `gh run view <id> --log-failed`. A
   red `test-coverage` is often not about coverage.
2. **Infrastructure:** an action that would not download, a runner or network error, a
   Codecov upload timing out. Re-run the failed jobs; change nothing.
3. **A floor R-universe hasn't built yet:** installing dependencies fails. Re-run once
   `https://animovement.r-universe.dev/api/packages/<package>` reports the version.
4. **The job fails on `main` too:** not yours. Say so, and fix it in its own PR.
5. **Yours.** R-CMD-check runs `--as-cran` and fails on any WARNING (NOTEs pass); pkgdown on
   a topic missing from `_pkgdown.yml`; format-suggest on anything air would change.

A local failure that CI doesn't show is usually the environment: Suggests not installed (CI
installs them all; so does `pak::pak()` in the package root), renv's library (rule 3), or the
installed build (rule 2). Compare with a clean checkout of `main` before calling anything a
regression.

## Using another package's new code

1. **The PR adding the code bumps its package's development version** (`0.8.0.9008` to
   `0.8.0.9009`), because a dependency can only name a version. Other PRs leave it alone.
2. **The PR using it raises the floor** in `Imports`, `anicore (>= 0.8.0.9009)`, and the same
   floor goes into `recipes/<package>/recipe.yaml` in
   [animovement-forge](https://github.com/animovement/animovement-forge), under `host` and
   `run`: the conda recipes list dependencies by hand.
3. **Wait for R-universe.** CI installs suite packages from R-universe, not GitHub, so the
   downstream checks can't resolve the floor until it has built the new version, typically
   10 to 15 minutes after the merge. Then re-run them, rather than adding `Remotes:`.

A first dependency on a suite package also needs
`Additional_repositories: https://animovement.r-universe.dev` in `DESCRIPTION`. Merged changes
reach the conda channel only with a version bump; a maintainer catches up with
`chore(<package>): bump development version to <version>`.

## Releases

Open a **Release checklist** issue and work through it: `reference/release-checklist.md` (from
`gh`, see `reference/github-api.md`). What it doesn't say:

- **Release in dependency order:** anicore; then aniread, aniprocess, anispace; animetric;
  anivis; anicheck; the metapackage last. A release depends only on releases: its PR replaces
  each `.9xxx` floor on a suite package with that package's new release (aniread#111 took
  `anicore (>= 0.6.0)` to `(>= 0.8.0)`), so upstream goes out first.
- **The version number is the maintainer's call.** Every package is below 1.0.0, where
  breaking changes have bumped the minor (anicore 0.7.0 to 0.8.0; its deprecations name 0.9.0).
- **It lives in `DESCRIPTION`, `CITATION.cff`** (`version`, `date-released`) **and the
  NEWS.md heading**, `# <package> <version> (YYYY-MM-DD)`. `inst/CITATION` reads
  `meta$Version`. Only animovement's README embeds versions, those of every suite package, so
  it is re-rendered after any release.
- **PR titles:** `chore(<package>): release <version>` from `release/<version>`, then
  `chore(<package>): begin the <version>.9000 development cycle`.
- **Name the GitHub release `v<version> — <subtitle>`:** the Zulip announcement shows the
  subtitle. To announce again, run *Post Release Notes on Zulip* by hand with the tag; never
  re-publish a release, which mints a duplicate Zenodo DOI.

## Through `gh` or the API

Templates apply only in the web UI, and the contents API commits one file at a time. The
commands are in `reference/github-api.md`:

- An issue or PR created with `gh` gets no template: write every section yourself, and set
  `--type Bug|Feature|Task` on an issue.
- A change to several files is one tree and one commit through the git data API, not one
  contents-API call per file.

## Writing

The house style is terse (*Documentation style* in `reference/contributing.md`): no "This
function…", no restating the name, no closing summary, no comments narrating the next line. A
one-sentence description is finished. A PR description says why; the diff already says what.
