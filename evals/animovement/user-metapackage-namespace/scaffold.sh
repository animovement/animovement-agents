#!/usr/bin/env bash
# A Quarto report that calls every function through animovement::, which fails to render
set -euo pipefail

mkdir -p data

cat > data/larvae_trajectories.csv <<'EOF'
seconds,x1,y1,x2,y2
0.000,303.894,220.915,516.819,412.425
0.020,307.823,221.667,513.704,414.934
0.040,311.781,222.241,510.400,417.190
0.060,315.780,222.335,506.952,419.217
0.080,319.682,221.456,503.722,421.576
0.100,320.159,221.307,503.377,421.938
0.120,320.651,221.216,503.068,422.331
0.140,321.151,221.197,502.678,422.644
0.160,321.644,221.117,502.234,422.875
0.180,322.144,221.113,501.773,423.068
0.200,326.026,220.149,498.117,424.690
0.220,329.962,219.433,nan,nan
0.240,333.761,218.183,nan,nan
0.260,337.383,216.484,487.811,430.796
0.280,340.864,214.514,484.319,432.746
0.300,341.316,214.300,483.839,432.886
0.320,341.743,214.040,483.403,433.131
0.340,342.219,213.887,482.933,433.301
0.360,342.712,213.805,482.461,433.466
0.380,343.190,213.659,482.024,433.709
EOF

cat > report.qmd <<'EOF'
---
title: "Zebrafish larvae: first look"
format: html
---

Two larvae tracked with idtracker.ai at 50 fps.

```{r}
tracks <- animovement::read_dataset("data/larvae_trajectories.csv")
animovement::check_na_gapsize(tracks)
animovement::plot_trajectory(tracks)
```

```{r}
kin <- animovement::add_kinematics(tracks)
animovement::summarise_path(tracks)
```
EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
/.quarto/
*_files/
EOF
