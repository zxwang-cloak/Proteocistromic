#!/usr/bin/env bash
set -euo pipefail

# Submit all jobs listed in a sample table to a SLURM cluster.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/submit_slurm_from_table.sh <SAMPLE_GROUP_TSV> <CONFIG_FILE>

Optional environment variables:
  SBATCH_ACCOUNT
  SBATCH_PARTITION
  SBATCH_TIME
  SBATCH_MEM
  SBATCH_CPUS_PER_TASK

Example:
  bash scripts/submit_slurm_from_table.sh config/sample_group.tsv config/config.sh
EOF
}

[[ $# -eq 2 ]] || { usage; exit 1; }

SAMPLE_TABLE="$(abs_path "$1")"
CONFIG_FILE="$(abs_path "$2")"

require_file "$SAMPLE_TABLE"
require_file "$CONFIG_FILE"
require_command sbatch

LOG_DIR="${SCRIPT_DIR%/scripts}/logs"
ensure_dir "$LOG_DIR"

SBATCH_CPUS_PER_TASK="${SBATCH_CPUS_PER_TASK:-20}"
SBATCH_TIME="${SBATCH_TIME:-48:00:00}"
SBATCH_MEM="${SBATCH_MEM:-64G}"

SLURM_BASE_ARGS=(
    "--cpus-per-task=${SBATCH_CPUS_PER_TASK}"
    "--time=${SBATCH_TIME}"
    "--mem=${SBATCH_MEM}"
)

if [[ -n "${SBATCH_ACCOUNT:-}" ]]; then
    SLURM_BASE_ARGS+=("--account=${SBATCH_ACCOUNT}")
fi

if [[ -n "${SBATCH_PARTITION:-}" ]]; then
    SLURM_BASE_ARGS+=("--partition=${SBATCH_PARTITION}")
fi

declare -A INPUT_JOB_IDS

log "Submitting input-control jobs to SLURM"
while read -r input_id; do
    job_id="$(sbatch --parsable \
        "${SLURM_BASE_ARGS[@]}" \
        --job-name="chip_in_${input_id}" \
        --output="${LOG_DIR}/chip_in_${input_id}.%j.out" \
        --error="${LOG_DIR}/chip_in_${input_id}.%j.err" \
        --wrap="bash ${SCRIPT_DIR}/run_input_chipseq.sh ${input_id} ${CONFIG_FILE}")"
    INPUT_JOB_IDS["$input_id"]="$job_id"
    log "Submitted input sample ${input_id} as job ${job_id}"
done < <(awk 'NR > 1 && $1 != "" {print $1}' "$SAMPLE_TABLE" | sort -u)

log "Submitting treatment jobs to SLURM"
while IFS=$'\t' read -r input_id treat_id; do
    dependency_job="${INPUT_JOB_IDS[$input_id]:-}"
    sbatch_args=(
        --parsable
        "${SLURM_BASE_ARGS[@]}"
        "--job-name=chip_tr_${treat_id}"
        "--output=${LOG_DIR}/chip_tr_${treat_id}.%j.out"
        "--error=${LOG_DIR}/chip_tr_${treat_id}.%j.err"
    )

    if [[ -n "$dependency_job" ]]; then
        sbatch_args+=("--dependency=afterok:${dependency_job}")
    fi

    job_id="$(sbatch "${sbatch_args[@]}" --wrap="bash ${SCRIPT_DIR}/run_treat_chipseq.sh ${treat_id} ${input_id} ${CONFIG_FILE}")"
    log "Submitted treatment sample ${treat_id} with control ${input_id} as job ${job_id}"
done < <(awk 'NR > 1 && $1 != "" && $2 != "" {print $1 "\t" $2}' "$SAMPLE_TABLE")

log "All SLURM jobs have been submitted"
