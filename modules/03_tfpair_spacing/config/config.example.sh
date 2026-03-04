#!/usr/bin/env bash

# Runtime
PYTHON_BIN="python3"

# Input files
TF_MAP_TSV="./config/tf_map.example.tsv"
INPUT_FASTA_DIR="/path/to/tf_fasta"
INPUT_TSV_DIR="/path/to/tf_peak_tables"
MOTIF_DIR="/path/to/jaspar_motifs"

# Workspace
WORK_DIR="./work"
PAIR_DIR="${WORK_DIR}/pairs"
LOG_DIR="./logs"

# identify_motif.py parameters
IDENTIFY_DISTANCE=50
RESCALED_PEAK_SIZE=400
