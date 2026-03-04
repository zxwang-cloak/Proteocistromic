#!/usr/bin/env python3
"""Generate all unique TF pairs from a one-column or two-column TF map table."""

from __future__ import annotations

import argparse
import csv
from itertools import combinations
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate all unique TF pairs.")
    parser.add_argument("--infile", required=True, help="Input TSV with a header.")
    parser.add_argument("--column", default="tf_name", help="Column name containing TF identifiers.")
    parser.add_argument("--out", required=True, help="Output TSV without header: tf1<TAB>tf2.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    infile = Path(args.infile)
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)

    names: list[str] = []
    with infile.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter="\t")
        if args.column not in reader.fieldnames:
            raise SystemExit(f"Column not found: {args.column}")
        for row in reader:
            value = (row.get(args.column) or "").strip()
            if value:
                names.append(value)

    names = sorted(dict.fromkeys(names))
    with out.open("w", encoding="utf-8", newline="") as handle:
        for a, b in combinations(names, 2):
            handle.write(f"{a}\t{b}\n")


if __name__ == "__main__":
    main()
