#!/usr/bin/env bash
set -euo pipefail

# Run upstream processing for a single ChIP-seq treatment sample.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/run_treat_chipseq.sh <TREAT_ID> <INPUT_ID> <CONFIG_FILE>

Example:
  bash scripts/run_treat_chipseq.sh ELF1 Input-1 config/config.sh
EOF
}

[[ $# -eq 3 ]] || { usage; exit 1; }

TREAT_ID="$1"
INPUT_ID="$2"
CONFIG_FILE="$3"

load_config "$CONFIG_FILE"
require_vars \
    THREADS RAW_DIR OUT_DIR TRIM_QUALITY MIN_LENGTH MAPQ_FILTER SAMTOOLS_FILTER_FLAGS \
    BAMCOVERAGE_BIN_SIZE EFFECTIVE_GENOME_SIZE EXTEND_READS GENOME_NAME HOMER_GENOME \
    MACS2_GSIZE MACS2_PVALUE MACS2_LOGLR_PVALUE TOP_N_PEAKS SUMMIT_HALF_WIDTH \
    MEME_NMOTIFS MEME_MINW MEME_MAXW MEME_CCUT HOMER_MOTIF_LENGTHS \
    BOWTIE2_INDEX GENOME_FASTA CHROM_SIZES BLACKLIST_BED PICARD_JAR \
    MEME_DB_1 MEME_DB_2 MEME_DB_3

require_command fastqc
require_command trim_galore
require_command bowtie2
require_command samtools
require_command java
require_command bamCoverage
require_command macs2
require_command bedtools
require_command annotatePeaks.pl
require_command findMotifsGenome.pl
require_command meme-chip
require_command meme2meme
require_command fimo
require_command bedGraphToBigWig

check_bowtie2_index "$BOWTIE2_INDEX"
require_dir "$RAW_DIR"
require_file "${RAW_DIR}/${TREAT_ID}.fq.gz"
require_file "$PICARD_JAR"
require_file "$GENOME_FASTA"
require_file "$CHROM_SIZES"
require_file "$BLACKLIST_BED"
require_file "$MEME_DB_1"
require_file "$MEME_DB_2"
require_file "$MEME_DB_3"
require_file "${OUT_DIR}/${INPUT_ID}/02alignment/${INPUT_ID}.df.bam"

SAMPLE_OUT="${OUT_DIR}/${TREAT_ID}"
QC_DIR="${SAMPLE_OUT}/00datafilter"
CLEAN_DIR="${SAMPLE_OUT}/01cleandata"
ALIGN_DIR="${SAMPLE_OUT}/02alignment"
BIGWIG_DIR="${SAMPLE_OUT}/03bigwig"
MACS_DIR="${SAMPLE_OUT}/04macs"
MOTIF_DIR="${SAMPLE_OUT}/05motif"

ensure_dir "$QC_DIR"
ensure_dir "$CLEAN_DIR"
ensure_dir "$ALIGN_DIR"
ensure_dir "$BIGWIG_DIR"
ensure_dir "$MACS_DIR"
ensure_dir "$MOTIF_DIR"

RAW_FASTQ="${RAW_DIR}/${TREAT_ID}.fq.gz"
TRIMMED_FASTQ="${CLEAN_DIR}/${TREAT_ID}_trimmed.fq.gz"
SORTED_BAM="${ALIGN_DIR}/${TREAT_ID}.sort.bam"
FILTERED_BAM="${ALIGN_DIR}/${TREAT_ID}.af.bam"
DEDUP_BAM="${ALIGN_DIR}/${TREAT_ID}.df.bam"
INPUT_BAM="${OUT_DIR}/${INPUT_ID}/02alignment/${INPUT_ID}.df.bam"

log "Starting FastQC for raw reads: ${TREAT_ID}"
fastqc --threads "$THREADS" -f fastq -o "$QC_DIR" "$RAW_FASTQ"

log "Starting adapter trimming: ${TREAT_ID}"
trim_galore -q "$TRIM_QUALITY" -o "$CLEAN_DIR" --length "$MIN_LENGTH" --gzip "$RAW_FASTQ"

log "Starting FastQC for trimmed reads: ${TREAT_ID}"
fastqc --threads "$THREADS" -f fastq -o "$CLEAN_DIR" "$TRIMMED_FASTQ"

log "Starting alignment: ${TREAT_ID}"
bowtie2 -p "$THREADS" \
    -x "$BOWTIE2_INDEX" \
    -U "$TRIMMED_FASTQ" \
    2> "${ALIGN_DIR}/${TREAT_ID}.bowtie2.summary.txt" \
    | samtools sort -@ "$THREADS" -o "$SORTED_BAM" -

log "Indexing sorted BAM: ${TREAT_ID}"
samtools index -@ "$THREADS" "$SORTED_BAM"

log "Filtering BAM by MAPQ and SAM flags: ${TREAT_ID}"
samtools view -@ "$THREADS" -q "$MAPQ_FILTER" -F "$SAMTOOLS_FILTER_FLAGS" -bo "$FILTERED_BAM" "$SORTED_BAM"
samtools index -@ "$THREADS" "$FILTERED_BAM"
samtools flagstat "$FILTERED_BAM" > "${ALIGN_DIR}/${TREAT_ID}.af.flagstat.txt"

log "Removing duplicates with Picard: ${TREAT_ID}"
java -jar "$PICARD_JAR" MarkDuplicates \
    I="$FILTERED_BAM" \
    O="$DEDUP_BAM" \
    METRICS_FILE="${ALIGN_DIR}/${TREAT_ID}.df.picard.metrics.txt" \
    REMOVE_DUPLICATES=true

samtools index -@ "$THREADS" "$DEDUP_BAM"
samtools flagstat "$DEDUP_BAM" > "${ALIGN_DIR}/${TREAT_ID}.df.flagstat.txt"

log "Generating bigWig track: ${TREAT_ID}"
bamCoverage \
    --bam "$DEDUP_BAM" \
    -o "${BIGWIG_DIR}/${TREAT_ID}.bw" \
    -bs "$BAMCOVERAGE_BIN_SIZE" \
    --normalizeUsing CPM \
    --effectiveGenomeSize "$EFFECTIVE_GENOME_SIZE" \
    --extendReads "$EXTEND_READS"

log "Calling peaks with MACS2: ${TREAT_ID}"
macs2 callpeak \
    -t "$DEDUP_BAM" \
    -c "$INPUT_BAM" \
    -f BAM \
    --gsize "$MACS2_GSIZE" \
    -n "$TREAT_ID" \
    -p "$MACS2_PVALUE" \
    -B \
    --outdir "$MACS_DIR"

log "Generating FE and logLR signal tracks: ${TREAT_ID}"
macs2 bdgcmp \
    -t "${MACS_DIR}/${TREAT_ID}_treat_pileup.bdg" \
    -c "${MACS_DIR}/${TREAT_ID}_control_lambda.bdg" \
    -o "${MACS_DIR}/${TREAT_ID}_FE.bdg" \
    -m FE

macs2 bdgcmp \
    -t "${MACS_DIR}/${TREAT_ID}_treat_pileup.bdg" \
    -c "${MACS_DIR}/${TREAT_ID}_control_lambda.bdg" \
    -o "${MACS_DIR}/${TREAT_ID}_logLR.bdg" \
    -m logLR \
    -p "$MACS2_LOGLR_PVALUE"

sort -k1,1 -k2,2n "${MACS_DIR}/${TREAT_ID}_FE.bdg" > "${MACS_DIR}/${TREAT_ID}_FE.sorted.bdg"
sort -k1,1 -k2,2n "${MACS_DIR}/${TREAT_ID}_logLR.bdg" > "${MACS_DIR}/${TREAT_ID}_logLR.sorted.bdg"

bedGraphToBigWig "${MACS_DIR}/${TREAT_ID}_FE.sorted.bdg" "$CHROM_SIZES" "${MACS_DIR}/${TREAT_ID}_FE.bw"
bedGraphToBigWig "${MACS_DIR}/${TREAT_ID}_logLR.sorted.bdg" "$CHROM_SIZES" "${MACS_DIR}/${TREAT_ID}_logLR.bw"

log "Annotating peaks with HOMER: ${TREAT_ID}"
annotatePeaks.pl "${MACS_DIR}/${TREAT_ID}_peaks.narrowPeak" "$HOMER_GENOME" > "${MACS_DIR}/${TREAT_ID}_peaks.narrowPeak.annotations.txt"

log "Preparing top peaks for motif analysis: ${TREAT_ID}"
awk -v WIDTH="$SUMMIT_HALF_WIDTH" 'BEGIN {OFS="\t"} {start=$2-WIDTH; if (start < 0) start=0; end=$2+WIDTH; print $1, start, end, $4, $5}' \
    "${MACS_DIR}/${TREAT_ID}_summits.bed" > "${MACS_DIR}/${TREAT_ID}_summits_extended_peaks.bed"

bedtools subtract \
    -a "${MACS_DIR}/${TREAT_ID}_summits_extended_peaks.bed" \
    -b "$BLACKLIST_BED" \
    -f 0.25 \
    -A > "${MACS_DIR}/${TREAT_ID}_extended_bk_removal_peaks.bed"

sort -k5,5nr "${MACS_DIR}/${TREAT_ID}_extended_bk_removal_peaks.bed" | head -n "$TOP_N_PEAKS" > "${MACS_DIR}/${TREAT_ID}_top_peaks.bed"

bedtools getfasta \
    -bed "${MACS_DIR}/${TREAT_ID}_top_peaks.bed" \
    -fi "$GENOME_FASTA" \
    -fo "${MOTIF_DIR}/${TREAT_ID}_top_peaks.fa"

log "Running MEME-ChIP: ${TREAT_ID}"
meme-chip \
    -meme-nmotifs "$MEME_NMOTIFS" \
    -oc "${MOTIF_DIR}/${TREAT_ID}" \
    -ccut "$MEME_CCUT" \
    -dna \
    -meme-minw "$MEME_MINW" \
    -meme-maxw "$MEME_MAXW" \
    -db "$MEME_DB_1" \
    -db "$MEME_DB_2" \
    -db "$MEME_DB_3" \
    "${MOTIF_DIR}/${TREAT_ID}_top_peaks.fa"

log "Running HOMER motif analysis: ${TREAT_ID}"
findMotifsGenome.pl \
    "${MACS_DIR}/${TREAT_ID}_peaks.narrowPeak" \
    "$HOMER_GENOME" \
    "${MACS_DIR}/${TREAT_ID}_homer-motif" \
    -len "$HOMER_MOTIF_LENGTHS"

log "Running FIMO: ${TREAT_ID}"
meme2meme -numbers "${MOTIF_DIR}/${TREAT_ID}/meme_out/meme.txt" > "${MOTIF_DIR}/${TREAT_ID}/PWM.meme"
sed -i 's/ MEME/_MEME/g' "${MOTIF_DIR}/${TREAT_ID}/PWM.meme"
fimo --text "${MOTIF_DIR}/${TREAT_ID}/PWM.meme" "${MOTIF_DIR}/${TREAT_ID}_top_peaks.fa" > "${MOTIF_DIR}/${TREAT_ID}/${TREAT_ID}-fimo.txt"

log "Completed treatment sample: ${TREAT_ID}"
