# Module 01 - ChIP-seq upstream analysis

The pipeline performs:


1. raw read QC with FastQC
2. adapter and quality trimming with Trim Galore
3. alignment with Bowtie2
4. BAM filtering and duplicate removal with Samtools and Picard
5. CPM-normalized bigWig generation with deepTools
6. peak calling with MACS2
7. peak annotation with HOMER
8. motif analysis with MEME-ChIP, HOMER, and FIMO

All commands below assume you are working inside `modules/01_chipseq_upstream/` unless an explicit full path is shown.


---

## 1. Repository contents

```text
modules/01_chipseq_upstream/
├── README.md
├── config/
│   ├── config.example.sh
│   └── sample_group.tsv
├── demo/
│   └── README.md
├── docs/
│   ├── nature_checklist_mapping.md
│   ├── packaging_notes.md
│   ├── release_checklist.md
│   └── software_versions.tsv
├── envs/
│   └── chipseq_upstream_environment.yml
├── legacy/
│   ├── README.original.txt
│   ├── input-chipseq.original.sh
│   ├── sample_group.original.txt
│   └── treat-chipseq.original.sh
└── scripts/
    ├── check_dependencies.sh
    ├── collect_software_versions.sh
    ├── make_demo_subset.sh
    ├── run_all_from_table.sh
    ├── run_input_chipseq.sh
    ├── run_treat_chipseq.sh
    ├── submit_slurm_from_table.sh
    └── lib/
        └── common.sh
```

---

## 2. System requirements

### Operating system
- Linux is recommended.
- The pipeline was originally written as shell-based command-line workflows for a Linux or HPC environment.
- A SLURM submission helper is included for cluster use.

### Required software
The current workflow expects the following tools to be installed and available in `PATH`:

- FastQC
- Trim Galore
- Bowtie2
- Samtools
- Java
- Picard
- deepTools (`bamCoverage`)
- MACS2
- Bedtools
- HOMER (`annotatePeaks.pl`, `findMotifsGenome.pl`)
- MEME Suite (`meme-chip`, `meme2meme`, `fimo`)
- UCSC `bedGraphToBigWig`

### Reference resources
You also need to prepare:

- Bowtie2 index for the reference genome
- genome FASTA file
- chromosome sizes file
- blacklist BED file
- MEME-format motif database files

### Versions tested
Exact tested versions were not included in the source materials used for this packaging step.

After validating the pipeline on your system, run:

```bash
bash scripts/collect_software_versions.sh config/config.sh docs/software_versions.tsv
```

Then copy the resulting version information into the manuscript software documentation.

### Non-standard hardware
- No non-standard hardware is required.
- For batch processing of many samples, an HPC environment is recommended but not mandatory.

---

## 3. Installation guide

### 3.1 Create the conda environment
A starter environment file is provided:

```bash
conda env create -f envs/chipseq_upstream_environment.yml
conda activate chipseq-upstream
```

### 3.2 Prepare reference resources
Edit a new config file based on the template:

```bash
cp config/config.example.sh config/config.sh
```

Then update the following paths in `config/config.sh`:

- `BOWTIE2_INDEX`
- `GENOME_FASTA`
- `CHROM_SIZES`
- `BLACKLIST_BED`
- `PICARD_JAR`
- `MEME_DB_1`
- `MEME_DB_2`
- `MEME_DB_3`

### 3.3 Check dependencies
```bash
bash scripts/check_dependencies.sh config/config.sh
```

### Typical install time
Because the original package did not include benchmarked installation metadata, the following should be treated as an estimate only:

- software environment creation: approximately 20-60 minutes
- reference and motif resource preparation: highly variable, typically 10-60 minutes depending on local storage and download speed

Replace these estimates with measured values before manuscript submission if the journal requires exact timings.

---

## 4. Input data organization

### Raw FASTQ files
Place gzipped FASTQ files in:

```text
Rawdata/
```

Expected naming scheme:

```text
Rawdata/Input-1.fq.gz
Rawdata/ELF1.fq.gz
Rawdata/BHLHA15.fq.gz
...
```

