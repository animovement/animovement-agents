#!/usr/bin/env bash
# Three mice tracked together with multi-animal DeepLabCut, cleaned and calibrated
set -euo pipefail

mkdir -p data

cat > data/social_triad_DLC_resnet50_socialOct2shuffle1_50000.csv <<'EOF'
scorer,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000,DLC_resnet50_socialOct2shuffle1_50000
individuals,mouse1,mouse1,mouse1,mouse1,mouse1,mouse1,mouse1,mouse1,mouse1,mouse2,mouse2,mouse2,mouse2,mouse2,mouse2,mouse2,mouse2,mouse2,mouse3,mouse3,mouse3,mouse3,mouse3,mouse3,mouse3,mouse3,mouse3
bodyparts,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase,snout,snout,snout,centre,centre,centre,tailbase,tailbase,tailbase
coords,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood,x,y,likelihood
0,222.5,202.3,0.906,205.5,200.9,0.973,190.2,199.0,0.960,473.9,298.0,0.916,458.5,292.7,0.972,443.9,288.3,0.954,717.8,401.3,0.904,707.1,389.2,0.932,697.3,377.4,0.952
1,227.8,203.7,0.902,211.7,201.0,0.951,196.7,199.1,0.918,483.3,299.1,0.973,467.8,295.3,0.978,451.6,291.7,0.995,723.3,412.5,0.971,714.5,399.1,0.949,705.9,386.0,0.982
2,233.1,207.1,0.989,217.7,202.9,0.991,202.5,199.0,0.922,491.8,299.2,0.916,476.7,296.1,0.990,460.1,294.4,0.970,728.7,423.2,0.964,720.7,409.2,0.921,712.5,396.2,0.962
3,238.1,210.2,0.972,223.9,204.4,0.974,207.7,199.9,0.927,500.8,298.9,0.911,485.2,297.5,0.924,468.8,296.3,0.942,733.1,434.1,0.936,725.4,420.4,0.908,719.4,405.3,0.972
4,243.1,213.0,0.981,228.5,206.7,0.968,214.1,200.3,0.998,509.7,296.6,0.934,494.3,297.4,0.911,477.9,296.6,0.944,736.3,446.6,0.989,730.5,431.8,0.970,724.3,416.2,0.965
5,248.2,216.8,0.944,234.7,209.4,0.958,220.0,202.5,0.914,519.6,294.8,0.960,503.0,295.8,0.955,486.7,297.2,0.903,737.8,457.8,0.963,733.6,443.5,0.992,729.6,427.3,0.944
6,252.6,221.7,0.962,239.7,213.3,0.925,225.7,204.6,0.900,527.2,292.3,0.120,512.3,294.7,0.910,495.8,297.2,0.922,739.5,470.2,0.931,736.3,454.3,0.990,733.3,439.3,0.943
7,257.0,226.3,0.905,244.1,216.7,0.918,230.9,207.4,0.936,536.3,289.5,0.120,520.5,293.4,0.937,504.6,296.9,0.910,739.5,482.8,0.967,737.1,466.5,0.941,735.6,450.3,0.958
8,260.2,230.9,0.937,249.2,220.1,0.975,236.3,210.1,0.939,544.4,285.3,0.939,528.8,289.5,0.908,514.5,295.2,0.995,739.3,493.9,0.965,738.6,478.8,0.949,737.3,462.5,0.979
9,263.7,236.4,0.947,253.4,225.3,0.992,242.1,213.2,0.923,552.3,280.0,0.942,537.8,287.0,0.958,523.2,292.2,0.935,738.1,506.1,0.941,737.4,490.0,0.989,739.0,474.7,0.913
10,266.6,241.5,0.966,256.9,229.4,0.952,246.0,217.2,0.994,560.1,274.5,0.951,545.8,282.0,0.989,531.3,290.0,0.940,735.5,518.7,0.957,736.2,502.4,0.903,738.5,487.0,0.918
11,269.3,247.5,0.940,260.4,235.0,0.970,250.9,221.9,0.933,567.0,269.2,0.975,553.6,277.2,0.962,539.5,286.3,0.997,731.5,529.4,0.946,734.6,514.7,0.964,737.8,497.9,0.993
12,271.5,253.5,0.990,263.6,239.1,0.981,255.4,225.4,0.974,573.3,262.3,0.980,560.0,272.3,0.943,547.3,281.8,0.946,726.6,541.8,0.907,730.6,525.8,0.983,735.6,510.7,0.948
13,273.0,259.2,0.926,265.8,244.4,0.908,259.1,230.2,0.974,579.5,255.6,0.967,567.5,266.7,0.913,554.7,276.7,0.946,721.4,551.5,0.955,727.7,536.9,0.953,732.4,522.0,0.986
14,273.5,265.7,0.948,268.0,251.1,0.908,262.5,235.4,0.964,584.9,248.5,0.939,573.8,259.3,0.963,562.2,271.3,0.984,715.8,562.7,0.930,721.8,547.9,0.923,728.5,534.0,0.911
15,274.6,271.5,0.936,269.5,255.8,0.945,264.7,240.9,0.929,589.8,241.0,0.944,579.3,253.4,0.932,568.5,264.9,0.919,708.7,572.3,0.935,716.6,558.1,0.980,724.2,544.4,0.982
EOF

cat > analysis.R <<'EOF'
library(animovement)
library(dplyr)

mice <- read_dataset("data/social_triad_DLC_resnet50_socialOct2shuffle1_50000.csv") |>
  set_metadata(sampling_rate = 25) |>
  convert_unit_time("s") |>
  convert_unit_space("cm", calibration_factor = 0.05) |>
  mask_na_across("confidence", threshold = 0.8) |>
  replace_na_across("linear", max_gap = 5)

# TODO: one row per mouse, with total distance travelled (cm) and median speed (cm/s)
EOF

cat > .gitignore <<'EOF'
.Rproj.user
.Rhistory
.RData
EOF
