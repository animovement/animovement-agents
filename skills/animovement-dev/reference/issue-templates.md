<!--
  Generated from .github/ISSUE_TEMPLATE/{bug_report,feature_request}.yml in animovement/.github — do not edit here.
  Edit it there; the Sync agent docs workflow opens a pull request with the change.

  Source: https://github.com/animovement/.github/blob/main/.github/ISSUE_TEMPLATE/{bug_report,feature_request}.yml
  Commit: 37da74bf2231c0dceed8ce1af6988763c0065f82
  Synced: 2026-08-25

  This copy can lag its source. If a detail matters, check the URL above.
-->

# Issue templates, as markdown

The bug and feature templates are **GitHub issue forms**. They apply only in the web
UI — an issue opened with `gh issue create` or through the API gets none of their
structure, and the YAML cannot be passed as a body. Reproduce the fields below by
hand, and set the type explicitly with `--type`.

```sh
gh issue create --type Bug --title "..." --body-file body.md
```

## Bug report

`--type Bug` · Something in an animovement package does not work as expected

Fields, in order:

- **What happened?** — required, textarea
  What went wrong, and what you were trying to do.
- **Reproducible example** — required, textarea
  The smallest piece of code that shows the problem. The [reprex](https://reprex.tidyverse.org) package makes this easy — `reprex::reprex({ ... })` runs your code and copies the result, output and all, ready to paste here. If the problem depends on a particular file, say which tool produced it, and attach a small excerpt if you can share one.
- **What did you expect to happen?** — required, textarea
- **Session information** — required, textarea
  Please paste the output of `animovement::animovement_sitrep()`, which reports your R version and the version of every animovement package. If animovement will not load, `sessionInfo()` is the next best thing.
- **Anything else?** — optional, textarea
  Screenshots, the full error message, or context about what you were working towards.

Body skeleton:

````markdown
## What happened?

<!-- required -->

## Reproducible example

```r

```

## What did you expect to happen?

<!-- required -->

## Session information

```text

```

## Anything else?

<!-- optional -->

````

## Feature request

`--type Feature` · Suggest an idea for an animovement package

Fields, in order:

- **What problem would this solve?** — required, textarea
  What you are trying to do, and where the current packages get in the way. Describing the problem rather than the solution often leads somewhere better.
- **What would you like to happen?** — required, textarea
  If you have a sense of what the function or argument might look like, sketching the call helps — it does not have to be right.
- **What alternatives have you considered?** — optional, textarea
  Including whether an existing function nearly does the job.
- **Anything else?** — optional, textarea
  The kind of movement data or experiment this relates to, references, prior art.

Body skeleton:

````markdown
## What problem would this solve?

<!-- required -->

## What would you like to happen?

<!-- required -->

## What alternatives have you considered?

<!-- optional -->

## Anything else?

<!-- optional -->

````
