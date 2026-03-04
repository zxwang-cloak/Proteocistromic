#!/usr/bin/env bash
set -euo pipefail

# Run upstream processing for a single input control sample.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/run_input_chipseq.sh <INPUT_ID> <CONFIG_FILE>

Example:
  bash scripts/run_input_chipseq.sh Input-1 config/config.sh
EOF
}

[[ $# -eq 2 ]] || { usage; exit 1; }

INPUT_ID="$1"
CONFIG_FILE="$2"

load_config "$CONFIG_FILE"
require_vars \
    THREADS RAW_DIR OUT_DIR TRIM_QUALITY MIN_LENGTH MAPQ_FILTER SAMTOOLS_FILTER_FLAGS \
    BAMCOVERAGE_BIN_SIZE EFFECTIVE_GENOME_SIZE EXTEND_READS BOWTIE2_INDEX PICARD_JAR

require_command fastqc
require_command trim_galore
require_command bowtie2
require_command samtools
require_command java
require_command bamCoverage

check_bowtie2_index "$BOWTIE2_INDEX"
require_dir "$RAW_DIR"
require_file "${RAW_DIR}/${INPUT_ID}.fq.gz"
require_file "$PICARD_JAR"

SAMPLE_OUT="${OUT_DIR}/${INPUT_ID}"
QC_DIR="${SAMPLE_OUT}/00datafilter"
CLEAN_DIR="${SAMPLE_OUT}/01cleandata"
ALIGN_DIR="${SAMPLE_OUT}/02alignment"
BIGWIG_DIR="${SAMPLE_OUT}/03bigwig"

ensure_dir "$QC_DIR"
ensure_dir "$CLEAN_DIR"
ensure_dir "$ALIGN_DIR"
ensure_dir "$BIGWIG_DIR"

RAW_FASTQ="${RAW_DIR}/${INPUT_ID}.fq.gz"
TRIMMED_FASTQ="${CLEAN_DIR}/${INPUT_ID}_trimmed.fq.gz"
SORTED_BAM="${ALIGN_DIR}/${INPUT_ID}.sort.bam"
FILTERED_BAM="${ALIGN_DIR}/${INPUT_ID}.af.bam"
DEDUP_BAM="${ALIGN_DIR}/${INPUT_ID}.df.bam"

log "Starting FastQC for raw reads: ${INPUT_ID}"
fastqc --threads "$THREADS" -f fastq -o "$QC_DIR" "$RAW_FASTQ"

log "Starting adapter trimming: ${INPUT_ID}"
trim_galore -q "$TRIM_QUALITY" -o "$CLEAN_DIR" --length "$MIN_LENGTH" --gzip "$RAW_FASTQ"

log "Starting FastQC for trimmed reads: ${INPUT_ID}"
fastqc --threads "$THREADS" -f fastq -o "$CLEAN_DIR" "$TRIMMED_FASTQ"

log "Starting alignment: ${INPUT_ID}"
bowtie2 -p "$THREADS" \
    -x "$BOWTIE2_INDEX" \
    -U "$TRIMMED_FASTQ" \
    2> "${ALIGN_DIR}/${INPUT_ID}.bowtie2.summary.txt" \
    | samtools sort -@ "$THREADS" -o "$SORTED_BAM" -

log "Indexing sorted BAM: ${INPUT_ID}"
samtools index -@ "$THREADS" "$SORTED_BAM"

log "Filtering BAM by MAPQ and SAM flags: ${INPUT_ID}"
samtools view -@ "$THREADS" -q "$MAPQ_FILTER" -F "$SAMTOOLS_FILTER_FLAGS" -bo "$FILTERED_BAM" "$SORTED_BAM"
samtools index -@ "$THREADS" "$FILTERED_BAM"
samtools flagstat "$FILTERED_BAM" > "${ALIGN_DIR}/${INPUT_ID}.af.flagstat.txt"

log "Removing duplicates with Picard: ${INPUT_ID}"
java -jar "$PICARD_JAR" MarkDuplicates \
    I="$FILTERED_BAM" \
    O="$DEDUP_BAM" \
    METRICS_FILE="${ALIGN_DIR}/${INPUT_ID}.df.picard.metrics.txt" \
    REMOVE_DUPLICATES=true

samtools index -@ "$THREADS" "$DEDUP_BAM"
samtools flagstat "$DEDUP_BAM" > "${ALIGN_DIR}/${INPUT_ID}.df.flagstat.txt"

log "Generating bigWig track: ${INPUT_ID}"
bamCoverage \
    --bam "$DEDUP_BAM" \
    -o "${BIGWIG_DIR}/${INPUT_ID}.bw" \
    -bs "$BAMCOVERAGE_BIN_SIZE" \
    --normalizeUsing CPM \
    --effectiveGenomeSize "$EFFECTIVE_GENOME_SIZE" \
    --extendReads "$EXTEND_READS"

log "Completed input sample: ${INPUT_ID}"
