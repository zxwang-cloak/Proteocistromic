#!/usr/bin/env bash
# Module 03: TF-pair spacing analysis
#
# Commands:
#   prepare - link FASTA/TSV inputs into the module workspace
#   identify - run motif scanning for all TFs
#   pairs - generate all TF pairs
#   spacing - run pairwise spacing analysis
#
# Comments are in English by design.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash work.sh prepare --config <config.sh> [--force]
  bash work.sh identify --config <config.sh> [--start <i>] [--end <j>]
  bash work.sh pairs --config <config.sh>
  bash work.sh spacing --config <config.sh> --pairs <pairs.tsv> [--start <i>] [--end <j>]
USAGE
}

CMD="${1:-help}"
if [[ $# -gt 0 ]]; then
  shift
fi

CONFIG=""
FORCE=0
START=1
END=0
PAIRS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --force) FORCE=1; shift 1;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    --pairs) PAIRS="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${CONFIG:-$MODULE_DIR/config/config.sh}"

[[ -f "$CONFIG" ]] || { echo "ERROR: config not found: $CONFIG" >&2; exit 1; }

case "$CMD" in
  prepare)
    cmd=(bash "$MODULE_DIR/scripts/prepare_workspace.sh" --config "$CONFIG")
    if (( FORCE == 1 )); then
      cmd+=(--force)
    fi
    "${cmd[@]}"
    ;;
  identify)
    bash "$MODULE_DIR/scripts/run_identify_motif_batch.sh" --config "$CONFIG" --start "$START" --end "$END"
    ;;
  pairs)
    # shellcheck disable=SC1090
    source "$CONFIG"
    mkdir -p "$PAIR_DIR"
    "$PYTHON_BIN" "$MODULE_DIR/scripts/generate_pairs.py" --infile "$TF_MAP_TSV" --column tf_name --out "$PAIR_DIR/pairs.tsv"
    echo "[OK] Wrote: $PAIR_DIR/pairs.tsv"
    ;;
  spacing)
    [[ -n "$PAIRS" ]] || { echo "ERROR: --pairs is required for spacing" >&2; exit 1; }
    bash "$MODULE_DIR/scripts/run_spacing_for_pairs.sh" --config "$CONFIG" --pairs "$PAIRS" --start "$START" --end "$END"
    ;;
  help|"")
    usage
    ;;
  *)
    echo "ERROR: command must be one of: prepare | identify | pairs | spacing" >&2
    usage
    exit 1
    ;;
esac
