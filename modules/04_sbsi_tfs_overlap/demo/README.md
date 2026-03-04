# Demo data for Module 04

This module can be demonstrated with small BED files. Two tiny example BED files are included below.

Run:

```bash
cd modules/04_sbsi_tfs_overlap
mkdir -p work/demo_beds
cp demo/*.bed work/demo_beds/
cp config/config.example.sh config/config.sh
# edit BED_DIR and WORK_DIR to point to the demo files
bash work.sh --config config/config.sh
```
