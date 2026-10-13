---
description: Per-animal summaries from multi-animal pose data, where each keypoint is its own trajectory. Grouping by individual pools the keypoints and measures the jumps between them.
expected_outcome: >-
  Reduces each mouse to one trajectory, a keypoint such as centre or a point
  from add_point(across = "keypoint"), then takes total_distance from
  summarise_path() and median_speed from add_kinematics() with
  summarise_aniframe(), joined into one row per mouse. Never group_by(individual)
  over all keypoints before measuring.
tags: [metrics, summaries]
max_turns: 20
allowed_tools: [Read, Glob, Grep, Skill]
append_system_prompt: Shell commands and R can't run in this session, and files can't be edited. Tell the user exactly what to run, in order.
---

analysis.R has three mice tracked together, already cleaned and in cm. For the stats I need one row per mouse with its total distance travelled and its median speed. How do I get that?
