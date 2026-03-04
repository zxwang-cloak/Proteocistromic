# Software versions by module

The table below summarizes the software versions explicitly mentioned in the manuscript STAR Methods table and mapped to the packaged code modules in this repository.

## Module 01 - ChIP-seq upstream analysis
- FastQC 0.11.9
- TrimGalore 0.6.7
- Bowtie2 2.2.5
- SAMtools 1.9
- Picard 2.25.1
- deepTools 3.5.2
- MACS2 2.1.4
- BEDTools 2.30.0
- HOMER 4.11.1
- MEME-ChIP 5.0.5
- CentriMo 5.0.2
- MultiQC 1.13.dev0

## Module 02 - ASB analysis with BaalChIP
- R 4.0.5
- BaalChIP 1.24.0
- Bowtie2 2.2.5
- SAMtools 1.9
- Picard 2.25.1

## Module 03 - TF-pair spacing analysis
- HOMER 4.11.1 (mergePeaks)
- BEDTools 2.30.0 (when upstream peak processing is required)
- JASPAR motif collection (database resource referenced in STAR Methods)
- Spacing pipeline (TF pairs calling) (manuscript-referenced upstream method)

## Module 04 - SBSI-TFs overlap aggregation
- BEDTools 2.30.0

## Module 05 - MCL-community analysis
- MCL 22-282
- R 4.0.5

See `docs/software_versions_used_in_repo.tsv` for the machine-readable version table and
`docs/software_and_algorithms_star_methods.tsv` for the software table extracted from the STAR Methods workbook.
