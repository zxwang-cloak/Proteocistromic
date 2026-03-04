#!/usr/bin/env bash

# General run settings
THREADS=20
RAW_DIR="./Rawdata"
OUT_DIR="./chipseq_out"

# Read-processing settings
TRIM_QUALITY=20
MIN_LENGTH=20
MAPQ_FILTER=30
SAMTOOLS_FILTER_FLAGS=3844
BAMCOVERAGE_BIN_SIZE=10
EFFECTIVE_GENOME_SIZE=2862010578
EXTEND_READS=200

# Peak-calling and motif settings
GENOME_NAME="hg38"
HOMER_GENOME="hg38"
MACS2_GSIZE="hs"
MACS2_PVALUE=0.001
MACS2_LOGLR_PVALUE=0.00001
TOP_N_PEAKS=500
SUMMIT_HALF_WIDTH=100
MEME_NMOTIFS=5
MEME_MINW=6
MEME_MAXW=30
MEME_CCUT=200
HOMER_MOTIF_LENGTHS="8,10,12"

# Reference files
# BOWTIE2_INDEX must be the Bowtie2 index basename, not the FASTA file path.
BOWTIE2_INDEX="/path/to/bowtie2/index/hg38"
GENOME_FASTA="/path/to/reference/hg38.fa"
CHROM_SIZES="/path/to/reference/hg38.chrom.sizes"
BLACKLIST_BED="/path/to/reference/hg38.blacklist.bed"
PICARD_JAR="/path/to/picard.jar"

# Motif databases
MEME_DB_1="/path/to/HOCOMOCOv11_full_HUMAN_mono_meme_format.meme"
MEME_DB_2="/path/to/JASPAR2022_CORE_vertebrates_non-redundant_v2.meme"
MEME_DB_3="/path/to/jolma2013.meme"
