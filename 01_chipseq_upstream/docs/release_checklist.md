# Release checklist before journal submission

## Must complete
- [ ] Replace the top-level `LICENSE` file with the final OSI-approved license.
- [ ] Fill in `CITATION.cff` with the real author list, title, and GitHub URL.
- [ ] Copy `config/config.example.sh` to `config/config.sh` and validate all paths.
- [ ] Run `bash scripts/check_dependencies.sh config/config.sh`.
- [ ] Run `bash scripts/collect_software_versions.sh config/config.sh docs/software_versions.tsv`.
- [ ] Add a small demo dataset or a reproducible download script.
- [ ] Benchmark and record typical install time.
- [ ] Benchmark and record demo runtime on a standard workstation.
- [ ] Confirm all commands work from a clean clone of the repository.
- [ ] Tag a release in GitHub.

## Recommended
- [ ] Add figure-level or result-level reproducibility notes.
- [ ] Archive the release to Zenodo if a DOI is needed.
- [ ] Ask a colleague unfamiliar with the project to run the demo and report issues.
