# Module 04 — SBSI-TFs overlap aggregation

This module aggregates multi-TF ChIP-seq peak overlaps across many TF BED files and produces merged genomic regions annotated with the TF set supporting each region.

## What this module does

1. **Multi-intersection** across all TF BED files (`bedtools multiinter` / `multiIntersectBed`)
2. **Filter** overlap segments by TF coverage (e.g., keep segments supported by ≥10 TFs)
3. **Merge** adjacent/overlapping segments and **collapse & de-duplicate** TF labels
4. **Filter** merged regions by length (default ≥55 bp)

## Inputs

- A directory containing TF peak BED files: `*.bed` (recommended: sorted by `chrom`, `start`)
- *(Optional)* `cluster.info` (first column contains TF/cluster IDs) plus a source BED directory for auto-symlinking

## Outputs

All outputs are written under `WORK_DIR` (default: `./work`):

- `overlaps_with_sources.bed` — output from `bedtools multiinter` (segments + supporting TF list)
- `<MIN_TF>TF-overlaps_with_sources.bed` — filtered segments (≥MIN_TF TFs)
- `final_regions_with_tf.bed` — merged regions annotated with unique TF list (4th column)
- Intermediate files may also be created for debugging (see `scripts/`).

## Dependencies

- bash
- bedtools (multiinter + merge)
- awk (gawk recommended for stable TF ordering)
- coreutils (sort, find)

## Quick start

```bash
cd modules/04_sbsi_tfs_overlap

# 1) Create your config
cp config/config.example.sh config/config.sh
# edit config/config.sh (BED_DIR, WORK_DIR, etc.)

# 2) Run the pipeline
bash work.sh --config config/config.sh
```

## Notes

- `bedtools merge` expects **sorted** BED. The provided scripts will sort the intermediate BED before merging.
- If your TF BED files are unsorted, consider sorting each BED once (recommended) before running multiinter.

