#!/usr/bin/env bash
set -euo pipefail

# Collect software version strings for Nature-style software documentation.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/collect_software_versions.sh <CONFIG_FILE> [OUTPUT_TSV]

Example:
  bash scripts/collect_software_versions.sh config/config.sh docs/software_versions.tsv
EOF
}

[[ $# -ge 1 && $# -le 2 ]] || { usage; exit 1; }

CONFIG_FILE="$1"
OUTPUT_TSV="${2:-${SCRIPT_DIR%/scripts}/docs/software_versions.tsv}"

load_config "$CONFIG_FILE"

capture_version() {
    local tool_name="$1"
    local command_string="$2"
    local version_output

    set +e
    version_output="$(bash -lc "$command_string" 2>&1 | head -n 1)"
    local exit_code=$?
    set -e

    if [[ $exit_code -ne 0 || -z "$version_output" ]]; then
        version_output="NOT_AVAILABLE"
    fi

    printf "%s\t%s\n" "$tool_name" "$version_output"
}

ensure_dir "$(dirname "$OUTPUT_TSV")"

{
    printf "tool\tversion\n"
    capture_version "operating_system" "uname -srmo"
    capture_version "fastqc" "fastqc --version"
    capture_version "trim_galore" "trim_galore --version"
    capture_version "bowtie2" "bowtie2 --version"
    capture_version "samtools" "samtools --version"
    capture_version "picard" "java -jar '${PICARD_JAR}' MarkDuplicates --version"
    capture_version "deeptools_bamCoverage" "bamCoverage --version"
    capture_version "macs2" "macs2 --version"
    capture_version "bedtools" "bedtools --version"
    capture_version "homer_annotatePeaks" "annotatePeaks.pl 2>&1"
    capture_version "homer_findMotifsGenome" "findMotifsGenome.pl 2>&1"
    capture_version "meme_chip" "meme-chip -version"
    capture_version "meme2meme" "meme2meme -version"
    capture_version "fimo" "fimo -version"
    capture_version "bedGraphToBigWig" "bedGraphToBigWig 2>&1"
} > "$OUTPUT_TSV"

log "Software versions were written to: ${OUTPUT_TSV}"
