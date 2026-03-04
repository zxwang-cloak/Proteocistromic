# Module 05 - MCL-community analysis

This module clusters a protein-protein interaction (PPI) network using **MCL** and tests community-community connectivity enrichment with Fisher's exact test.

## Inputs

- `INPUT_PPI`: a tab-separated file in **MCL `--abc`** format:
  - column 1: `protein_A`
  - column 2: `protein_B`
  - column 3: edge weight (for example PSM)

## Outputs

Outputs are written below `OUTPUT_DIR`:

- `mcl/mcl_out.I*.txt`
- `community/community_membership.tsv`
- `community/noself_community_edges.tsv`
- `community/community_counts.tsv`
- `community/community_pair_counts.tsv`
- `fisher/fisher_input.tsv`
- `fisher/fisher_results.tsv`

## Quick start

```bash
cd modules/05_mcl_community
cp config/config.example.sh config/config.sh
# edit config/config.sh
bash work.sh run --config config/config.sh
```

## Software versions
- MCL 22-282
- R 4.0.5

See `docs/system_requirements.md` and `envs/mcl_community_environment.yml` for details.

## Legacy scripts

Original uploaded Perl and R scripts are preserved under `legacy/`.
