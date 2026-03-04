All commands below assume your current working directory is `modules/01_chipseq_upstream/`.

# Demo instructions

The original materials used to package this module did not include a small reviewer-ready demo dataset.

To satisfy the journal demo requirement, generate a small FASTQ subset from your own gzipped FASTQ files:

```bash
mkdir -p demo/Rawdata
bash scripts/make_demo_subset.sh Rawdata/Input-1.fq.gz demo/Rawdata/Input-1.fq.gz 100000
bash scripts/make_demo_subset.sh Rawdata/ELF1.fq.gz demo/Rawdata/ELF1.fq.gz 100000
```

Then set in `config/config.sh`:

```bash
RAW_DIR="./demo/Rawdata"
OUT_DIR="./demo/chipseq_out"
```

Finally run:

```bash
bash scripts/run_input_chipseq.sh Input-1 config/config.sh
bash scripts/run_treat_chipseq.sh ELF1 Input-1 config/config.sh
```

Recommended demo contents:
- 1 input control FASTQ subset
- 1 treatment FASTQ subset
- updated config file with demo paths
- a short note reporting the measured runtime on a standard workstation
