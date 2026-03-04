#!/usr/bin/env bash
# Example configuration for Module 04: SBSI-TFs overlap aggregation
# Copy to config.sh and edit paths as needed.

# Working directory (will be created if missing). The wrapper will `cd` into this directory.
WORK_DIR="./work"

# Directory containing TF peak BED files (*.bed).
# If empty, the wrapper will scan BED files under WORK_DIR (matching the original workflow that symlinks beds into the run directory).
BED_DIR=""

# Optional: If you have a table listing TF/cluster IDs (first column) and want to create symlinks automatically,
# set CLUSTER_INFO and PEAK_BED_SOURCE_DIR. The script will symlink <ID>.bed into WORK_DIR.
CLUSTER_INFO=""           # e.g., "/path/to/cluster.info"
PEAK_BED_SOURCE_DIR=""    # e.g., "/path/to/ExactName_peak_bed"

# Filters
MIN_TF=10                 # Keep overlap segments covered by at least MIN_TF TFs
MIN_REGION_LEN=55         # Keep merged regions with length >= MIN_REGION_LEN (bp)

# Output file naming
# If empty, outputs will follow the original names:
#   overlaps_with_sources.bed
#   <MIN_TF>TF-overlaps_with_sources.bed
#   final_regions_with_tf.bed
OUT_PREFIX=""
