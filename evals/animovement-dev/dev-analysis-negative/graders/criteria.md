---
type: llm
---

PASS if the response answers the analysis question with R code that reads the SLEAP file with a function from aniread (such as `read_sleap()` or `read_dataset()`) and computes each mouse's speed with a function from the animovement packages (such as `add_kinematics()`), and stays on the analysis. Further analysis advice (cleaning, units, sampling rate, plotting, checking names in the docs) is staying on the analysis. Judge only the response's text: which skills or tools were used is checked elsewhere.

FAIL if it brings in contributor material the question didn't ask about, such as NEWS.md, pull requests, releases, CI, or how to develop the packages.
