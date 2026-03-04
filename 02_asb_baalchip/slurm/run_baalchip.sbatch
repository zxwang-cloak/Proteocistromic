#!/usr/bin/env bash
#SBATCH --job-name=baalchip
#SBATCH --cpus-per-task=10
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=logs/%x.%j.out
#SBATCH --error=logs/%x.%j.err

set -euo pipefail

if [[ -z "${TREAT_ID:-}" || -z "${INPUT_ID:-}" ]]; then
  echo "ERROR: TREAT_ID and INPUT_ID must be provided via sbatch --export." >&2
  exit 1
fi

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="${CONFIG_FILE:-$MODULE_DIR/config/config.sh}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Config file not found: $CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

bash "$MODULE_DIR/scripts/run_one.sh" --config "$CONFIG_FILE" --input "$INPUT_ID" --treat "$TREAT_ID"
