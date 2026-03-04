#!/usr/bin/env bash
# Prepare a clean workspace for TF-pair spacing analysis by linking input FASTA and TSV files.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash prepare_workspace.sh --config <config.sh> [--force]
USAGE
}

CONFIG=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --force) FORCE=1; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$CONFIG" ]] || { echo "ERROR: --config is required" >&2; exit 1; }
[[ -f "$CONFIG" ]] || { echo "ERROR: config not found: $CONFIG" >&2; exit 1; }

# shellcheck disable=SC1090
source "$CONFIG"

mkdir -p "$WORK_DIR/data" "$PAIR_DIR" "$LOG_DIR"

if (( FORCE == 1 )); then
  find "$WORK_DIR/data" -maxdepth 1 -type l -delete
fi

tail -n +2 "$TF_MAP_TSV" | while IFS=$'\t' read -r tf_name _; do
  [[ -z "${tf_name:-}" ]] && continue
  fasta_src="${INPUT_FASTA_DIR}/${tf_name}.fa"
  tsv_src="${INPUT_TSV_DIR}/${tf_name}.tsv"

  [[ -f "$fasta_src" ]] || { echo "[WARN] Missing FASTA: $fasta_src" >&2; continue; }
  [[ -f "$tsv_src" ]] || { echo "[WARN] Missing peak table: $tsv_src" >&2; continue; }

  ln -sfn "$fasta_src" "$WORK_DIR/data/${tf_name}.fa"
  ln -sfn "$tsv_src" "$WORK_DIR/data/${tf_name}.tsv"
done

echo "[OK] Workspace prepared under $WORK_DIR/data"
