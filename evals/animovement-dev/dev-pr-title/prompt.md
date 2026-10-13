---
description: Title and description for a single-commit bug-fix pull request to anispace, opened with gh.
expected_outcome: >-
  Title `fix(anispace): keep metadata through map_to_polar()` or similar: a
  lower-case Conventional Commit. Says to reword the single commit ("fixed polar
  metadata") to the same line, since a single-commit squash merge keeps the
  commit's message. The description fills in every section of the org's pull
  request template, which gh doesn't apply: kind of change, why, what, `Fixes
  #61`, testing, breaking change, documentation, checklist.
tags: [dev, pull-request]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

My anispace branch is ready: `map_to_polar()` used to drop the frame's metadata and now keeps it (#61). It's a single commit, with the message "fixed polar metadata". Write the pull request title and description for me; I'll open it with `gh pr create`.
