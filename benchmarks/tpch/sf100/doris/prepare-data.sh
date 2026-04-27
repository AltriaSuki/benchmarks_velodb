#!/bin/bash
set -euo pipefail

# Doris local-load reuses the PostgreSQL-prepared TPCH SF100 data files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PG_DIR="${SCRIPT_DIR}/../postgresql"
DATA_DIR="${PG_DIR}/data"

need_file="${DATA_DIR}/lineitem.tbl"
if [[ ! -f "$need_file" ]]; then
  echo "[INFO] TPCH SF100 data not found at $need_file; preparing via PostgreSQL prepare-data.sh..."
  (cd "$PG_DIR" && bash prepare-data.sh)
fi

echo "[INFO] TPCH SF100 data ready for Doris local load: $DATA_DIR"

