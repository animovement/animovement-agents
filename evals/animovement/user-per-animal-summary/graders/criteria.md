---
type: llm
---

PASS if it measures each mouse along a single trajectory before summarising, and ends with one row per mouse:

- one trajectory per mouse: a keypoint stands for the mouse (such as `filter(keypoint == "centre")`), or a point is derived per mouse with `add_point(across = "keypoint")` or `compute_point()`;
- total distance from `summarise_path()` (`total_distance`), or the final `cumulative_distance` from `add_kinematics()`;
- median speed from `add_kinematics()` followed by `summarise_aniframe()` (`median_speed`), or `median(speed)` per mouse;
- the two combined per mouse, for example joined by `individual`.

Summarising every mouse-keypoint trajectory first and then averaging those per mouse is also a PASS.

FAIL if it groups the frame by `individual` across keypoints before computing distance or speed, which pools the keypoints into one trajectory; adds up the distances of a mouse's keypoints; or uses the deprecated `calculate_kinematics()`, `summarise_kinematics()`, `summarise_tortuosity()` or `add_centroid()`.
