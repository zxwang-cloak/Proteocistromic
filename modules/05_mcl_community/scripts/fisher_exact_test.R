#!/usr/bin/env Rscript

# Fisher exact tests for community-community intersections.
# Input: fisher_input.tsv with columns:
#   C1, C2, Both, Just_community_1, Just_community_2, Neither
# Output: fisher_results.tsv with p-values, OR and 95% CI, plus FDR.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  stop("Usage: Rscript fisher_exact_test.R <fisher_input.tsv> <out.tsv>")
}

infile <- args[1]
outfile <- args[2]

df <- read.table(infile, header = TRUE, sep = "\t", quote = "", stringsAsFactors = FALSE)

if (nrow(df) == 0) {
  stop("No rows found in fisher input table.")
}

pvals <- numeric(nrow(df))
OR <- numeric(nrow(df))
OR.lower95 <- numeric(nrow(df))
OR.upper95 <- numeric(nrow(df))

for (i in 1:nrow(df)) {
  # To stay consistent with the original implementation, we preserve the same
  # matrix construction (column-major fill):
  # matrix(c(Both, Just_community_1, Just_community_2, Neither), ncol=2)
  m <- matrix(as.vector(t(df[i, c("Both", "Just_community_1", "Just_community_2", "Neither")])), ncol = 2)
  ft <- fisher.test(m)
  pvals[i] <- ft$p.value
  OR[i] <- unname(ft$estimate[[1]])
  OR.lower95[i] <- ft$conf.int[1]
  OR.upper95[i] <- ft$conf.int[2]
}

fdr <- p.adjust(pvals, method = "fdr")

out <- df
out$p.value <- pvals
out$OR <- OR
out$OR.lower95 <- OR.lower95
out$OR.upper95 <- OR.upper95
out$FDR <- fdr

write.table(out, file = outfile, sep = "\t", quote = FALSE, row.names = FALSE)
