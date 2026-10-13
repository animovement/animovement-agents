---
description: Using a function from an unmerged anicore pull request in animetric, so that animetric's CI passes.
expected_outcome: >-
  The anicore PR bumps anicore's development version to 0.8.0.9009; after it
  merges, animetric's PR raises its floor to `anicore (>= 0.8.0.9009)`; its CI
  installs anicore from R-universe, so it passes only once R-universe has built
  0.8.0.9009 (check the R-universe API, then re-run). The same floor goes into
  animetric's conda recipe in animovement-forge, under host and run. No
  Remotes: field.
tags: [dev, dependencies]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

I've added signed_turn() to anicore in a pull request that isn't merged yet, and I want animetric's add_kinematics() to use it. Both repositories are checked out here. What's the sequence to get the animetric change through CI?
