---
description: Broken R-universe and Zulip badges in a new suite package's README, rendered from README.qmd without the image-extension setting.
expected_outcome: >-
  Quarto appended ".png" to the extensionless badge URLs (the .svg ones are
  untouched). Add `default-image-extension: ""` under `format: gfm:` in
  README.qmd's YAML header, re-render README.md from it (quarto render
  README.qmd, with the package installed), and commit both; not a hand edit of
  README.md, which the next render would undo.
tags: [dev, readme]
max_turns: 25
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands can't run and files can't be edited in this session. Answer with what to change and what to run.
---

On GitHub, the R-universe and Zulip badges in the README of our new package, anigait, show as broken images, while the R-CMD-check and Codecov badges are fine. What's wrong, and how do I fix it?
