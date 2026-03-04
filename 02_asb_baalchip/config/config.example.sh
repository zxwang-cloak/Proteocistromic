#!/usr/bin/env bash
# Configuration file for BaalChIP-based allele-specific binding (ASB) analysis.
# Copy this file to config.sh and edit paths for your environment.

set -euo pipefail

############################
# Input tables
############################
# Two-column TSV with header: Input_ID, Treat_ID
SAMPLE_GROUP_TSV="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sample_group.tsv"

############################
# ChIP-seq processed inputs
############################
# Directory containing de-duplicated TF ChIP BAM files (one per Treat_ID)
# Expected filename: <Treat_ID><TREAT_BAM_SUFFIX>
TREAT_BAM_DIR="/path/to/ExactName_bam"
TREAT_BAM_SUFFIX=".df.bam"

# Directory containing MACS2 peak calls (one per Treat_ID)
# Expected filename: <Treat_ID><PEAK_SUFFIX>
TREAT_PEAK_DIR="/path/to/ExactName_narrowPeak"
PEAK_SUFFIX="_peaks.narrowPeak"

# Directory containing de-duplicated INPUT control BAM files (one per Input_ID)
# Expected filename: <Input_ID><INPUT_BAM_SUFFIX>
INPUT_BAM_DIR="/path/to/ExactName_bam"
INPUT_BAM_SUFFIX=".df.bam"

############################
# Variant set for BaalChIP
############################
# File with heterozygous variants used by BaalChIP (hg38)
HETS_FILE="/path/to/new-adj-BaalChIP-variant.txt"

############################
# Regions to filter (hg38)
############################
# Note: these files are read as TSV with header containing columns:
# chr, start, end, strand
BAALCHIP_BLACKLIST_TSV="/path/to/BaalChIP_blacklist_hg38"
BAALCHIP_HIGHCOVERAGE_TSV="/path/to/pickrell2011cov1_hg38.bed"

############################
# Intrinsic bias simulation dependencies (filterIntbias)
############################
# Provide the same order as in the original pipeline:
# 1) picard-tools directory or picard jar (BaalChIP will handle it as provided)
# 2) bowtie executable path
# 3) reference FASTA
# 4) directory of per-chromosome files
PICARD_PATH="/path/to/picard-tools-1.119"
BOWTIE_BIN="/path/to/bowtie"
REFERENCE_FASTA="/path/to/hg38.fa"
CHR_FILES_DIR="/path/to/chrFiles"

############################
# Runtime parameters
############################
MIN_BASE_QUALITY=10
MIN_MAPQ=15
ASB_ITER=5000
ASB_CONF_LEVEL=0.95
CORES=10

############################
# Output locations (relative to module root by default)
############################
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BAALCHIP_INPUT_DIR="$MODULE_DIR/BaalChIP_input"
BAALCHIP_OUTPUT_DIR="$MODULE_DIR/BaalChIP_output"
SIMUL_OUTPUT_DIR="$MODULE_DIR/simul_output"
LOG_DIR="$MODULE_DIR/logs"
