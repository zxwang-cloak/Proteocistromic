setwd("/home/u41546/ZixianWang/Project/ChIP-seq/293T/FOR_PUBLICATION/ASB")

library(BaalChIP)

samplesheet <- file.path("./BaalChIP_input/TFID-samplesheet.tsv")
hets <- c("TFID"="/home/u41546/ZixianWang/ref/hg38/new-adj-BaalChIP-variant.txt")
gDNA <- list("TFID"= c("../ExactName_bam/INPUT.df.bam"))

res <- BaalChIP(samplesheet=samplesheet, hets=hets, CorrectWithgDNA=gDNA)

## Obtaining allele-specific counts for BAM files
res <- alleleCounts(res, min_base_quality=10, min_mapq=15, verbose=FALSE)

## QCfilter: A filter to exclude SNPs in regions of known problematic read alignment
blacklist_hg38 <- read.table("/home/u41546/ZixianWang/ref/hg38/chipseq/BaalChIP_blacklist_hg38", header = T, sep = "\t")
G_blacklist_hg38 <- GRanges(seqnames = blacklist_hg38$chr,ranges = IRanges(start = blacklist_hg38$start, end = blacklist_hg38$end),strand = blacklist_hg38$strand)

highcoverage_hg38 <- read.table("/home/u41546/ZixianWang/ref/hg38/chipseq/pickrell2011cov1_hg38.bed", header = T, sep = "\t")
G_highcoverage_hg38 <- GRanges(seqnames = highcoverage_hg38$chr, ranges = IRanges(start = highcoverage_hg38$start, end = highcoverage_hg38$end), strand = highcoverage_hg38$strand)

## run QC filter
res <- QCfilter(res, 
                RegionsToFilter=list("blacklist"=G_blacklist_hg38, "highcoverage"=G_highcoverage_hg38),
                verbose=FALSE)

## filterIntbias: A simulation-based filtering to exclude SNPs with intrinsic bias
res <- filterIntbias(res, 
                     simul_output="simul_output", 
                     simulation_script = "local",
                     alignmentSimulArgs=c("/home/u41546/software/picard-tools-1.119",
                                          "/home/u41546/software/bowtie-1.3.1-linux-x86_64",
                                          "/home/u41546/ZixianWang/ref/hg38/chipseq/hg38.fa",
                                          "/home/u41546/ZixianWang/ref/hg38/chrFiles"),
                     verbose=FALSE)

## Merge allele counts per group
res <- mergePerGroup(res)

## Removing possible homozygous SNPs
res <- filter1allele(res)

## Identifying allele-specific binding events
res <- getASB(res, Iter=5000, conf_level=0.95, cores = 10, 
              RMcorrection = TRUE, 
              RAFcorrection= TRUE)

## Exporting the results
result <- BaalChIP.report(res)
write.table(result, file = "./BaalChIP_output/TFID-BaalChIP-results.txt", sep = "\t", quote = F)

## QC summary
summaryQC <- summaryQC(res)[["filtering_stats"]]
write.table(summaryQC, file = "./BaalChIP_output/TFID-summaryQC.txt", sep = "\t", quote = F)


