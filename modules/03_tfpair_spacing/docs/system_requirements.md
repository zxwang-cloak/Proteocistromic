# System requirements (Module 03)

## Core dependencies
- Python 3.8+
- Biopython 1.77 (chosen for compatibility with the original script API)
- NumPy
- pandas
- SciPy
- matplotlib
- seaborn
- HOMER 4.11.1 (`mergePeaks`)
- BEDTools 2.30.0 when upstream peak preprocessing is needed

## Input assumptions
- One TF FASTA file per TF: `<TF>.fa`
- One peak table per TF: `<TF>.tsv`
- JASPAR-format motif files under `MOTIF_DIR`

## Notes
- The original workflow referenced additional site-specific helper scripts and motif resources. Those steps are documented in `legacy/original_workflow_summary.md`.
- A synthetic `simul_random_null.json` is included only to make the refactored module self-contained for packaging and demo purposes. Replace it with the manuscript-specific null reference if one was used in production.
