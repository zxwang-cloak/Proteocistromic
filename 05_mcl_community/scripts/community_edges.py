#!/usr/bin/env python3
"""Build community-level edges from a protein-protein interaction table.

Input:
  - membership TSV: community_id<TAB>protein_id
  - PPI (MCL --abc) TSV: protein_A<TAB>protein_B<TAB>weight (weight optional)

Output:
  - community edges TSV: community_A<TAB>community_B
    (self loops are removed)

By default, community pairs are sorted lexicographically per edge, making the
edge list order-independent.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Dict, Tuple


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Generate community edges from PPI + membership.")
    p.add_argument("--membership", required=True, help="Membership TSV (community_id, protein_id).")
    p.add_argument("--ppi", required=True, help="PPI TSV (protein_A, protein_B, [weight]).")
    p.add_argument("--out", required=True, help="Output community edge TSV (community_A, community_B).")
    p.add_argument(
        "--sort_pair",
        action="store_true",
        help="Sort community pairs per edge lexicographically (recommended).",
    )
    p.add_argument(
        "--require_both_mapped",
        action="store_true",
        help="Only keep edges where both proteins have community assignment.",
    )
    return p.parse_args()


def read_membership(path: Path) -> Dict[str, str]:
    prot2com: Dict[str, str] = {}
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            a = line.split("\t")
            if len(a) < 2:
                continue
            com, prot = a[0], a[1]
            # If a protein appears multiple times, keep the first assignment.
            if prot not in prot2com:
                prot2com[prot] = com
    return prot2com


def main() -> None:
    args = parse_args()
    membership_path = Path(args.membership)
    ppi_path = Path(args.ppi)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    prot2com = read_membership(membership_path)

    n_total = 0
    n_kept = 0
    n_skipped_unmapped = 0
    n_skipped_self = 0

    with ppi_path.open("r", encoding="utf-8", errors="ignore") as fin, out_path.open(
        "w", encoding="utf-8"
    ) as fout:
        for line in fin:
            line = line.strip()
            if not line:
                continue
            n_total += 1
            a = line.split("\t")
            if len(a) < 2:
                continue
            p1, p2 = a[0], a[1]

            c1 = prot2com.get(p1)
            c2 = prot2com.get(p2)

            if args.require_both_mapped and (c1 is None or c2 is None):
                n_skipped_unmapped += 1
                continue
            if c1 is None or c2 is None:
                # If not required, still skip because community edges require both endpoints.
                n_skipped_unmapped += 1
                continue

            if c1 == c2:
                n_skipped_self += 1
                continue

            if args.sort_pair and c2 < c1:
                c1, c2 = c2, c1

            fout.write(f"{c1}\t{c2}\n")
            n_kept += 1

    # Minimal summary to stderr would be fine, but keep stdout clean for pipelines.
    # Users can inspect counts by enabling shell 'set -x' in wrappers if needed.


if __name__ == "__main__":
    main()
