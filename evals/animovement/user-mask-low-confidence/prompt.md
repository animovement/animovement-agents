---
description: Cleaning pose data. The common mistakes are dropping the low-likelihood rows with dplyr::filter(), filling every gap, smoothing without a frame rate, and the pre-rename filter_na_*() names.
expected_outcome: >-
  Masks points below 0.9 to NA and keeps the rows, with
  mask_na_across("confidence", threshold = 0.9); fills gaps of up to 10 frames
  with replace_na_across(max_gap = 10); declares sampling_rate = 50 and then
  smooths, e.g. filter_across("sgolay", ...). In that order: mask, fill,
  smooth. No dplyr::filter() on confidence, no filter_na_*().
tags: [cleaning]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

In clean.R, the points where DeepLabCut's likelihood is below 0.9 are junk: the nose jumps to the far end of the track whenever the tracker is unsure. Can you add the cleaning? Get rid of those points, fill gaps of up to 10 frames, and smooth the tracks a little. The camera ran at 50 fps.
