# Module 03 - TF-pair spacing analysis

This module packages the TF-pair spacing workflow into a parameterized, GitHub-ready structure.

## What the refactored module does

1. Prepare a clean workspace of TF FASTA and peak tables.
2. Run motif scanning for each TF with `identify_motif.py`.
3. Generate all unique TF pairs.
4. Run spacing analysis for each pair with `characterize_spacing.py`.
5. Re-use existing outputs automatically when the spacing statistics file already exists.

## Inputs

- `config/tf_map.tsv` - one header column named `tf_name`
- `INPUT_FASTA_DIR/<TF>.fa`
- `INPUT_TSV_DIR/<TF>.tsv`
- `MOTIF_DIR/*.jaspar` motif files

## Quick start

```bash
cd modules/03_tfpair_spacing
cp config/config.example.sh config/config.sh
cp config/tf_map.example.tsv config/tf_map.tsv
# edit config/config.sh

bash scripts/check_dependencies.sh
bash work.sh prepare --config config/config.sh
bash work.sh identify --config config/config.sh
bash work.sh pairs --config config/config.sh
bash work.sh spacing --config config/config.sh --pairs work/pairs/pairs.tsv
```

## Outputs

Outputs are written below `WORK_DIR/data/` by the original spacing scripts:

- `*_cutoff.tsv` - motif-annotated peak tables
- `merged_files/merged_<TF1>_<TF2>_filtered.tsv`
- `spacing_files/<TF1>_<TF2>_spacing.json`
- `spacing_files/<TF1>_<TF2>_spacing_stats.tsv`
- `spacing_files/<TF1>_<TF2>_spacingDistribution.pdf`

## Notes

- The original workflow included additional site-specific helper scripts and ad hoc rerun logic. Those materials are documented under `legacy/`.
- The included `simul_random_null.json` is a synthetic placeholder for packaging and demo purposes. Replace it if you need the manuscript-specific null reference.
