#!/usr/bin/env bash
# Run identify_motif.py for every TF listed in the TF map.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash run_identify_motif_batch.sh --config <config.sh> [--start <i>] [--end <j>]
USAGE
}

CONFIG=""
START=1
END=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$CONFIG" ]] || { echo "ERROR: --config is required" >&2; exit 1; }
[[ -f "$CONFIG" ]] || { echo "ERROR: config not found: $CONFIG" >&2; exit 1; }

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1090
source "$CONFIG"

i=0
tail -n +2 "$TF_MAP_TSV" | while IFS=$'\t' read -r tf_name _; do
  [[ -z "${tf_name:-}" ]] && continue
  i=$((i+1))
  if (( i < START )); then
    continue
  fi
  if (( END > 0 && i > END )); then
    break
  fi

  fasta_file="$WORK_DIR/data/${tf_name}.fa"
  [[ -f "$fasta_file" ]] || { echo "[WARN] Missing FASTA for ${tf_name}: $fasta_file" >&2; continue; }

  echo "[${i}] identify_motif: ${tf_name}"
  "$PYTHON_BIN" "$MODULE_DIR/scripts/identify_motif.py"     "$fasta_file"     "$tf_name"     --motif_path "$MOTIF_DIR/"     --cutoff     -d "$IDENTIFY_DISTANCE"     -s "$RESCALED_PEAK_SIZE"     1>>"$LOG_DIR/identify_motif.log"     2>>"$LOG_DIR/identify_motif.err"
done
