#!/usr/bin/env bash
# Configuration for Module 05: MCL-community analysis
# Please copy this file to config/config.sh and edit paths as needed.

# Input PPI file in MCL --abc format (tab-separated):
#   col1: protein_A
#   col2: protein_B
#   col3: weight (e.g., PSM). If not available, you can set all weights to 1.
INPUT_PPI="path/to/bait-prey.with-PSM.tsv"

# Output directory (will be created if not exists)
OUTPUT_DIR="./work"

# MCL parameters
MCL_BIN="mcl"
MCL_INFLATION="2.0"

# Community membership post-processing
MIN_COMMUNITY_SIZE="3"
COMMUNITY_PREFIX="community"

# Rscript binary
RSCRIPT_BIN="Rscript"

# Python binary
PYTHON_BIN="python3"
