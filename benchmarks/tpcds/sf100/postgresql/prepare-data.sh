#!/bin/bash
# TPC-DS SF100 Data Preparation Script for PostgreSQL
# This script downloads and prepares TPC-DS benchmark data from S3

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

echo "Preparing TPC-DS SF100 data for PostgreSQL..."

# Create data directory
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# Aliyun OSS bucket URL (faster for CN region)
OSS_BASE="https://qa-build.oss-cn-beijing.aliyuncs.com/performance/data/tpcds_sf100"

# List of TPC-DS tables (24 tables)
TABLES=(
    "call_center" "catalog_page" "catalog_returns" "catalog_sales"
    "customer" "customer_address" "customer_demographics" "date_dim"
    "household_demographics" "income_band" "inventory" "item"
    "promotion" "reason" "ship_mode" "store" "store_returns" "store_sales"
    "time_dim" "warehouse" "web_page" "web_returns" "web_sales" "web_site"
)

# Download data files from Aliyun OSS
for table in "${TABLES[@]}"; do
    echo "Downloading $table data..."
    
    # TPC-DS uses .dat extension
    # Files are directly under tpcds_sf100/ (not in subdirectories)
    if wget -c "$OSS_BASE/${table}.dat"; then
        echo "Downloaded ${table}.dat successfully"
    else
        echo "Warning: ${table}.dat not found, checking for split files..."
        # Check if split files exist
        file_num=1
        downloaded=0
        while wget -c "$OSS_BASE/${table}.dat.${file_num}" 2>/dev/null; do
            echo "Downloaded ${table}.dat.${file_num}"
            file_num=$((file_num + 1))
            downloaded=1
        done
        
        if [ $downloaded -eq 0 ]; then
            echo "ERROR: No data found for ${table}"
        fi
    fi
done

# Note: OSS data is uncompressed, skip extraction

# Concatenate split files if they exist
echo "Concatenating split files..."
for table in "${TABLES[@]}"; do
    if ls ${table}.dat.* 1> /dev/null 2>&1; then
        echo "Concatenating ${table} parts..."
        cat ${table}.dat.* > ${table}.dat
        rm -f ${table}.dat.[0-9]*
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
echo "1. Create database: createdb -h localhost -U postgres tpcds"
echo "2. Run DDL: psql -h localhost -U postgres tpcds -f $SCRIPT_DIR/ddl/ddl.sql"
echo "3. Load data using the benchmark framework or manually with load scripts"
