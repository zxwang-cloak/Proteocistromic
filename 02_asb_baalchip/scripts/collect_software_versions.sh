#!/usr/bin/env bash
# Collect basic software versions for reporting.

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${1:-$MODULE_DIR/config/config.sh}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

out="$MODULE_DIR/docs/software_versions.tsv"
mkdir -p "$(dirname "$out")"

{
  echo -e "tool\tversion"
  echo -e "R\t$(Rscript --version 2>&1 | head -n1)"
  echo -e "bowtie\t$($BOWTIE_BIN --version 2>&1 | head -n1 || true)"
  echo -e "picard\t$PICARD_PATH"
} > "$out"

echo "Wrote: $out"
