#!/usr/bin/env bash
# An R project with one mouse's DeepLabCut output, before any analysis
set -euo pipefail

mkdir -p data

cat > data/openfield_m1DLC_resnet50_openfieldOct1shuffle1_100000.csv <<'EOF'
scorer,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000,DLC_resnet50_openfieldOct1shuffle1_100000
bodyparts,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase
coords,x,y,likelihood,x,y,likelihood,x,y,likelihood
0,446.0,307.0,0.994,428.7,302.3,0.971,410.9,297.7,0.973
1,454.7,310.3,0.951,436.7,305.5,0.978,419.6,300.1,0.997
2,462.5,315.3,0.941,445.0,308.5,0.934,428.5,301.5,0.932
3,470.0,319.9,0.988,453.8,312.5,0.964,437.7,304.6,0.949
4,478.0,325.9,0.988,461.9,316.4,0.946,445.6,307.5,0.983
5,484.4,331.4,0.957,469.8,321.8,0.930,453.7,312.3,0.962
6,491.8,337.0,0.935,476.7,327.0,0.949,461.4,316.0,0.997
7,497.9,343.2,0.947,483.1,331.8,0.985,469.2,321.1,0.961
8,503.2,350.8,0.939,490.4,337.9,0.959,476.6,326.0,0.997
9,509.4,357.5,0.410,496.2,344.7,0.989,484.1,331.4,0.998
10,513.8,365.0,0.983,502.2,351.4,0.935,490.1,338.1,0.947
11,518.9,373.0,0.961,508.4,358.8,0.970,497.4,344.1,0.941
12,523.4,381.6,0.947,512.5,366.6,0.995,502.5,351.9,0.991
13,526.6,389.5,0.937,516.8,374.6,0.946,508.5,358.2,0.987
14,529.8,397.9,0.942,521.7,381.5,0.946,513.4,366.4,0.972
15,532.0,407.3,0.944,524.5,390.0,0.961,517.4,373.4,0.955
16,534.4,415.2,0.955,528.6,399.3,0.975,522.2,382.0,0.940
17,535.4,424.1,0.993,531.0,407.9,0.931,525.8,390.1,0.980
18,536.7,434.3,0.935,532.9,416.4,0.992,529.0,398.9,0.985
19,537.9,442.6,0.977,534.8,425.5,0.959,531.6,407.7,0.970
20,537.5,451.7,0.970,535.5,433.5,0.974,533.9,416.5,0.980
21,536.6,461.2,0.970,535.7,443.4,0.936,535.2,424.4,0.971
22,535.5,469.6,0.978,535.7,452.1,0.994,535.6,433.4,0.951
23,534.1,478.5,0.942,535.6,461.1,0.960,536.8,442.8,0.976
EOF

cat > notes.md <<'EOF'
# Open field, mouse 1

- Camera: 1280 x 720 px, 30 fps, mounted above the arena.
- Arena: 45 cm wide, about 900 px in the video.
- Tracked with DeepLabCut (snout, centre, tailbase).
EOF

cat > analysis.R <<'EOF'
# Open field analysis, mouse 1
library(animovement)
EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
EOF
