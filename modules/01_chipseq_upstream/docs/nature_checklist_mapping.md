# Nature checklist mapping for Module 01

This file maps the current repository structure to the common Nature-style code and software submission checklist.

## Required content

### Compiled standalone software and/or source code
- Source code is included under `scripts/`.
- The original source files are preserved under `legacy/`.

### Small dataset to demo the software/code
- Not included in the source materials used for packaging.
- A helper script is provided in `scripts/make_demo_subset.sh` so a reviewer-ready demo can be generated from existing FASTQ files.
- Before submission, add the actual demo FASTQ subset or a reproducible download script.

## README requirements

### 1. System requirements
Covered in `README.md`:
- software dependencies
- operating system guidance
- reference resources
- tested versions workflow
- hardware note

### 2. Installation guide
Covered in `README.md`:
- environment setup
- configuration file creation
- reference path setup
- dependency check

### 3. Demo
Covered in `README.md` and `demo/README.md`:
- how to generate a small demo subset
- how to run the demo
- expected output structure

### 4. Instructions for use
Covered in `README.md`:
- single-sample execution
- full-table execution
- SLURM submission
- instructions for running on new data

## Additional information

### Software license for use
- A final license has not yet been chosen.
- Replace the top-level `LICENSE` file with an OSI-approved license before public release or submission.

### Open repository link
- Add the real GitHub repository URL to the top-level `CITATION.cff` after upload.

## Items still needing manual completion

1. choose the final license
2. provide a small demo dataset or a download script
3. record exact tested software versions
4. record typical install time and typical demo runtime after benchmarking
5. optionally add figure-level reproducibility notes linked to the manuscript
