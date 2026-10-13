---
type: llm
---

PASS if the updated script makes all of these replacements:

- `set_sampling_rate(30)` by `set_metadata(sampling_rate = 30)` followed by `convert_unit_time("s")`, since the old function also converted time to seconds;
- `set_unit_space("cm", calibration_factor = 9 / 140)` by `convert_unit_space("cm", calibration_factor = 9 / 140)`;
- `filter_na_across()` by `mask_na_across()`;
- `calculate_kinematics()` by `add_kinematics()`;
- `summarise_kinematics()` by `summarise_aniframe()` (also adding `summarise_path()` is fine);
- the plotted `heading` column by `course`, the direction of travel it was renamed to. Declaring a body heading with `add_orientation()` and plotting that instead is also a PASS if the response explains the difference.

The order of the unit steps, the file names, and keeping or adding `library()` calls don't matter.

FAIL if the updated code still calls `set_sampling_rate()`, `set_unit_space()`, `filter_na_across()`, `calculate_kinematics()` or `summarise_kinematics()`; replaces `set_unit_space()` with `set_metadata(unit_space = "cm")`, which relabels pixels as centimetres without rescaling; replaces `set_sampling_rate(30)` without both declaring the 30 fps rate (the Savitzky-Golay filter needs it) and converting time to seconds; or still plots a `heading` column that nothing creates.
