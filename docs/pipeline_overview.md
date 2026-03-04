# Pipeline overview and pseudocode

This file provides a compact workflow description for the packaged analysis modules.
It can be cited in the code availability statement and used to complete the Nature software checklist item asking where pseudocode or detailed functionality is documented.

## Module 01 - ChIP-seq upstream analysis
**Input:** raw FASTQ files, reference genome, Bowtie2 index, blacklist BED, chromosome sizes, sample-group table

**Pseudocode**
1. For each input-control FASTQ, run FastQC.
2. Trim adapters and low-quality bases with TrimGalore.
3. Re-run FastQC on trimmed reads.
4. Align trimmed reads with Bowtie2 and sort BAM with SAMtools.
5. Filter reads by mapping quality and flags, remove duplicates with Picard.
6. Generate normalized bigWig tracks with deepTools.
7. For each treatment FASTQ, repeat steps 1-6, then call peaks with MACS2 against the matched input.
8. Annotate peaks and run motif analysis with HOMER and MEME-ChIP.

## Module 02 - ASB analysis with BaalChIP
**Input:** treatment BAMs, input BAMs, peak calls, heterozygous SNP list, blacklist/high-coverage filters

**Pseudocode**
1. Build a per-TF BaalChIP sample sheet from the sample-group table.
2. Initialize BaalChIP using the sample sheet and heterozygous SNP list.
3. Count allele-specific reads in treatment BAMs.
4. Remove SNPs in blacklisted or high-coverage regions.
5. Correct intrinsic bias using gDNA/input BAMs and reference resources.
6. Merge per-group results and estimate allele-specific binding.
7. Write ASB statistics and QC summaries.

## Module 03 - TF-pair spacing analysis
**Input:** TF-centered FASTA files, corresponding peak tables, JASPAR-format motif files, TF list

**Pseudocode**
1. Prepare a workspace containing one FASTA and one peak table per TF.
2. Scan each TF FASTA with the matching motif PWM using `identify_motif.py`.
3. Generate all unique TF pairs.
4. For each TF pair, merge paired peak sets with HOMER `mergePeaks`.
5. Restrict to co-bound peaks passing the original filtering rules.
6. Compute orientation-specific motif spacing distributions.
7. Compare spacing distributions to the null reference and write summary tables and plots.

## Module 04 - SBSI-TFs overlap aggregation
**Input:** multiple TF peak BED files

**Pseudocode**
1. Optionally create a clean workspace of symbolic links to BED files.
2. Run `bedtools multiinter` (or `multiIntersectBed`) across all BEDs.
3. Keep overlap segments supported by at least `MIN_TF` datasets.
4. Merge adjacent/overlapping segments with `bedtools merge`.
5. Collapse TF labels and remove duplicates.
6. Filter merged regions by minimum length.

## Module 05 - MCL-community analysis
**Input:** weighted protein-protein interaction table in MCL `--abc` format

**Pseudocode**
1. Cluster the interaction graph with MCL.
2. Convert clusters to a community-membership table.
3. Map protein-level edges to community-level edges.
4. Remove self loops.
5. Count per-community degree and per-community-pair edge counts.
6. Build Fisher exact test contingency tables.
7. Run Fisher exact tests in R and adjust p-values by FDR.
