#!/bin/bash
# Load hits dataset into BigQuery

set -euo pipefail

if [[ ! -f "hits.csv" ]]; then
    wget --continue --progress=dot:giga 'https://datasets.clickhouse.com/hits_compatible/hits.csv.gz'
    gzip -d -f hits.csv.gz
fi

bq load --source_format=CSV --allow_quoted_newlines=1 test.hits hits.csv
