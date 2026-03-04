#!/usr/bin/env bash
# Run BaalChIP ASB analysis for all pairs in sample_group.tsv (local execution).

set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/run_all_from_table.sh [--config <config.sh>] [--start <i>] [--end <j>] [--dry-run]

Arguments:
  --start / --end: 1-based indices AFTER the header row of sample_group.tsv.
USAGE
}

CONFIG=""
START=1
END=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --start) START="$2"; shift 2;;
    --end) END="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift 1;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1"; usage; exit 1;;
  esac
done

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-$MODULE_DIR/config/config.sh}"

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: Config file not found: $CONFIG" >&2
  echo "Hint: copy config/config.example.sh to config/config.sh and edit paths." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

if [[ ! -f "$SAMPLE_GROUP_TSV" ]]; then
  echo "ERROR: sample_group.tsv not found: $SAMPLE_GROUP_TSV" >&2
  exit 1
fi

i=0
# Skip header
while IFS=$'\t' read -r input_id treat_id; do
  [[ -z "${input_id:-}" || -z "${treat_id:-}" ]] && continue
  i=$((i+1))
  if (( i < START )); then
    continue
  fi
  if (( END > 0 && i > END )); then
    break
  fi

  echo "[${i}] Running: treat=${treat_id}, input=${input_id}"

  if (( DRY_RUN == 1 )); then
    continue
  fi

  bash "$MODULE_DIR/scripts/run_one.sh" --config "$CONFIG" --input "$input_id" --treat "$treat_id"
done < <(tail -n +2 "$SAMPLE_GROUP_TSV")
