#!/usr/bin/env python3
"""Build Fisher's exact test contingency tables for community pairs.

Inputs:
  1) community_counts.tsv: header + columns [community, count]
     - count is the per-community incident edge count (degree count)
  2) community_pair_counts.tsv: header + columns [C1, C2, Both]
  3) community_edges.tsv: two columns [C1, C2] (used only to get total edge count)

Output:
  fisher_input.tsv with columns:
    C1, C2, Both, Just_community_1, Just_community_2, Neither

Definitions follow the original Perl implementation:
  Just_community_1 = degree(C1) - Both
  Just_community_2 = degree(C2) - Both
  Neither = total_edges - Both - Just_community_1 - Just_community_2
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, Tuple


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Build Fisher contingency table for community pairs.")
    p.add_argument("--community_counts", required=True, help="TSV with columns community,count.")
    p.add_argument("--pair_counts", required=True, help="TSV with columns C1,C2,Both.")
    p.add_argument("--edges", required=True, help="Community edges TSV (two columns).")
    p.add_argument("--out", required=True, help="Output TSV for Fisher input.")
    return p.parse_args()


def read_degree_counts(path: Path) -> Dict[str, int]:
    d: Dict[str, int] = {}
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        header = f.readline()
        for line in f:
            line = line.strip()
            if not line:
                continue
            a = line.split("\t")
            if len(a) < 2:
                continue
            d[a[0]] = int(float(a[1]))
    return d


def count_total_edges(path: Path) -> int:
    n = 0
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            if line.strip():
                n += 1
    return n


def main() -> None:
    args = parse_args()
    deg = read_degree_counts(Path(args.community_counts))
    total_edges = count_total_edges(Path(args.edges))

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    with Path(args.pair_counts).open("r", encoding="utf-8", errors="ignore") as fin, out_path.open(
        "w", encoding="utf-8"
    ) as fout:
        # header
        hdr = fin.readline()
        fout.write("C1\tC2\tBoth\tJust_community_1\tJust_community_2\tNeither\n")

        for line in fin:
            line = line.strip()
            if not line:
                continue
            a = line.split("\t")
            if len(a) < 3:
                continue
            c1, c2, both_s = a[0], a[1], a[2]
            both = int(float(both_s))

            if c1 not in deg or c2 not in deg:
                # Skip pairs if degree count missing.
                continue

            just1 = deg[c1] - both
            just2 = deg[c2] - both
            neither = total_edges - both - just1 - just2

            # Guard against negative due to inconsistent inputs
            if just1 < 0 or just2 < 0 or neither < 0:
                continue

            fout.write(f"{c1}\t{c2}\t{both}\t{just1}\t{just2}\t{neither}\n")


if __name__ == "__main__":
    main()
