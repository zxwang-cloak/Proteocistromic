#!/usr/bin/env bash
set -euo pipefail

# Create a small gzipped FASTQ subset for demo or reviewer testing.

usage() {
    cat <<'EOF'
Usage:
  bash scripts/make_demo_subset.sh <INPUT_FASTQ_GZ> <OUTPUT_FASTQ_GZ> [READ_COUNT]

Example:
  bash scripts/make_demo_subset.sh Rawdata/Input-1.fq.gz demo/Rawdata/Input-1.fq.gz 100000
EOF
}

[[ $# -ge 2 && $# -le 3 ]] || { usage; exit 1; }

INPUT_FASTQ_GZ="$1"
OUTPUT_FASTQ_GZ="$2"
READ_COUNT="${3:-100000}"

[[ -f "$INPUT_FASTQ_GZ" ]] || { echo "[ERROR] Input file not found: $INPUT_FASTQ_GZ" >&2; exit 1; }
mkdir -p "$(dirname "$OUTPUT_FASTQ_GZ")"

LINE_COUNT=$((READ_COUNT * 4))

zcat "$INPUT_FASTQ_GZ" | head -n "$LINE_COUNT" | gzip -c > "$OUTPUT_FASTQ_GZ"

echo "[INFO] Demo subset created: $OUTPUT_FASTQ_GZ"
echo "[INFO] Read count requested: $READ_COUNT"
