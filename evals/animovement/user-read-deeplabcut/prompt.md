---
description: A new user's first step, reading one DeepLabCut CSV and plotting it, where a model's memory of the API is most likely to be stale.
expected_outcome: >-
  Reads the CSV with aniread after library(animovement): read_dataset(), or
  read_deeplabcut() with video_height = 720 from notes.md. Plots it with
  anivis: plot() on the frame, or plot_trajectory(). May declare the 30 fps
  rate and convert units from notes.md, saying time is in frames and positions
  in pixels until then. No invented functions, nothing called through
  animovement::, no plain CRAN install.
tags: [reading, plotting]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

I have DeepLabCut output for one mouse in data/, and animovement is installed. How do I load the tracking into R and plot the trajectories?
