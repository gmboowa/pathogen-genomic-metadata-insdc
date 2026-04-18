#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF
Usage:
  $(basename "$0") --input /absolute/path/to/file.tsv --output /path/to/output_dir
EOF
}

INPUT=""
OUTDIR=""

# -----------------------------
# Parse arguments
# -----------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --input)
            INPUT="${2:-}"
            shift 2
            ;;
        --output)
            OUTDIR="${2:-}"
            shift 2
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [[ -z "$INPUT" || -z "$OUTDIR" ]]; then
    echo "Error: --input and --output are required"
    exit 1
fi

if [[ ! -f "$INPUT" ]]; then
    echo "Error: Input file not found"
    exit 1
fi

mkdir -p "$OUTDIR"

SUCCESS_LOG="$OUTDIR/download_success.log"
FAIL_LOG="$OUTDIR/download_failed.log"
RUN_LIST="$OUTDIR/run_accessions.txt"

: > "$SUCCESS_LOG"
: > "$FAIL_LOG"
: > "$RUN_LIST"

# -----------------------------
# Extract first column
# -----------------------------
awk -F '\t' 'NF>0 {gsub(/\r/,"",$1); print $1}' "$INPUT" \
    | sed '/^[[:space:]]*$/d' \
    | awk '
        BEGIN {IGNORECASE=1}
        NR==1 && ($1 ~ /run|accession|sample|ena|sra/) {next}
        {print}
      ' \
    | sort -u > "$RUN_LIST"

TOTAL=$(wc -l < "$RUN_LIST" | tr -d ' ')

if [[ "$TOTAL" -eq 0 ]]; then
    echo "No accessions found."
    exit 1
fi

echo "======================================="
echo "Total samples detected: $TOTAL"
echo "Output directory: $OUTDIR"
echo "======================================="
echo

# -----------------------------
# Download loop with progress
# -----------------------------
COUNT=0

while IFS= read -r RUN; do
    [[ -z "$RUN" ]] && continue

    COUNT=$((COUNT + 1))

    # Calculate percentage
    PERCENT=$(awk "BEGIN {printf \"%.2f\", ($COUNT/$TOTAL)*100}")

    echo "[$COUNT/$TOTAL | ${PERCENT}%] Downloading: $RUN"

    # Skip existing
    if [[ -f "$OUTDIR/${RUN}.fastq.gz" || \
          ( -f "$OUTDIR/${RUN}_1.fastq.gz" && -f "$OUTDIR/${RUN}_2.fastq.gz" ) ]]; then
        echo "  → Already exists, skipping"
        echo "$RUN" >> "$SUCCESS_LOG"
        continue
    fi

    if fastq-dump --split-3 --gzip -O "$OUTDIR" "$RUN"; then
        echo "  ✓ Success"
        echo "$RUN" >> "$SUCCESS_LOG"
    else
        echo "  ✗ Failed"
        echo "$RUN" >> "$FAIL_LOG"
    fi

    echo

done < "$RUN_LIST"

# -----------------------------
# Summary
# -----------------------------
SUCCESS_COUNT=$(wc -l < "$SUCCESS_LOG" | tr -d ' ')
FAIL_COUNT=$(wc -l < "$FAIL_LOG" | tr -d ' ')

echo "======================================="
echo "Download complete"
echo "Successful: $SUCCESS_COUNT"
echo "Failed    : $FAIL_COUNT"
echo "======================================="

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo "Failed runs saved in:"
    echo "$FAIL_LOG"
fi
