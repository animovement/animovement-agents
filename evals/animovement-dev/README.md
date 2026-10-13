# Evals for the animovement-dev skill

Cases for [`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals): each sends a
maintainer's request about the animovement packages, in a scaffolded workspace, with the
plugin and without it, and grades the reply. Every case is named `dev-*`, so run just this
suite from the repository root with:

```sh
claude plugin eval . --scaffold --case 'dev-*'
```

`--scaffold` runs each case's `scaffold.sh`, which writes the files the request is about: a
cut-down package (`DESCRIPTION`, `NEWS.md`, `R/`, `_pkgdown.yml`, a log) with only what the
case needs. Every run is a real model call on your account: 8 cases × 3 runs × 2 arms, plus
the judge calls. While iterating on one case: `--case <name> --runs 1 --ablation none`.

The agent gets read-only tools and is told it can't run commands or edit files, so the
graders judge what it tells the user to do. `llm` graders accept every legitimate route and
fail only real errors; exact names are checked with `regex` graders.

| Case | Request | A correct agent |
|---|---|---|
| `dev-news-entry` | NEWS.md entry for a fix to `filter_kalman()` (#112) | A bullet under a new `## Fixed` in the development section, after `## Changed`: what users now get, `(#112)`. Not `## Bug fixes`, not the story of the bug |
| `dev-pr-title` | Title and description for a single-commit fix to anispace | `fix(anispace): keep metadata through map_to_polar()`; reword the commit "fixed polar metadata" to match, since a single-commit squash keeps the commit's message; every section of the org's PR template, which `gh` doesn't apply, with `Fixes #61` |
| `dev-release-prep` | What to bump to release anicheck 0.4.0 | `DESCRIPTION`, `CITATION.cff` (version and date), the NEWS.md heading with its date; not `inst/CITATION` or the README. Flags the floors on development versions of anicore and anivis, which are released first. Ends at `0.4.0.9000` |
| `dev-new-export` | What else changes after exporting `smooth_heading()` | `devtools::document()`; the topic added to `_pkgdown.yml`, or pkgdown fails; the example's unqualified, deprecated `example_aniframe()` replaced by `anicore::example_anipoint()`; tests, NEWS.md, a `feat(aniprocess):` title |
| `dev-check-missing-suggests` | A local check of aniread's main fails 11 tests; CI is green | Main isn't broken: arrow and c3dr, in Suggests, aren't installed locally. Install them (`pak::pak()` in the package root) and re-run; no issue about main |
| `dev-cross-package` | Use a function from an unmerged anicore PR in animetric | Bump anicore to `0.8.0.9009` in its PR; raise animetric's floor to it; wait for R-universe to build it before animetric's CI can pass; mirror the floor in the animovement-forge recipe. No `Remotes:` |
| `dev-readme-badges` | R-universe and Zulip badges broken in a new package's README | `default-image-extension: ""` in `README.qmd`'s header, then re-render; not a hand edit of `README.md` |
| `dev-analysis-negative` | Read SLEAP data and compute speed | Answers the analysis question; `animovement-dev` never loads (the `animovement` skill may) |

The positive cases also report whether the skill fired (`skill-used`), which a two-arm run
shows as an indicator rather than a score. In the negative case, `dev-skill-not-used` is
scored in both arms (`arm: both`), and `user-skill-used` is an indicator.
