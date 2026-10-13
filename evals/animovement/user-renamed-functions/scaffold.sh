#!/usr/bin/env bash
# An analysis written in August 2026, against the releases, which no longer runs on current builds
set -euo pipefail

mkdir -p data results

cat > data/epm_mouse4DLC_resnet50_epmSep2shuffle1_150000.csv <<'EOF'
scorer,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000,DLC_resnet50_epmSep2shuffle1_150000
bodyparts,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase
coords,x,y,likelihood,x,y,likelihood,x,y,likelihood
0,500.5,285.2,0.975,500.8,266.7,0.948,499.8,249.2,0.951
1,502.5,291.8,0.984,500.4,273.6,0.992,499.2,255.7,0.985
2,504.0,298.4,0.968,501.9,280.5,0.975,499.1,262.9,0.936
3,505.3,306.2,0.958,503.4,287.8,0.972,500.4,270.3,0.938
4,507.9,312.5,0.943,503.7,295.1,0.965,500.3,277.0,0.945
5,510.5,319.0,0.937,506.3,301.0,0.949,501.0,284.3,0.938
6,512.8,325.0,0.963,508.0,308.3,0.961,502.8,290.8,0.971
7,515.2,331.9,0.946,510.5,315.4,0.935,503.9,298.0,0.969
8,518.3,338.5,0.995,512.4,321.2,0.969,506.7,304.3,0.951
9,521.9,344.6,0.962,514.9,327.7,0.932,508.0,311.9,0.970
10,525.6,351.0,0.955,517.9,333.6,0.940,510.2,317.6,0.990
11,529.5,356.0,0.972,522.0,340.1,0.983,513.0,324.5,0.971
12,534.4,362.4,0.965,525.3,346.3,0.957,516.5,330.9,0.983
13,538.0,368.1,0.972,528.4,352.9,0.962,518.9,336.9,0.937
14,542.4,373.2,0.940,532.3,358.1,0.968,522.3,343.7,0.948
15,547.4,378.1,0.220,536.5,363.3,0.980,525.6,349.5,0.945
16,552.7,383.4,0.954,541.7,369.4,0.968,529.3,355.1,0.948
17,557.7,388.5,0.990,545.3,374.7,0.994,534.0,360.5,0.990
18,563.0,393.2,0.990,551.0,380.1,0.935,538.6,366.3,0.939
19,568.5,397.1,0.930,555.6,384.8,0.964,542.8,371.6,0.997
20,574.0,401.3,0.975,560.3,389.7,0.946,548.1,377.6,0.992
21,580.6,404.9,0.961,566.1,394.1,0.932,552.0,382.6,0.986
22,586.4,409.2,0.966,572.3,397.7,0.992,557.0,386.8,0.970
23,592.7,412.0,0.977,578.2,401.7,0.944,562.3,391.9,0.963
EOF

cat > analysis.R <<'EOF'
# Elevated plus maze, mouse 4. Written in August 2026.
library(animovement)
library(dplyr)
library(ggplot2)

movement <- read_dataset("data/epm_mouse4DLC_resnet50_epmSep2shuffle1_150000.csv") |>
  set_sampling_rate(30) |>
  set_unit_space("cm", calibration_factor = 9 / 140)

clean <- movement |>
  filter_na_across("confidence", threshold = 0.6) |>
  replace_na_across("linear", max_gap = 5) |>
  filter_across("sgolay", window_width = 11, order = 3)

kin <- calculate_kinematics(clean)

per_keypoint <- summarise_kinematics(kin)
write.csv(per_keypoint, "results/summary.csv", row.names = FALSE)

kin |>
  filter(keypoint == "centre") |>
  ggplot(aes(time, heading)) +
  geom_line()
ggsave("results/heading.png", width = 6, height = 3)
EOF

cat > results/.gitkeep <<'EOF'

EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
EOF
