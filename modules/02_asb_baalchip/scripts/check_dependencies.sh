#!/usr/bin/env bash
# Minimal dependency checks for Module 02.

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${1:-$MODULE_DIR/config/config.sh}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

echo "== Checking required files =="

req_files=(
  "$HETS_FILE"
  "$BAALCHIP_BLACKLIST_TSV"
  "$BAALCHIP_HIGHCOVERAGE_TSV"
  "$REFERENCE_FASTA"
)

for f in "${req_files[@]}"; do
  if [[ ! -e "$f" ]]; then
    echo "MISSING: $f" >&2
  else
    echo "OK: $f"
  fi
done

echo
echo "== Checking external tools =="

tools=(Rscript "$BOWTIE_BIN")
for t in "${tools[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "OK: $t ($(command -v "$t"))"
  elif [[ -x "$t" ]]; then
    echo "OK: $t"
  else
    echo "MISSING: $t" >&2
  fi
done

echo
echo "Note: Picard is passed to BaalChIP as a path; ensure it is valid: $PICARD_PATH"
