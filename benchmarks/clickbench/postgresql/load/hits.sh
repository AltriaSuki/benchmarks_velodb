#!/bin/bash
# Load hits data into PostgreSQL using COPY command
# This script assumes hits.tsv file is available in the current directory

set -e

export PGPASSWORD="${password:-}"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TSV_FILE="$SCRIPT_DIR/hits.tsv"

echo "Loading hits table from $TSV_FILE..."

# Use COPY command with FREEZE option for better performance
# FREEZE prevents generating WAL records during initial load
# Note: Don't specify NULL handling - empty strings in TSV remain as empty strings (not NULL)
psql -h "$pg_host" -p "$pg_port" -U "$user" -d "$db" <<EOF
BEGIN;
TRUNCATE TABLE hits;
\copy hits FROM '$TSV_FILE' with freeze;
COMMIT;
EOF

echo "Data loaded successfully"

# Run VACUUM ANALYZE for optimal query performance
echo "Running VACUUM ANALYZE..."
psql -h "$pg_host" -p "$pg_port" -U "$user" -d "$db" -c "VACUUM ANALYZE hits;"

echo "Load completed"
