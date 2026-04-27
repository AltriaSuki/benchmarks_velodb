#!/bin/bash
set -euo pipefail

# Doris local-load reuses the PostgreSQL-prepared SSB SF100 data files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PG_DIR="${SCRIPT_DIR}/../postgresql"
DATA_DIR="${PG_DIR}/data"

need_file="${DATA_DIR}/lineorder.tbl"
if [[ ! -s "$need_file" ]]; then
  echo "[INFO] SSB SF100 data not found at $need_file; preparing via PostgreSQL prepare-data.sh..."
  (cd "$PG_DIR" && bash prepare-data.sh)
fi

echo "[INFO] SSB SF100 data ready for Doris local load: $DATA_DIR"
