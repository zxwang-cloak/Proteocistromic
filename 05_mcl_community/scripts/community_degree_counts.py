#!/usr/bin/env python3
"""Compute per-community connection counts (degree counts) from community edge list.

Input:
  community_edges.tsv: community_A<TAB>community_B

Output:
  community_counts.tsv: community<TAB>count

Count definition matches the original grep-based approach:
each edge contributes +1 to both endpoints (community_A and community_B).
"""

from __future__ import annotations

import argparse
from pathlib import Path
from collections import Counter


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Compute community degree counts from edge list.")
    p.add_argument("--edges", required=True, help="Community edge TSV (community_A, community_B).")
    p.add_argument("--out", required=True, help="Output TSV (community, count).")
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
            cnt[c1] += 1
            cnt[c2] += 1

    # Sort by count desc, then community id
    records = sorted(cnt.items(), key=lambda x: (-x[1], x[0]))

    with out_path.open("w", encoding="utf-8") as out:
        out.write("community\tcount\n")
        for com, n in records:
            out.write(f"{com}\t{n}\n")


if __name__ == "__main__":
    main()