### Sample pairing table
The file `config/sample_group.tsv` stores the mapping between control samples and treatment samples:

```text
Input_ID    Treat_ID
Input-1     ELF1
Input-2     BHLHA15
...
```

The batch scripts automatically skip the header row.

---

## 5. Demo

A small demo FASTQ subset was not part of the source materials supplied for this packaging step.  
To help you satisfy the journal demo requirement, a helper script is included to generate small demo subsets from your own gzipped FASTQ files.

### Create a small demo subset
```bash
mkdir -p demo/Rawdata
bash scripts/make_demo_subset.sh Rawdata/Input-1.fq.gz demo/Rawdata/Input-1.fq.gz 100000
bash scripts/make_demo_subset.sh Rawdata/ELF1.fq.gz demo/Rawdata/ELF1.fq.gz 100000
```

You can then temporarily set in `config/config.sh`:

```bash
RAW_DIR="./demo/Rawdata"
OUT_DIR="./demo/chipseq_out"
```

### Run the demo
```bash
bash scripts/run_input_chipseq.sh Input-1 config/config.sh
bash scripts/run_treat_chipseq.sh ELF1 Input-1 config/config.sh
```

### Expected demo output
After a successful run, the following directories are generated for each sample:

- `00datafilter/`
- `01cleandata/`
- `02alignment/`
- `03bigwig/`

For treatment samples, the following additional directories are produced:

- `04macs/`
- `05motif/`

### Expected demo runtime
Exact benchmarked runtime values were not included in the supplied source files.  
For a small FASTQ subset, runtime is expected to be substantially shorter than the full dataset run, but you should record the measured value on your own workstation before submission.

---

## 6. Instructions for use

### 6.1 Run a single input sample
```bash
bash scripts/run_input_chipseq.sh Input-1 config/config.sh
```

### 6.2 Run a single treatment sample
```bash
bash scripts/run_treat_chipseq.sh ELF1 Input-1 config/config.sh
```

### 6.3 Run all samples sequentially
```bash
bash scripts/run_all_from_table.sh config/sample_group.tsv config/config.sh
```

### 6.4 Submit all samples to a SLURM cluster
```bash
bash scripts/submit_slurm_from_table.sh config/sample_group.tsv config/config.sh
```

Optional SLURM environment variables:

```bash
export SBATCH_ACCOUNT="your_account"
export SBATCH_PARTITION="your_partition"
export SBATCH_TIME="48:00:00"
export SBATCH_MEM="64G"
export SBATCH_CPUS_PER_TASK="20"
```

### 6.5 Run the workflow on your own data
1. Place your gzipped FASTQ files in `Rawdata/`.
2. Rename files using the `<sample_id>.fq.gz` convention.
3. Edit `config/sample_group.tsv` to define input-treatment pairs.
4. Copy `config/config.example.sh` to `config/config.sh` and update all paths.
5. Run either the single-sample scripts or the batch scripts above.

---

## 7. Output files

### Input sample outputs
For each input sample, the main outputs are:

- raw and trimmed FastQC reports
- trimmed FASTQ
- sorted BAM
- filtered BAM
- duplicate-removed BAM
- alignment statistics
- CPM-normalized bigWig

### Treatment sample outputs
For each treatment sample, the main outputs are:

- all upstream outputs listed above
- MACS2 peaks and signal tracks
- HOMER peak annotations
- top peak FASTA sequences
- MEME-ChIP motif results
- HOMER motif results
- FIMO motif scanning results

---

## 8. Reproducibility notes

To improve reproducibility before journal submission, the following steps are recommended:

1. run `scripts/collect_software_versions.sh`
2. archive exact reference resources and record their versions or download URLs
3. add a small demo dataset or a reproducible data download script
4. record the exact commands used to generate each manuscript figure or table
5. tag a GitHub release and archive it to Zenodo if a DOI is needed

---

## 9. Important packaging notes

This module was refactored from shell scripts provided as source materials.  
The refactoring mainly aimed to make the code:

- easier to upload to GitHub
- less dependent on user-specific absolute paths
- easier for reviewers to run
- easier to extend when additional manuscript modules are added later

See `docs/packaging_notes.md` for details.
