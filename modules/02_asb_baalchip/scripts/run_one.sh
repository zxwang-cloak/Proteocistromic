#!/usr/bin/env bash
# Run BaalChIP ASB analysis for one Treat_ID + Input_ID pair.

set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  bash scripts/run_one.sh --input <Input_ID> --treat <Treat_ID> [--config <config.sh>]

Notes:
  - By default, config is loaded from: config/config.sh
USAGE
}

CONFIG=""
INPUT_ID=""
TREAT_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --input) INPUT_ID="$2"; shift 2;;
    --treat) TREAT_ID="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1"; usage; exit 1;;
  esac
done

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${CONFIG:-$MODULE_DIR/config/config.sh}"

if [[ -z "$INPUT_ID" || -z "$TREAT_ID" ]]; then
  echo "ERROR: --input and --treat are required." >&2
  usage
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: Config file not found: $CONFIG" >&2
  echo "Hint: copy config/config.example.sh to config/config.sh and edit paths." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

mkdir -p "$BAALCHIP_INPUT_DIR" "$BAALCHIP_OUTPUT_DIR" "$SIMUL_OUTPUT_DIR" "$LOG_DIR"

Rscript "$MODULE_DIR/scripts/run_baalchip.R" \
  --treat "$TREAT_ID" \
  --input "$INPUT_ID"
