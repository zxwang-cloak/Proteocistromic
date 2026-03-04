#!/usr/bin/env bash
# Submit BaalChIP ASB analysis jobs to SLURM for all pairs in sample_group.tsv.

set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/submit_slurm_from_table.sh [--config <config.sh>] [--start <i>] [--end <j>] [--dry-run]

Arguments:
  --start / --end: 1-based indices AFTER the header row of sample_group.tsv.
  --dry-run: print sbatch commands without submitting.
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

mkdir -p "$LOG_DIR"

i=0
while IFS=$'\t' read -r input_id treat_id; do
  [[ -z "${input_id:-}" || -z "${treat_id:-}" ]] && continue
  i=$((i+1))
  if (( i < START )); then
    continue
  fi
  if (( END > 0 && i > END )); then
    break
  fi

  export_cmd="ALL,CONFIG_FILE=$CONFIG,INPUT_ID=$input_id,TREAT_ID=$treat_id"
  cmd=(sbatch --export="$export_cmd" "$MODULE_DIR/slurm/run_baalchip.sbatch")

  echo "[${i}] ${cmd[*]}"

  if (( DRY_RUN == 1 )); then
    continue
  fi

  "${cmd[@]}"
done < <(tail -n +2 "$SAMPLE_GROUP_TSV")
