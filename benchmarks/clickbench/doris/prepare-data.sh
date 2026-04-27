#!/bin/bash
set -euo pipefail

# Doris local-load reuses the PostgreSQL-prepared ClickBench hits.tsv.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PG_DIR="${SCRIPT_DIR}/../postgresql"
HITS_TSV="${PG_DIR}/load/hits.tsv"

size_bytes=0
if [[ -f "$HITS_TSV" ]]; then
  size_bytes="$(stat -c%s "$HITS_TSV" 2>/dev/null || echo 0)"
fi

# hits.tsv should be >10GB when complete; reuse PG prepare script's logic.
if [[ ! -f "$HITS_TSV" || "$size_bytes" -lt 10000000000 ]]; then
  echo "[INFO] ClickBench hits.tsv not found at $HITS_TSV; preparing via PostgreSQL prepare-data.sh..."
  (cd "$PG_DIR" && bash prepare-data.sh)
fi

echo "[INFO] ClickBench data ready for Doris local load: $HITS_TSV"
