---
description: A script written against the 2026-08-28 releases, run on current builds. Every step uses a name that was since removed, deprecated or renamed, including a column.
expected_outcome: >-
  Rewrites analysis.R for the current API: set_sampling_rate(30) becomes
  set_metadata(sampling_rate = 30) |> convert_unit_time("s"); set_unit_space()
  becomes convert_unit_space() with the same calibration; filter_na_across()
  becomes mask_na_across(); calculate_kinematics() add_kinematics();
  summarise_kinematics() summarise_aniframe(); the plotted heading column
  course (or a body heading declared with add_orientation(), explained).
tags: [renames]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

analysis.R ran fine in August. Since I updated the animovement packages this week it stops straight away with

    Error in set_unit_space(set_sampling_rate(read_dataset("data/epm_mouse4DLC_resnet50_epmSep2shuffle1_150000.csv"),  :
      could not find function "set_unit_space"

Can you bring the whole script up to date, so it runs on the current packages without errors or deprecation warnings?
