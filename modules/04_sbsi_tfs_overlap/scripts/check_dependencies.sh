#!/usr/bin/env bash
# Check required dependencies for Module 04.

set -euo pipefail

missing=0

need_cmd() {
  local c="$1"
  if ! command -v "$c" >/dev/null 2>&1; then
    echo "[MISSING] $c"
    missing=1
  else
    echo "[OK] $c -> $(command -v "$c")"
  fi
}

need_cmd bash
need_cmd awk
need_cmd sort
need_cmd find

if command -v bedtools >/dev/null 2>&1; then
  echo "[OK] bedtools -> $(command -v bedtools)"
else
  echo "[MISSING] bedtools"
  missing=1
fi

if command -v multiIntersectBed >/dev/null 2>&1; then
  echo "[OK] multiIntersectBed -> $(command -v multiIntersectBed)"
else
  echo "[INFO] multiIntersectBed not found; will try 'bedtools multiinter' instead."
fi

if [[ $missing -ne 0 ]]; then
  echo "ERROR: Missing dependencies detected." >&2
  exit 1
fi

echo "All dependencies look OK."
