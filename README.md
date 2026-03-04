## Packaged modules

- `modules/01_chipseq_upstream` - ChIP-seq upstream processing from raw FASTQ to QC, alignment, peak calling, annotation, and motif analysis
- `modules/02_asb_baalchip` - Allele-specific binding analysis with BaalChIP
- `modules/03_tfpair_spacing` - TF-pair motif spacing analysis
- `modules/04_sbsi_tfs_overlap` - SBSI-TFs multi-BED overlap aggregation
- `modules/05_mcl_community` - MCL-based community detection and Fisher enrichment analysis

## Software versions

Versions taken from the manuscript STAR Methods workbook are summarized in:

- `docs/software_and_algorithms_star_methods.tsv`
- `docs/software_versions_used_in_repo.tsv`
- `docs/software_versions_by_module.md`

Where a module also needs a runtime not explicitly versioned in STAR Methods (for example Python itself), the requirement is documented in that module's `envs/` and `docs/` directory.

## Pseudocode and workflow descriptions

High-level pseudocode for all packaged modules is documented in:

- `docs/pipeline_overview.md`

Module-specific workflow details are documented in each module README.

## General quick start

```bash
git clone https://github.com/<YOUR_ACCOUNT>/<REPO_NAME>.git
cd <REPO_NAME>

# choose one module
cd modules/01_chipseq_upstream
cp config/config.example.sh config/config.sh
# edit config/config.sh

# create the conda environment when an env file is provided
conda env create -f envs/chipseq_upstream_environment.yml
conda activate chipseq-upstream

# run dependency checks, then execute the module
bash scripts/check_dependencies.sh config/config.sh
```

Each module provides its own execution entry point (`work.sh` or documented scripts), expected inputs, and output layout.

## Repository layout

```text
nature-code-repository/
├── README.md
├── LICENSE
├── CITATION.cff
├── docs/
│   ├── pipeline_overview.md
│   ├── repository_release_checklist.md
│   ├── software_and_algorithms_star_methods.tsv
│   ├── software_versions_by_module.md
│   └── software_versions_used_in_repo.tsv
└── modules/
    ├── 01_chipseq_upstream/
    ├── 02_asb_baalchip/
    ├── 03_tfpair_spacing/
    ├── 04_sbsi_tfs_overlap/
    └── 05_mcl_community/
```

## Notes for public release

- The code comments in the refactored scripts are written in English.
- Site-specific absolute paths from the original scripts were replaced by module-level configuration files.
- Original author-provided scripts are retained under `legacy/` whenever they were available in the uploaded materials.
- Replace the placeholder GitHub URL, repository title, and author list before public release.
