---
description: A local check of aniread's main fails in tests that need Suggests packages missing from this machine, while CI on main is green.
expected_outcome: >-
  Not a regression, and no issue about main: the failing tests need arrow and
  c3dr, which aniread lists in Suggests and which aren't installed here; CI
  installs every Suggests, which is why it is green. Install them (pak::pak() in
  the package root installs all dependencies, Suggests included) and re-run.
  Optionally, the tests could skip without them (skip_if_not_installed()).
tags: [dev, checks]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I ran devtools::check() on a fresh clone of aniread's main and got 11 test failures; the output is in check-output.txt. CI on main is green. Is main broken? Should I open an issue?
