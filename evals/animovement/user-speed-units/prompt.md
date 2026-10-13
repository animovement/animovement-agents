---
description: Speed in physical units. DeepLabCut gives pixels and frames, so add_kinematics() reports px per frame until the data are converted; declaring the units with set_metadata() alone changes nothing.
expected_outcome: >-
  Explains the current speed is px per frame. Before add_kinematics(), declares
  the rate and converts: set_metadata(sampling_rate = 25) |>
  convert_unit_time("s") |> convert_unit_space("cm", calibration_factor =
  50 / 1000). The median then comes out near 12.5 cm/s. No set_metadata()
  relabelling without conversion, no wrong factor, no set_unit_space().
tags: [units, metrics]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

speed.R prints a median speed of about 10, but I don't know in what unit, and the paper needs cm/s. The camera recorded at 25 fps, and the arena is 50 cm across, which is 1000 px in the video. How do I get the speed in cm/s?
