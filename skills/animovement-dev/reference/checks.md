# When a check fails

Read this when a check fails, locally or on CI, or before calling a failure a regression.
`SKILL.md` (*A check fails: is it yours?*) has the order to work in; `packaging.md` (*CI*)
describes the jobs themselves.

## Reading a run

```sh
gh pr checks <number> -R animovement/<package>
gh run view <run-id> -R animovement/<package> --log-failed
gh run rerun <run-id> -R animovement/<package> --failed
gh run list -R animovement/<package> --branch main --workflow R-CMD-check --limit 5
```

The last answers "does `main` fail too?". A job failing only on `ubuntu-latest (devel)` ran on a
push to `main`: R-devel is left out of pull requests.

## R-CMD-check

- **It fails on a WARNING, not only an ERROR**, and runs with `--as-cran`. NOTEs pass.
- **CI installs every dependency `DESCRIPTION` declares**, Suggests included, from R-universe
  and Posit's binaries. A package used in `tests/` or an example but not declared passes
  locally, where it happens to be installed, and fails here:
  `'::' or ':::' import not declared from: 'sf'`. Add it to `Suggests` (`Imports` if `R/`
  uses it), and start the tests that need it with `skip_if_not_installed("sf")`.
- **A floor naming a version R-universe hasn't built** fails while installing dependencies,
  before any check runs. Re-run once `https://animovement.r-universe.dev/api/packages/<package>`
  reports it.
- **An S3 method from a package that no longer exists still wins dispatch:** a stale cached
  library. Bump `cache-version` in the shared workflows (animovement/anicore#127).

## pkgdown

- **`N topics missing from index: …`:** add them to `reference:` in `_pkgdown.yml`, or mark them
  `@keywords internal`. `pkgdown::check_pkgdown()` finds this, and articles missing from an
  `articles:` index (anicore keeps one), without building the site, once the theme is
  installed: `pak::pak("animovement/animovementtemplate")`. Without it, from the package root:

  ```sh
  for f in $(grep -L '\\keyword{internal}' man/*.Rd); do
    t=$(basename "$f" .Rd)
    grep -qE "^[[:space:]]*-[[:space:]]*$t[[:space:]]*$" _pkgdown.yml || echo "$t"
  done
  ```

  It prints the topics not named in `_pkgdown.yml`; a selector such as anicheck's
  `starts_with("check_")` can cover some of them.
- It is the slowest job, so it often fails after everything else has passed.

## format-suggest

Fails when air would change anything; its suggestions are on the PR. Run `air format .`, or
ask an organisation member to comment `/style`. Don't reformat code the change doesn't touch.

## anicore-metadata-contract

Not required, but read it. Use anicore's accessors instead of the raw attribute. A line that
genuinely needs it ends in `# anicore: allow-metadata`; air moves a comment trailing `{` to the
next line, so put the read in an assignment of its own.

## test-coverage and Codecov

A red `test-coverage` is as often infrastructure as coverage: open the log first. The Codecov
statuses, `codecov/patch` and `codecov/project`, are informational and never block a merge;
Codecov comments only when coverage drops or a PR adds lines no test reaches. Measure locally:

```r
cv <- covr::package_coverage()
covr::percent_coverage(cv)
covr::zero_coverage(cv)   # lines no test reaches
```

An unreached line inside a function that has a test usually means the test stops earlier than
its name claims: `expect_error()` without a `class` or a pattern passes on an error raised by a
guard clause before the branch it was written for.

## Locally

Compare with a clean checkout of `main` before calling anything a regression; CI's result on
`main` is the reference.

- **Tests error with `there is no package called 'arrow'`:** a Suggests package isn't installed.
  `pak::pak()` in the package root installs every dependency, Suggests included, as CI does. A
  plain `R CMD check` stops earlier, at "Packages suggested but not available";
  `_R_CHECK_FORCE_SUGGESTS_=false` (as on CI) gets past that, but tests that need the package
  still fail unless they skip.
- **`dependencies … are not available`, or `Package required and available but unsuitable
  version`, while `packageVersion()` looks right:** two libraries. renv's autoloader picks a
  project library by the directory R starts in, and `R CMD build`, `R CMD check` and
  `quarto render` each start R. Set `RENV_CONFIG_AUTOLOADER_ENABLED=false` in `~/.Renviron`
  (or before the command), and compare `.libPaths()` where it works and where it fails.
- **A function fails that works on the branch:** the installed build is older. Use
  `devtools::load_all()`, or `devtools::install()` first.
- **A rendered README shows an old version or citation:** the same. Install the branch, then
  render from the package root.
- **An example prints nothing:** the function returns invisibly. Fix it if its siblings return
  visibly; otherwise wrap the call in `print()`.
