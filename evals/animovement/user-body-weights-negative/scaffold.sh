#!/usr/bin/env bash
# Weekly body weights of mice by genotype: animal data, but no tracking
set -euo pipefail

mkdir -p data

cat > data/body_weights.csv <<'EOF'
mouse_id,genotype,sex,week,weight_g
M01,WT,F,4,17.8
M01,WT,F,5,18.6
M01,WT,F,6,20.0
M01,WT,F,7,21.1
M02,WT,M,4,18.9
M02,WT,M,5,20.1
M02,WT,M,6,21.4
M02,WT,M,7,22.1
M03,WT,F,4,17.7
M03,WT,F,5,18.8
M03,WT,F,6,19.6
M03,WT,F,7,21.0
M04,KO,F,4,17.2
M04,KO,F,5,17.5
M04,KO,F,6,18.6
M04,KO,F,7,19.3
M05,KO,M,4,19.6
M05,KO,M,5,20.4
M05,KO,M,6,20.9
M05,KO,M,7,21.4
M06,KO,M,4,18.5
M06,KO,M,5,19.6
M06,KO,M,6,19.9
M06,KO,M,7,21.0
EOF

cat > weights.R <<'EOF'
library(readr)

weights <- read_csv("data/body_weights.csv")

# TODO: mean weight and standard error per genotype and week, and growth curves
EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
EOF
