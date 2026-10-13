---
type: llm
---

PASS if it computes the mean and standard error of `weight_g` for each genotype and week (for example `group_by(genotype, week)` then `summarise(mean = mean(weight_g), se = sd(weight_g) / sqrt(n()))`) and plots mean weight against week with one line per genotype, using ordinary R such as dplyr and ggplot2. Error bars or a ribbon, base R instead of the tidyverse, or extra plots per sex are all fine.

FAIL if it uses any animovement package (animovement, anicore, aniread, animetric, …), converts the data into an anipoint or aniframe, or treats the body weights as tracking data.
