#!/usr/bin/env python3
"""Count the number of edges between each pair of communities.

Input:
  community_edges.tsv: community_A<TAB>community_B

Output:
  community_pair_counts.tsv: community_1<TAB>community_2<TAB>both

Notes:
  - Pairs are treated as undirected: (A,B) is the same as (B,A).
  - community_1 < community_2 lexicographically in the output.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from collections import Counter
from typing import Tuple


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Count community-community edge frequencies.")
    p.add_argument("--edges", required=True, help="Community edge TSV (community_A, community_B).")
    p.add_argument("--out", required=True, help="Output TSV (community_1, community_2, both).")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    edges_path = Path(args.edges)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    cnt = Counter()

    with edges_path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            a = line.split("\t")
            if len(a) < 2:
                continue
            c1, c2 = a[0], a[1]
            if c1 == c2:
                continue
            if c2 < c1:
                c1, c2 = c2, c1
            cnt[(c1, c2)] += 1

    records = sorted(cnt.items(), key=lambda x: (-x[1], x[0][0], x[0][1]))

    with out_path.open("w", encoding="utf-8") as out:
        out.write("C1\tC2\tBoth\n")
        for (c1, c2), n in records:
            out.write(f"{c1}\t{c2}\t{n}\n")


if __name__ == "__main__":
    main()
