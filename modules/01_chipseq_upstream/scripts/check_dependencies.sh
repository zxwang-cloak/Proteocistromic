#!/usr/bin/env bash
set -euo pipefail

# Check whether all required tools and reference files are available.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
    cat <<'EOF'
Usage:
  bash scripts/check_dependencies.sh <CONFIG_FILE>

Example:
  bash scripts/check_dependencies.sh config/config.sh
EOF
}

[[ $# -eq 1 ]] || { usage; exit 1; }

CONFIG_FILE="$1"
load_config "$CONFIG_FILE"

require_vars BOWTIE2_INDEX GENOME_FASTA CHROM_SIZES BLACKLIST_BED PICARD_JAR MEME_DB_1 MEME_DB_2 MEME_DB_3

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
require_file "$GENOME_FASTA"
require_file "$CHROM_SIZES"
require_file "$BLACKLIST_BED"
require_file "$PICARD_JAR"
require_file "$MEME_DB_1"
require_file "$MEME_DB_2"
require_file "$MEME_DB_3"

log "All required commands and reference files were found"
