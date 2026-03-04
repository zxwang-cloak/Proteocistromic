#!/usr/bin/env bash
# Merge overlap segments and annotate merged regions with unique TF sets.

set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  bash process_regions.sh --input <BED> --out <BED> [--min_len <INT>]

Options:
  --input     Input BED from multiinter (expects TF list in column 5)
  --out       Output BED with merged regions and unique TF list in column 4
  --min_len   Minimum merged region length to keep (default: 55)
USAGE
}

INPUT=""
OUT="final_regions_with_tf.bed"
MIN_LEN=55

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input) INPUT="$2"; shift 2;;
    --out) OUT="$2"; shift 2;;
    --min_len) MIN_LEN="$2"; shift 2;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: Unknown argument: $1" >&2; usage; exit 1;;
  esac
done

[[ -n "$INPUT" ]] || { echo "ERROR: --input is required" >&2; exit 1; }
[[ -f "$INPUT" ]] || { echo "ERROR: input not found: $INPUT" >&2; exit 1; }

tmp_pre="${OUT}.pre.tmp"
tmp_merged="${OUT}.merged.tmp"

# Keep: chrom, start, end, TF_list (column 5 of multiinter output)
# Sort before merging (bedtools merge requires sorted intervals).
awk 'BEGIN{OFS="\t"} {print $1, $2, $3, $5}' "$INPUT" \
  | sort -k1,1 -k2,2n > "$tmp_pre"

bedtools merge -i "$tmp_pre" -c 4 -o collapse -delim "," > "$tmp_merged"

if command -v gawk >/dev/null 2>&1; then
  # gawk: stable ordering via asorti()
  gawk -F"\t" -v OFS="\t" -v min_len="$MIN_LEN" '{
    len = $3 - $2;
    if (len < min_len) next;

    n = split($4, a, ",");
    delete uniq;
    for (i=1; i<=n; i++) if (a[i] != "") uniq[a[i]] = 1;

    m = asorti(uniq, keys);
    tf = "";
    for (i=1; i<=m; i++) tf = tf (i==1 ? "" : ",") keys[i];

    print $1, $2, $3, tf;
  }' "$tmp_merged" > "$OUT"
else
  # POSIX awk: TF order may be arbitrary
  awk -F"\t" -v OFS="\t" -v min_len="$MIN_LEN" '{
    len = $3 - $2;
    if (len < min_len) next;

    n = split($4, a, ",");
    delete uniq;
    for (i=1; i<=n; i++) if (a[i] != "") uniq[a[i]] = 1;

    first = 1;
    tf = "";
    for (k in uniq) {
      tf = tf (first ? "" : ",") k;
      first = 0;
    }

    print $1, $2, $3, tf;
  }' "$tmp_merged" > "$OUT"
fi

rm -f "$tmp_pre" "$tmp_merged"
echo "[OK] Wrote: $OUT"
