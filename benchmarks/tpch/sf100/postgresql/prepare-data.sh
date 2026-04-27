#!/bin/bash
# TPC-H SF100 Data Preparation Script for PostgreSQL
# This script downloads and prepares TPC-H benchmark data from S3

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

echo "Preparing TPC-H SF100 data for PostgreSQL..."

# Create data directory
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# Aliyun OSS bucket URL (faster for CN region)
OSS_BASE="https://qa-build.oss-cn-beijing.aliyuncs.com/performance/data/tpch_sf100"

# List of TPC-H tables
TABLES=("customer" "lineitem" "nation" "orders" "part" "partsupp" "region" "supplier")

# Download data files from Aliyun OSS
for table in "${TABLES[@]}"; do
    echo "Downloading $table data..."
    
    # Check if split files exist (like lineitem has multiple parts)
    file_num=1
    downloaded=0
    while wget -c "$OSS_BASE/${table}.tbl.${file_num}" 2>/dev/null; do
        echo "Downloaded ${table}.tbl.${file_num}"
        file_num=$((file_num + 1))
        downloaded=1
    done
    
    # If no split files, download single file
    if [ $downloaded -eq 0 ]; then
        wget -c "$OSS_BASE/${table}.tbl" || echo "Warning: ${table}.tbl not found"
    fi
done

# Note: OSS data is uncompressed, skip extraction

# Concatenate split files if they exist
echo "Concatenating split files..."
for table in "${TABLES[@]}"; do
    if ls ${table}.tbl.* 1> /dev/null 2>&1; then
        echo "Concatenating ${table} parts..."
        cat ${table}.tbl.* > ${table}.tbl
        rm -f ${table}.tbl.[0-9]*
    fi
done

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
echo "1. Create database: createdb -h localhost -U postgres tpch"
echo "2. Run DDL: psql -h localhost -U postgres tpch -f $SCRIPT_DIR/ddl/ddl.sql"
echo "3. Load data using the benchmark framework or manually with load scripts"
