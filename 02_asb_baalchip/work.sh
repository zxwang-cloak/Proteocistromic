#!/usr/bin/env bash
# Convenience wrapper for Module 02.
#
# This is a simplified replacement for the original legacy/work.original.sh:
# - No pre-generation of samplesheets is required (handled per TF at runtime).
# - No per-TF sbatch script generation is required.
# - Supports running a subset via --start/--end.

set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash work.sh [local|slurm] [--start <i>] [--end <j>] [--config <config.sh>] [--clean]

Examples:
  bash work.sh local
  bash work.sh slurm --start 1 --end 50
  bash work.sh slurm --clean

Notes:
  Indices are 1-based AFTER the header row of sample_group.tsv.
USAGE
}

MODE="local"
CONFIG=""
START=1
END=0
CLEAN=0

if [[ $# -gt 0 && "$1" != "--" && "$1" != -* ]]; then
  MODE="$1"
  shift 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    --clean) CLEAN=1; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1"; usage; exit 1;;
  esac
done

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${CONFIG:-$MODULE_DIR/config/config.sh}"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: Config file not found: $CONFIG" >&2
  echo "Hint: copy config/config.example.sh to config/config.sh and edit paths." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

mkdir -p "$BAALCHIP_INPUT_DIR" "$BAALCHIP_OUTPUT_DIR" "$SIMUL_OUTPUT_DIR" "$LOG_DIR"

if (( CLEAN == 1 )); then
  echo "Cleaning simulation outputs under: $SIMUL_OUTPUT_DIR"
  rm -rf "$SIMUL_OUTPUT_DIR"/*
fi

case "$MODE" in
  local)
    bash "$MODULE_DIR/scripts/run_all_from_table.sh" --config "$CONFIG" --start "$START" --end "$END"
    ;;
  slurm)
    bash "$MODULE_DIR/scripts/submit_slurm_from_table.sh" --config "$CONFIG" --start "$START" --end "$END"
    ;;
  *)
    echo "ERROR: MODE must be one of: local | slurm" >&2
    usage
    exit 1
    ;;
esac
