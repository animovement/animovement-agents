#!/usr/bin/env bash
# An analysis project that uses the animovement packages
set -euo pipefail

mkdir -p data
: > data/session1.analysis.h5

cat > analysis.R <<'EOF'
library(aniread)
library(animetric)

# SLEAP analysis export: two mice in an open field, 30 fps
path <- "data/session1.analysis.h5"
EOF
