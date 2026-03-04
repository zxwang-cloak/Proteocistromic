#!/usr/bin/env bash
# Collect software versions for Module 04.

set -euo pipefail

echo "Date: $(date -Is)"
echo "OS: $(uname -a)"
echo

echo "bash: $(bash --version | head -n 1)"
echo "awk: $(awk --version 2>/dev/null | head -n 1 || echo 'awk (no --version support)')"
echo "sort: $(sort --version 2>/dev/null | head -n 1 || echo 'sort (no --version support)')"
echo "find: $(find --version 2>/dev/null | head -n 1 || echo 'find (no --version support)')"

if command -v bedtools >/dev/null 2>&1; then
  echo "bedtools: $(bedtools --version 2>/dev/null || echo 'bedtools (version unavailable)')"
else
  echo "bedtools: NOT FOUND"
fi

if command -v multiIntersectBed >/dev/null 2>&1; then
  echo "multiIntersectBed: $(multiIntersectBed --version 2>/dev/null || echo 'multiIntersectBed (version unavailable)')"
fi
