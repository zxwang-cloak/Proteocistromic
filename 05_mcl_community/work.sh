#!/usr/bin/env bash
# Module 05: MCL-community analysis (clean pipeline)
#
# This script clusters a PPI network with MCL, derives community membership,
# builds community-level edges, and runs Fisher's exact test for community pairs.
#
# Comments are in English by design.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash work.sh run   [--config config/config.sh]
  bash work.sh help

Notes:
  - INPUT_PPI must be in MCL --abc format: proteinA<TAB>proteinB<TAB>weight
  - The pipeline outputs intermediate files under OUTPUT_DIR.
USAGE
}

CMD="${1:-help}"
shift || true

CONFIG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${CONFIG:-$MODULE_DIR/config/config.sh}"

if [[ "$CMD" == "help" ]]; then
  usage
  exit 0
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: config not found: $CONFIG" >&2
  echo "Hint: copy config/config.example.sh to config/config.sh and edit it." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG"

# ---- Basic checks ----
command -v "$MCL_BIN" >/dev/null 2>&1 || { echo "ERROR: mcl not found: $MCL_BIN" >&2; exit 1; }
command -v "$RSCRIPT_BIN" >/dev/null 2>&1 || { echo "ERROR: Rscript not found: $RSCRIPT_BIN" >&2; exit 1; }
command -v "$PYTHON_BIN" >/dev/null 2>&1 || { echo "ERROR: python not found: $PYTHON_BIN" >&2; exit 1; }

[[ -f "$INPUT_PPI" ]] || { echo "ERROR: INPUT_PPI not found: $INPUT_PPI" >&2; exit 1; }

OUTDIR="$OUTPUT_DIR"
MCLDIR="$OUTDIR/mcl"
COMDIR="$OUTDIR/community"
FISHDIR="$OUTDIR/fisher"

mkdir -p "$MCLDIR" "$COMDIR" "$FISHDIR"

# ---- Step 1: Run MCL ----
mcl_out="$MCLDIR/mcl_out.I${MCL_INFLATION}.txt"
echo "[1/6] Running MCL (inflation=${MCL_INFLATION}) ..."
"$MCL_BIN" "$INPUT_PPI" --abc -I "$MCL_INFLATION" -o "$mcl_out"

# ---- Step 2: Convert to community membership ----
membership_tsv="$COMDIR/community_membership.tsv"
community_sizes_tsv="$COMDIR/community_sizes.tsv"
echo "[2/6] Converting MCL output to membership table ..."
"$PYTHON_BIN" "$MODULE_DIR/scripts/mcl_to_membership.py"   --mcl_out "$mcl_out"   --out "$membership_tsv"   --sizes_out "$community_sizes_tsv"   --prefix "$COMMUNITY_PREFIX"   --min_size "$MIN_COMMUNITY_SIZE"   --reindex

# ---- Step 3: Build community-level edges (remove self loops) ----
community_edges="$COMDIR/noself_community_edges.tsv"
echo "[3/6] Building community-level edges ..."
"$PYTHON_BIN" "$MODULE_DIR/scripts/community_edges.py"   --membership "$membership_tsv"   --ppi "$INPUT_PPI"   --out "$community_edges"   --sort_pair   --require_both_mapped

# ---- Step 4: Community degree counts ----
community_counts="$COMDIR/community_counts.tsv"
echo "[4/6] Computing community degree counts ..."
"$PYTHON_BIN" "$MODULE_DIR/scripts/community_degree_counts.py"   --edges "$community_edges"   --out "$community_counts"

# ---- Step 5: Community pair counts ----
pair_counts="$COMDIR/community_pair_counts.tsv"
echo "[5/6] Computing community pair counts ..."
"$PYTHON_BIN" "$MODULE_DIR/scripts/community_pair_counts.py"   --edges "$community_edges"   --out "$pair_counts"

# ---- Step 6: Fisher exact tests ----
fisher_input="$FISHDIR/fisher_input.tsv"
fisher_results="$FISHDIR/fisher_results.tsv"
echo "[6/6] Building Fisher table and running Fisher exact tests ..."
"$PYTHON_BIN" "$MODULE_DIR/scripts/build_fisher_table.py"   --community_counts "$community_counts"   --pair_counts "$pair_counts"   --edges "$community_edges"   --out "$fisher_input"

"$RSCRIPT_BIN" "$MODULE_DIR/scripts/fisher_exact_test.R" "$fisher_input" "$fisher_results"

echo "[OK] Done."
echo "  - Membership:      $membership_tsv"
echo "  - Community edges: $community_edges"
echo "  - Fisher results:  $fisher_results"
