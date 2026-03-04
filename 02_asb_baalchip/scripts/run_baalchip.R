#!/usr/bin/env Rscript
# BaalChIP-based allele-specific binding (ASB) pipeline.
#
# This script is a parameterized version of the original batch-BaalChIP.R.txt.
# It reads paths from environment variables defined in config/config.sh and
# runs BaalChIP for one Treat_ID + Input_ID pair.

suppressPackageStartupMessages({
  library(BaalChIP)
  library(GenomicRanges)
  library(IRanges)
})

parse_args <- function(args) {
  # Simple CLI parser without extra dependencies
  out <- list()
  i <- 1
  while (i <= length(args)) {
    key <- args[[i]]
    if (key %in% c("--treat", "--input")) {
      if (i == length(args)) stop(paste0("Missing value for ", key))
      out[[sub("^--", "", key)]] <- args[[i + 1]]
      i <- i + 2
    } else if (key %in% c("-h", "--help")) {
      cat("Usage: Rscript run_baalchip.R --treat <Treat_ID> --input <Input_ID>\n")
      quit(save = "no", status = 0)
    } else {
      stop(paste0("Unknown argument: ", key))
    }
  }
  out
}

get_env <- function(name, required = TRUE, default = "") {
  val <- Sys.getenv(name, unset = default)
  if (required && (is.na(val) || val == "")) {
    stop(paste0("Missing required environment variable: ", name))
  }
  val
}

args <- parse_args(commandArgs(trailingOnly = TRUE))
treat_id <- args$treat
input_id <- args$input

if (is.null(treat_id) || is.null(input_id) || treat_id == "" || input_id == "") {
  stop("Both --treat and --input must be provided.")
}

# Read config from environment variables (set by config/config.sh)
treat_bam_dir <- get_env("TREAT_BAM_DIR")
treat_bam_suffix <- get_env("TREAT_BAM_SUFFIX")
treat_peak_dir <- get_env("TREAT_PEAK_DIR")
peak_suffix <- get_env("PEAK_SUFFIX")
input_bam_dir <- get_env("INPUT_BAM_DIR")
input_bam_suffix <- get_env("INPUT_BAM_SUFFIX")

hets_file <- get_env("HETS_FILE")
blacklist_tsv <- get_env("BAALCHIP_BLACKLIST_TSV")
highcov_tsv <- get_env("BAALCHIP_HIGHCOVERAGE_TSV")

picard_path <- get_env("PICARD_PATH")
bowtie_bin <- get_env("BOWTIE_BIN")
ref_fasta <- get_env("REFERENCE_FASTA")
chr_files_dir <- get_env("CHR_FILES_DIR")

min_base_quality <- as.integer(get_env("MIN_BASE_QUALITY", required = FALSE, default = "10"))
min_mapq <- as.integer(get_env("MIN_MAPQ", required = FALSE, default = "15"))
asb_iter <- as.integer(get_env("ASB_ITER", required = FALSE, default = "5000"))
asb_conf <- as.numeric(get_env("ASB_CONF_LEVEL", required = FALSE, default = "0.95"))
cores <- as.integer(get_env("CORES", required = FALSE, default = "10"))

baalchip_input_dir <- get_env("BAALCHIP_INPUT_DIR")
baalchip_output_dir <- get_env("BAALCHIP_OUTPUT_DIR")
simul_output_dir <- get_env("SIMUL_OUTPUT_DIR")

dir.create(baalchip_input_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(baalchip_output_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(simul_output_dir, showWarnings = FALSE, recursive = TRUE)

# Build per-TF samplesheet (2 rows by default, mirroring the original template)
treat_bam <- file.path(treat_bam_dir, paste0(treat_id, treat_bam_suffix))
treat_peak <- file.path(treat_peak_dir, paste0(treat_id, peak_suffix))

samplesheet_path <- file.path(baalchip_input_dir, paste0(treat_id, "-samplesheet.tsv"))

ss <- data.frame(
  group_name = treat_id,
  target = treat_id,
  replicate_number = c(1, 2),
  bam_name = c(treat_bam, treat_bam),
  bed_name = c(treat_peak, treat_peak),
  stringsAsFactors = FALSE
)

write.table(ss, file = samplesheet_path, sep = "\t", quote = FALSE, row.names = FALSE)

# Build hets + gDNA inputs (named by group)
hets <- setNames(hets_file, treat_id)
input_bam <- file.path(input_bam_dir, paste0(input_id, input_bam_suffix))
gDNA <- setNames(list(c(input_bam)), treat_id)

# Basic file checks
required_paths <- c(samplesheet_path, hets_file, treat_bam, treat_peak, input_bam, blacklist_tsv, highcov_tsv, ref_fasta)
missing <- required_paths[!file.exists(required_paths)]
if (length(missing) > 0) {
  stop(paste0("Missing required file(s):\n", paste(missing, collapse = "\n")))
}

# Initialize BaalChIP
res <- BaalChIP(samplesheet = samplesheet_path, hets = hets, CorrectWithgDNA = gDNA)

# Obtain allele-specific counts
res <- alleleCounts(res, min_base_quality = min_base_quality, min_mapq = min_mapq, verbose = FALSE)

# QCfilter: exclude SNPs in problematic regions
blacklist <- read.table(blacklist_tsv, header = TRUE, sep = "\t")
G_blacklist <- GRanges(
  seqnames = blacklist$chr,
  ranges = IRanges(start = blacklist$start, end = blacklist$end),
  strand = blacklist$strand
)

highcov <- read.table(highcov_tsv, header = TRUE, sep = "\t")
G_highcov <- GRanges(
  seqnames = highcov$chr,
  ranges = IRanges(start = highcov$start, end = highcov$end),
  strand = highcov$strand
)

res <- QCfilter(res, RegionsToFilter = list(blacklist = G_blacklist, highcoverage = G_highcov), verbose = FALSE)

# filterIntbias: simulation-based filtering to exclude intrinsic bias SNPs
# Use per-TF subdirectory to avoid collisions when running multiple TFs in parallel.
simul_dir_treat <- file.path(simul_output_dir, treat_id)
dir.create(simul_dir_treat, showWarnings = FALSE, recursive = TRUE)

res <- filterIntbias(
  res,
  simul_output = simul_dir_treat,
  simulation_script = "local",
  alignmentSimulArgs = c(picard_path, bowtie_bin, ref_fasta, chr_files_dir),
  verbose = FALSE
)

# Merge allele counts per group and filter homozygous SNPs
res <- mergePerGroup(res)
res <- filter1allele(res)

# Identify ASB events
res <- getASB(
  res,
  Iter = asb_iter,
  conf_level = asb_conf,
  cores = cores,
  RMcorrection = TRUE,
  RAFcorrection = TRUE
)

# Export results
result <- BaalChIP.report(res)
out_results <- file.path(baalchip_output_dir, paste0(treat_id, "-BaalChIP-results.tsv"))
write.table(result, file = out_results, sep = "\t", quote = FALSE, row.names = FALSE)

# QC summary
qc <- summaryQC(res)[["filtering_stats"]]
out_qc <- file.path(baalchip_output_dir, paste0(treat_id, "-summaryQC.tsv"))
write.table(qc, file = out_qc, sep = "\t", quote = FALSE, row.names = FALSE)

message("Done: ", treat_id)
message("Results: ", out_results)
message("QC: ", out_qc)
