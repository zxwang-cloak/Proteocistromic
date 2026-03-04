#!/usr/bin/env bash
# Run multi-intersection across BED files using bedtools.
# This script discovers BED files in a directory, filters empty files,
# and runs `bedtools multiinter` (or `multiIntersectBed` if available).

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash run_overlap_analysis.sh --bed_dir <DIR> --out <FILE>

Options:
  --bed_dir   Directory containing *.bed files
  --out       Output file (default: overlaps_with_sources.bed)
USAGE
}

BED_DIR=""
OUT="overlaps_with_sources.bed"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bed_dir) BED_DIR="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$BED_DIR" ]] || { echo "ERROR: --bed_dir is required" >&2; exit 1; }
[[ -d "$BED_DIR" ]] || { echo "ERROR: BED_DIR not found: $BED_DIR" >&2; exit 1; }

# Discover BED files (exclude outputs from previous runs)
mapfile -t bed_files < <(find "$BED_DIR" -maxdepth 1 -type f -name "*.bed" \
  ! -name "*overlaps_with_sources.bed" \
  ! -name "*TF-overlaps_with_sources.bed" \
  ! -name "merged_overlaps_with_sources.bed" \
  ! -name "final_regions_with_tf.bed" \
  | sort)

if [[ ${#bed_files[@]} -eq 0 ]]; then
  echo "ERROR: No BED files found under: $BED_DIR" >&2
  exit 1
fi

# Filter empty files and build name list
files=()
names=()
for f in "${bed_files[@]}"; do
  if [[ -s "$f" ]]; then
    files+=("$f")
    names+=("$(basename "$f" .bed)")
  fi
done

if [[ ${#files[@]} -lt 2 ]]; then
  echo "ERROR: Need at least 2 non-empty BED files to run multiinter." >&2
  exit 1
fi

# Select multiinter executable
if command -v multiIntersectBed >/dev/null 2>&1; then
  MULTI_CMD=(multiIntersectBed)
elif command -v bedtools >/dev/null 2>&1; then
  MULTI_CMD=(bedtools multiinter)
else
  echo "ERROR: bedtools (multiinter) not found in PATH." >&2
  exit 1
fi

# Run
tmp_out="${OUT}.tmp"
"${MULTI_CMD[@]}" -i "${files[@]}" -names "${names[@]}" > "$tmp_out"

# Sanity check
if [[ ! -s "$tmp_out" ]]; then
  echo "ERROR: multiinter produced an empty output: $tmp_out" >&2
  exit 1
fi

mv "$tmp_out" "$OUT"
echo "[OK] Wrote: $OUT"
head -n 5 "$OUT" || true
