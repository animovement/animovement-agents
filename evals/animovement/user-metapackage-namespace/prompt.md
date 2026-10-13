---
description: A "function not found" diagnosis. The metapackage attaches the suite but exports none of its functions, so animovement::read_dataset() fails; the fix is library(animovement) or the owning package's namespace, not a reinstall.
expected_outcome: >-
  Explains that animovement exports only its animovement_*() helpers. Fixes the
  report with library(animovement) and bare calls, or with each function's own
  package: aniread::read_dataset(), anicheck::check_na_gapsize(),
  anivis::plot_trajectory(), animetric::add_kinematics() and
  animetric::summarise_path(). No reinstall.
tags: [diagnosis]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

Rendering report.qmd fails in the first chunk with

    Error: 'read_dataset' is not an exported object from 'namespace:animovement'

But animovement is installed, and library(animovement) works fine in the console. What's wrong, and how do I fix the report?
