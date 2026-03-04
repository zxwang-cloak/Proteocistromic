#!/usr/bin/env bash
# Run characterize_spacing.py for TF pairs.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash run_spacing_for_pairs.sh --config <config.sh> --pairs <pairs.tsv> [--start <i>] [--end <j>]
USAGE
}

CONFIG=""
PAIRS=""
START=1
END=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --pairs) PAIRS="$2"; shift 2;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$CONFIG" ]] || { echo "ERROR: --config is required" >&2; exit 1; }
[[ -f "$CONFIG" ]] || { echo "ERROR: config not found: $CONFIG" >&2; exit 1; }
[[ -n "$PAIRS" ]] || { echo "ERROR: --pairs is required" >&2; exit 1; }
[[ -f "$PAIRS" ]] || { echo "ERROR: pairs file not found: $PAIRS" >&2; exit 1; }

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$CONFIG"

i=0
while IFS=$'\t' read -r tf1 tf2; do
  [[ -z "${tf1:-}" || -z "${tf2:-}" ]] && continue
  i=$((i+1))
  if (( i < START )); then
    continue
  fi
  if (( END > 0 && i > END )); then
    break
  fi

  stats_file="$WORK_DIR/data/spacing_files/${tf1}_${tf2}_spacing_stats.tsv"
  if [[ -f "$stats_file" ]]; then
    echo "[${i}] Skip existing pair: ${tf1} ${tf2}"
    continue
  fi

  echo "[${i}] characterize_spacing: ${tf1} ${tf2}"
  "$PYTHON_BIN" "$MODULE_DIR/scripts/characterize_spacing.py"     "$WORK_DIR/data/"     "$tf1"     "$tf2"     --motif_path "$MOTIF_DIR/"     1>>"$LOG_DIR/characterize_spacing.log"     2>>"$LOG_DIR/characterize_spacing.err"
done < "$PAIRS"
