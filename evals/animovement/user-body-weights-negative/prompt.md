---
description: A near miss. Mice, individuals and repeated measures over time, but body weights rather than tracking, so the skill shouldn't load.
expected_outcome: >-
  Plain dplyr and ggplot2: group_by(genotype, week), summarise() the mean and
  standard error of weight_g, and a line per genotype across weeks. No
  animovement packages, no anipoint. The animovement skill isn't invoked.
tags: [negative]
max_turns: 15
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

Using data/body_weights.csv, can you add to weights.R the mean body weight and its standard error for each genotype in each week, and a plot of the growth curves?
