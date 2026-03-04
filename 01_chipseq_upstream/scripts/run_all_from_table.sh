#!/usr/bin/env bash
set -euo pipefail

# Run all input and treatment samples listed in a sample table, sequentially.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/run_all_from_table.sh <SAMPLE_GROUP_TSV> <CONFIG_FILE>

Example:
  bash scripts/run_all_from_table.sh config/sample_group.tsv config/config.sh
EOF
}

[[ $# -eq 2 ]] || { usage; exit 1; }

SAMPLE_TABLE="$1"
CONFIG_FILE="$2"

require_file "$SAMPLE_TABLE"
require_file "$CONFIG_FILE"

log "Running all unique input samples listed in: ${SAMPLE_TABLE}"
awk 'NR > 1 && $1 != "" {print $1}' "$SAMPLE_TABLE" | sort -u | while read -r input_id; do
    bash "${SCRIPT_DIR}/run_input_chipseq.sh" "$input_id" "$CONFIG_FILE"
done

log "Running all treatment samples listed in: ${SAMPLE_TABLE}"
awk 'NR > 1 && $1 != "" && $2 != "" {print $1 "\t" $2}' "$SAMPLE_TABLE" | while IFS=$'\t' read -r input_id treat_id; do
    bash "${SCRIPT_DIR}/run_treat_chipseq.sh" "$treat_id" "$input_id" "$CONFIG_FILE"
done

log "Completed all samples from table: ${SAMPLE_TABLE}"
