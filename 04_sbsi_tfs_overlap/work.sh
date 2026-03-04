#!/usr/bin/env bash
# Module 04 entry point: SBSI-TFs overlap aggregation
# This wrapper:
#   1) (optional) symlinks TF BEDs from a source directory using CLUSTER_INFO
#   2) runs multiinter across all BEDs
#   3) filters segments by TF coverage
#   4) merges segments and annotates regions with TF sets

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash work.sh --config <config.sh>

Options:
  --config   Path to config file (default: config/config.sh)
USAGE
}

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$MODULE_DIR/config/config.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -f "$CONFIG" ]] || { echo "ERROR: config not found: $CONFIG" >&2; exit 1; }

# shellcheck disable=SC1090
source "$CONFIG"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Optional symlinking step (environment-specific)
if [[ -n "${CLUSTER_INFO:-}" && -n "${PEAK_BED_SOURCE_DIR:-}" ]]; then
  if [[ -f "$CLUSTER_INFO" ]]; then
    echo "[INFO] Linking BED files from CLUSTER_INFO: $CLUSTER_INFO"
    cut -f 1 "$CLUSTER_INFO" | sed '1d' | while read -r id; do
      [[ -z "$id" ]] && continue
      src="$PEAK_BED_SOURCE_DIR/${id}.bed"
      if [[ -f "$src" ]]; then
        ln -sf "$src" "${id}.bed"
      else
        echo "[WARN] Missing BED: $src" >&2
      fi
    done
  else
    echo "[WARN] CLUSTER_INFO not found: $CLUSTER_INFO" >&2
  fi
fi

# If BED_DIR is set, run multiinter on that directory; otherwise, use current WORK_DIR.
BED_SCAN_DIR="${BED_DIR:-}"
if [[ -z "$BED_SCAN_DIR" ]]; then
  BED_SCAN_DIR="$WORK_DIR"
fi

# Output naming (keep original filenames when OUT_PREFIX is empty)
if [[ -n "${OUT_PREFIX:-}" ]]; then
  OUT_OVERLAP="${OUT_PREFIX}_overlaps_with_sources.bed"
  OUT_FILTERED="${OUT_PREFIX}_${MIN_TF}TF-overlaps_with_sources.bed"
  OUT_FINAL="${OUT_PREFIX}_final_regions_with_tf.bed"
else
  OUT_OVERLAP="overlaps_with_sources.bed"
  OUT_FILTERED="${MIN_TF}TF-overlaps_with_sources.bed"
  OUT_FINAL="final_regions_with_tf.bed"
fi

bash "$MODULE_DIR/scripts/run_overlap_analysis.sh" --bed_dir "$BED_SCAN_DIR" --out "$OUT_OVERLAP"

# Filter by TF support count (column 4)
awk -v min_tf="$MIN_TF" '($4+0) >= min_tf {print $0}' "$OUT_OVERLAP" > "$OUT_FILTERED"
echo "[OK] Wrote: $OUT_FILTERED"

# Merge and annotate TF sets
bash "$MODULE_DIR/scripts/process_regions.sh" --input "$OUT_FILTERED" --out "$OUT_FINAL" --min_len "$MIN_REGION_LEN"

echo "[DONE] Final output: $WORK_DIR/$OUT_FINAL"
