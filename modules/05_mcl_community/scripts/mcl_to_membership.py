#!/usr/bin/env python3
"""Convert MCL clustering output to a community membership table.

Input:
  MCL output file where each line is a cluster (whitespace-delimited node IDs).

Output:
  A two-column TSV: community_id<TAB>protein_id

This script can (optionally) filter clusters by minimum size and re-index community IDs.

Author: (fill in)
"""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Convert MCL output clusters to a community membership TSV."
    )
    p.add_argument("--mcl_out", required=True, help="MCL output file (clusters per line).")
    p.add_argument("--out", required=True, help="Output membership TSV (community_id, protein_id).")
    p.add_argument("--sizes_out", default=None, help="Optional output TSV of community sizes.")
    p.add_argument("--prefix", default="community", help="Community ID prefix. Default: community")
    p.add_argument("--min_size", type=int, default=1, help="Minimum cluster size to keep. Default: 1")
    p.add_argument(
        "--reindex",
        action="store_true",
        help="Re-index communities to make IDs contiguous after filtering.",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()

    in_path = Path(args.mcl_out)
    if not in_path.exists():
        raise FileNotFoundError(f"MCL output not found: {in_path}")

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)

    sizes_records = []
    community_counter = 0

    with in_path.open("r", encoding="utf-8", errors="ignore") as fin, out_path.open(
        "w", encoding="utf-8"
    ) as fout:
        for line_idx, line in enumerate(fin, start=1):
            line = line.strip()
            if not line:
                continue
            # MCL output is typically tab-delimited, but we accept any whitespace.
            nodes = [x for x in line.split() if x]
            if len(nodes) < args.min_size:
                continue

            if args.reindex:
                community_counter += 1
                com_id = f"{args.prefix}{community_counter}"
            else:
                # Keep original ordering index (line number) as community index.
                com_id = f"{args.prefix}{line_idx}"

            sizes_records.append((com_id, len(nodes)))

            for n in nodes:
                fout.write(f"{com_id}\t{n}\n")

    if args.sizes_out:
        sizes_path = Path(args.sizes_out)
        sizes_path.parent.mkdir(parents=True, exist_ok=True)
        with sizes_path.open("w", encoding="utf-8") as fsz:
            fsz.write("community\tsize\n")
            for com_id, size in sizes_records:
                fsz.write(f"{com_id}\t{size}\n")


if __name__ == "__main__":
    main()
