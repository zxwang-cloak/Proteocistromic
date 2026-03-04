# Original workflow summary

The uploaded TF-pair module used a site-specific batch workflow with the following major steps:

1. Prepare TF FASTA and peak-table files in a shared working directory.
2. Optionally post-process intermediate `*.tsv.mid` files into `*.tsv` peak tables using a local helper script.
3. Build a TF list and run `identify_motif.py` for each TF.
4. Generate all unique TF pairs.
5. Run `characterize_spacing.py` for each pair.
6. Re-run unfinished pairs in multiple batches using ad hoc shell splits and background jobs.

Because the original batch script depended on local paths, interactive editing, and helper utilities that were not fully included in the uploaded bundle, the refactored module replaces that logic with parameterized wrappers under `scripts/` and `work.sh`.
