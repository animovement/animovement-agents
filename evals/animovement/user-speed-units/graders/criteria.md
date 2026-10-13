---
type: llm
---

PASS if the response says the current speed is in pixels per frame (DeepLabCut records neither a frame rate nor a scale) and gets it in cm/s by converting the data before `add_kinematics()`:

- time: `set_metadata(sampling_rate = 25)` then `convert_unit_time("s")`, or `convert_unit_time("s", calibration_factor = 1/25)`;
- space: `convert_unit_space("cm", calibration_factor = 50/1000)`, that is 0.05 cm per px.

Multiplying the existing px-per-frame speeds by 0.05 × 25 = 1.25 is also a PASS, provided it says the result is cm/s (a median of about 12.5). Mentioning that the smoothing or masking steps are unaffected, or that the conversions could go right after reading, is fine.

FAIL if it only declares the units without rescaling the values: `set_metadata(unit_space = "cm")`, or `set_metadata(sampling_rate = 25)` without converting time, both of which leave speed in px per frame. Also FAIL if it uses a wrong factor (such as 1000/50 = 20 cm per px, or dividing by 25 instead of multiplying), or the removed `set_unit_space()` or `set_sampling_rate()`.
