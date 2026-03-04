# Demo data for Module 03

This directory contains a minimal example layout for TF-pair spacing analysis.

## Included demo materials
- `data/GATA1.fa`
- `data/GATA1.tsv`
- `data/TAL1.fa`
- `data/TAL1.tsv`
- `motifs/GATA1.jaspar`
- `motifs/TAL1.jaspar`
- `tf_map.tsv`

## Notes
- The demo is intentionally tiny and mainly documents the expected file structure.
- Full spacing analysis still requires HOMER `mergePeaks`.
- The synthetic null reference bundled under `scripts/simul_random_null.json` is sufficient for packaging tests but should be replaced by the manuscript-specific null if available.
