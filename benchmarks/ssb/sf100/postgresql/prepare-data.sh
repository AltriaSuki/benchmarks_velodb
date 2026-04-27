#!/bin/bash
# SSB SF100 Data Preparation Script for PostgreSQL
# This script downloads and prepares SSB benchmark data from S3

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

echo "Preparing SSB SF100 data for PostgreSQL..."

# Create data directory
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# Aliyun OSS bucket URL (faster for CN region)
OSS_BASE="https://qa-build.oss-cn-beijing.aliyuncs.com/performance/data/ssb_sf100"

# Download data files
echo "Downloading customer data..."
wget -c "$OSS_BASE/customer.tbl"

echo "Downloading dates data..."
wget -c "$OSS_BASE/dates.tbl"

echo "Downloading part data..."
wget -c "$OSS_BASE/part.tbl"

echo "Downloading supplier data..."
wget -c "$OSS_BASE/supplier.tbl"

echo "Downloading lineorder data..."
wget -c "$OSS_BASE/lineorder.tbl.1"
wget -c "$OSS_BASE/lineorder.tbl.2"
wget -c "$OSS_BASE/lineorder.tbl.3"
wget -c "$OSS_BASE/lineorder.tbl.4"
wget -c "$OSS_BASE/lineorder.tbl.5"

# Note: OSS data is uncompressed, skip extraction

# Concatenate lineorder parts
echo "Concatenating lineorder parts..."
if ls lineorder.tbl.[1-5] 1> /dev/null 2>&1; then
    cat lineorder.tbl.[1-5] > lineorder.tbl
    rm -f lineorder.tbl.[1-5]
fi

# Remove trailing delimiter from all .tbl files (only if present)
echo "Checking and removing trailing delimiters..."
for file in *.tbl *.dat 2>/dev/null; do
    if [ -f "$file" ]; then
        # Check if first line has trailing delimiter
        if head -1 "$file" | grep -q '|$'; then
            echo "Removing trailing delimiter from $file..."
            sed -i 's/|$//' "$file"
        else
            echo "No trailing delimiter in $file, skipping..."
        fi
    fi
done

echo ""
echo "Data preparation completed!"
echo "Data files are located in: $DATA_DIR"
echo ""
echo "Next steps:"
echo "1. Create database: createdb -h localhost -U postgres ssb"
echo "2. Run DDL: psql -h localhost -U postgres ssb -f $SCRIPT_DIR/ddl/ddl.sql"
echo "3. Load data using the benchmark framework or manually with:"
echo "   psql -h localhost -U postgres ssb -f $SCRIPT_DIR/load/customer.sql"
echo "   (Repeat for all tables)"
