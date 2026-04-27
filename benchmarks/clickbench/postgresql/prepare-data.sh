#!/bin/bash
# ClickBench Data Preparation Script for PostgreSQL
# This script downloads hits.tsv from qa-build OSS bucket

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/load"

echo "Preparing ClickBench data for PostgreSQL..."

# Create data directory if not exists
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

# Check if hits.tsv already exists
if [ -f "hits.tsv" ]; then
    echo "hits.tsv already exists, checking size..."
    SIZE=$(stat -f%z "hits.tsv" 2>/dev/null || stat -c%s "hits.tsv" 2>/dev/null || echo 0)
    if [ "$SIZE" -gt 10000000000 ]; then  # > 10GB
        echo "hits.tsv appears to be complete (size: $SIZE bytes)"
        echo "To re-download, delete hits.tsv and run this script again"
        exit 0
    else
        echo "hits.tsv exists but seems incomplete (size: $SIZE bytes), re-downloading..."
        rm -f hits.tsv
    fi
fi

# Aliyun OSS bucket URL (faster for CN region)
OSS_URL="https://qa-build.oss-cn-beijing.aliyuncs.com/performance/data/clickbench/hits.tsv"

echo "Downloading hits.tsv from qa-build OSS bucket..."
echo "This is a large file (~14.5GB), may take several minutes..."

# Download from qa-build
if wget -c "$OSS_URL" -O hits.tsv; then
    echo "Download from qa-build successful"
else
    echo "ERROR: Failed to download from qa-build bucket"
    echo "Tried URL: $OSS_URL"
    echo ""
    echo "Falling back to ClickHouse official mirror..."
    wget --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
    echo "Extracting..."
    gunzip -f hits.tsv.gz
fi

# Verify downloaded file
if [ ! -f "hits.tsv" ]; then
    echo "ERROR: hits.tsv not found after download"
    exit 1
fi

SIZE=$(stat -f%z "hits.tsv" 2>/dev/null || stat -c%s "hits.tsv" 2>/dev/null || echo 0)
echo ""
echo "Download completed!"
echo "File size: $SIZE bytes (~$(($SIZE / 1024 / 1024 / 1024))GB)"
echo "File location: $DATA_DIR/hits.tsv"
echo ""
echo "Next steps:"
echo "1. Ensure PostgreSQL is running"
echo "2. Create database: createdb -h localhost -U postgres clickbench"
echo "3. Run benchmark:"
echo "   cd $SCRIPT_DIR/../../../.."
echo "   bash benchmark.sh --config benchmarks/clickbench/postgresql/benchmark.yaml LOAD=true QUERY=true"

