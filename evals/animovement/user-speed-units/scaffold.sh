#!/usr/bin/env bash
# A mouse in an open field; speed.R computes speed without declaring the frame rate or scale
set -euo pipefail

mkdir -p data

cat > data/mouse2_openfieldDLC_resnet50_openfieldOct1shuffle1_100000.csv <<'EOF'
scorer,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000
bodyparts,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase
coords,x,y,likelihood,x,y,likelihood,x,y,likelihood
0,326.8,413.3,0.977,310.1,417.1,0.946,291.8,421.6,0.981
1,336.7,412.0,0.945,319.2,415.5,0.988,302.0,418.5,0.949
2,346.8,411.8,0.986,329.7,414.4,0.981,312.1,417.1,0.948
3,357.7,411.2,0.982,339.4,413.0,0.955,321.3,414.6,0.938
4,367.7,412.0,0.998,349.5,412.6,0.982,330.9,413.7,0.961
5,376.9,412.2,0.966,359.0,412.5,0.972,341.2,412.1,0.964
6,387.0,413.6,0.943,369.1,412.5,0.975,351.9,412.0,0.980
7,397.7,415.3,0.940,379.6,414.5,0.974,360.9,412.1,0.990
8,407.4,418.6,0.944,389.6,415.4,0.979,370.9,413.4,0.972
9,416.8,420.8,0.973,399.0,417.6,0.955,381.6,413.8,0.950
10,425.7,424.7,0.938,408.3,419.5,0.974,391.3,415.6,0.933
11,435.3,428.1,0.936,417.6,423.6,0.938,400.7,417.4,0.971
12,444.0,432.5,0.955,428.0,425.8,0.953,410.7,420.8,0.966
13,453.3,437.5,0.950,436.2,430.3,0.993,420.5,423.0,0.977
14,462.4,442.2,0.971,445.6,434.3,0.950,429.2,426.6,0.933
15,470.2,447.6,0.982,454.7,438.8,0.983,438.4,430.8,0.968
16,478.2,453.8,0.960,462.7,445.1,0.938,448.1,434.9,0.951
17,486.1,459.9,0.939,471.2,450.2,0.990,457.1,439.6,0.967
18,493.2,467.6,0.952,479.8,456.4,0.939,464.4,445.2,0.990
19,500.3,474.4,0.956,486.8,463.2,0.945,473.5,451.4,0.995
20,507.5,482.4,0.960,494.4,469.8,0.988,481.6,456.9,0.939
21,513.8,490.1,0.967,501.0,477.3,0.951,488.2,463.3,0.932
22,520.0,497.3,0.979,508.3,484.9,0.986,495.9,470.9,0.987
23,525.5,506.0,0.983,513.6,491.9,0.999,502.8,477.7,0.984
EOF

cat > speed.R <<'EOF'
library(animovement)

mouse <- read_dataset("data/mouse2_openfieldDLC_resnet50_openfieldOct1shuffle1_100000.csv") |>
  mask_na_across("confidence", threshold = 0.9) |>
  replace_na_across("linear", max_gap = 5)

kin <- add_kinematics(mouse)
median(kin$speed, na.rm = TRUE)
EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
EOF
