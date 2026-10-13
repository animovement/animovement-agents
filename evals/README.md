# Evals

Eval suites for the plugin's two skills, run with
[`claude plugin eval`](https://code.claude.com/docs/en/plugin-evals). Each case sends a realistic
request in a scaffolded workspace, with the plugin loaded and without it, and grades the reply.

| Suite | Skill | Case names | Cases |
|---|---|---|---|
| [`animovement/`](animovement/) | `animovement`: analysing data with the packages | `user-*` | [animovement/README.md](animovement/README.md) |
| [`animovement-dev/`](animovement-dev/) | `animovement-dev`: working on the packages | `dev-*` | [animovement-dev/README.md](animovement-dev/README.md) |

`claude plugin eval` finds every case below this directory, so both suites run together unless
you filter by name.

## Running

From the repository root:

```sh
claude plugin eval . --scaffold                       # both suites
claude plugin eval . --scaffold --case 'user-*'       # the animovement suite
claude plugin eval . --scaffold --case 'dev-*'        # the animovement-dev suite
```

- `--scaffold` runs each case's `scaffold.sh`, which writes the files the request is about:
  small tracking exports, R scripts, a package checkout. The scripts run as you, so pass it only
  for suites you trust.
- Every run is a real model call on the runner's own Claude login and plan (or API key):
  cases × 3 runs × 2 arms (with the plugin and without), plus three judge calls per `llm`
  grader per run.
- While iterating:
  `claude plugin eval . --scaffold --runs 1 --ablation none -j 4 --no-publish`, with
  `--case <name>` for one case. `--ablation none` skips the no-plugin arm, `-j 4` runs four
  cases at once, `--no-publish` keeps the HTML report local.
- To check that a suite loads without making any model call:
  `claude plugin eval . --case 'user-*' --max-cost-usd 0`. The ceiling stops every run before
  it starts, so the command exits 2; a case file that fails to load is reported above the
  table. Where the CLI can't ask whether to trust the directory, add `--trust-plugin`.
- Results go to `evals/results/<timestamp>/` (`report.html`, `aggregate-result.json`), which
  git ignores.
- The default `--threshold` is 1.0, so the command exits 1 whenever a case scores below perfect.
  Read the scores, not just the exit code.

## How the cases are built

- The agent gets read-only tools (`Read`, `Glob`, `Grep`, `Skill`) and is told that commands
  can't run, so graders judge what it tells the user to run, not the result of running it.
  It can't fetch the generated docs either, so the skill has to carry what a case needs.
- `regex` graders check the exact function names a correct answer must contain.
- `llm` rubrics name every legitimate route as a PASS and fail only genuine errors; a rubric
  stricter than that fails correct answers.
- A `tool_used: Skill` grader reports whether the skill loaded. In a two-arm run it is an
  indicator, not part of the score. Negative cases assert the skill did *not* load, scored in
  both arms (`arm: both`).
- Case names are unique across both suites, and carry the suite's prefix: `--case` and the
  report key on them.
- Graders name current functions. When the packages rename one, update the graders with the
  skill.
