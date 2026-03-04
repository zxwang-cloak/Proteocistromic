# Module 02 — Allele-specific binding (ASB) analysis using BaalChIP

This module packages the ASB pipeline based on **BaalChIP** for reproducible execution and sharing (e.g., Nature Research code availability requirements).

## What the original `work.sh` did (for reference)

The original workflow had two key parts:

1. **Prepare per-TF BaalChIP samplesheets** by replacing the `treat` placeholder in `samplesheet.tsv`, using Treat IDs from `sample_group.txt`.
2. **Submit BaalChIP jobs to SLURM** by generating per-TF sbatch scripts from a template (`BaalChIP.sh`), replacing placeholders `treat` and `input`.

See `legacy/work.original.sh` for the exact original commands. This repo replaces them with parameterized scripts.

## Inputs

- `config/sample_group.tsv`: mapping between `Input_ID` and `Treat_ID` (one TF ChIP sample uses one INPUT control).
- TF BAMs (deduplicated): `${TREAT_BAM_DIR}/${Treat_ID}${TREAT_BAM_SUFFIX}`
- TF peaks (MACS2 narrowPeak): `${TREAT_PEAK_DIR}/${Treat_ID}${PEAK_SUFFIX}`
- INPUT BAMs (deduplicated): `${INPUT_BAM_DIR}/${Input_ID}${INPUT_BAM_SUFFIX}`
- Heterozygous variant list for BaalChIP: `${HETS_FILE}`
- Region filters:
  - `${BAALCHIP_BLACKLIST_TSV}`
  - `${BAALCHIP_HIGHCOVERAGE_TSV}`

## Quick start

1) Copy config and edit paths:

```bash
cd modules/02_asb_baalchip
cp config/config.example.sh config/config.sh
# edit config/config.sh with your real paths
```

2) Run a single TF locally:

```bash
bash scripts/run_one.sh --input Input-8 --treat ALX4
```

3) Run all TFs locally (optional range selection):

```bash
bash scripts/run_all_from_table.sh
# or run a subset (1-based index after header)
bash scripts/run_all_from_table.sh --start 1 --end 20
```

4) Submit to SLURM (recommended for large batches):

```bash
bash scripts/submit_slurm_from_table.sh
# or submit a subset
bash scripts/submit_slurm_from_table.sh --start 1 --end 50
```

## Outputs

For each `Treat_ID`, the pipeline writes:

- `BaalChIP_output/<Treat_ID>-BaalChIP-results.tsv`
- `BaalChIP_output/<Treat_ID>-summaryQC.tsv`

Intermediate simulation files (intrinsic-bias filtering) are written to:

- `simul_output/<Treat_ID>/...`

## Notes

- The intrinsic-bias step (`filterIntbias`) requires external tools (Picard, Bowtie) and reference resources; ensure these are available in your environment.
- The default parameters follow the original script: `min_base_quality=10`, `min_mapq=15`, `Iter=5000`, `conf_level=0.95`, `cores=10`.
