#!/usr/bin/env bash
# Check minimal dependencies for TF-pair spacing analysis.

set -euo pipefail

missing=0

need_cmd() {
  local tool="$1"
  if command -v "$tool" >/dev/null 2>&1; then
    echo "[OK] ${tool} -> $(command -v "$tool")"
  else
    echo "[MISSING] ${tool}" >&2
    missing=1
  fi
}

need_cmd python3
need_cmd mergePeaks

python3 - <<'PY' || missing=1
modules = ["numpy", "pandas", "Bio", "scipy", "matplotlib", "seaborn"]
for name in modules:
    __import__(name)
print("[OK] Required Python modules imported successfully.")
PY

if [[ $missing -ne 0 ]]; then
  echo "ERROR: Missing dependencies detected." >&2
  exit 1
fi
