# Amazon Reviews Inverted Index Benchmark

This benchmark compares query performance between tables with and without inverted indexes using the Amazon Reviews dataset.

## Overview

Two separate benchmarks for direct comparison:
- `doris/` - Baseline table **without** inverted indexes
- `doris_indexed/` - Table **with** inverted indexes

Both use the same table name (`amazon_reviews`) but in different databases, allowing identical queries to run against different table configurations.

## Benchmark Structure

```
amazon_reviews/
├── README.md
├── doris/                   # Baseline (no inverted index)
│   ├── benchmark.yaml
│   ├── ddl/ddl.sql
│   ├── load/amazon_reviews.sql
│   ├── query/queries.sql
│   ├── query/fulltext_queries.sql
│   └── ...
└── doris_indexed/           # With inverted index
    ├── benchmark.yaml
    ├── ddl/ddl.sql
    ├── load/amazon_reviews.sql
    ├── query/queries.sql
    ├── query/fulltext_queries.sql
    └── ...
```

## Table Schema

Based on [VeloDB Inverted Index Blog](https://www.velodb.io/blog/inverted-index-it-speeds-up-text):

| Column | Type | Description |
|--------|------|-------------|
| `review_date` | INT | Review date as epoch days |
| `marketplace` | VARCHAR(20) | Amazon marketplace (US, UK, DE, etc.) |
| `customer_id` | BIGINT | Unique customer identifier |
| `review_id` | VARCHAR(40) | Unique review identifier |
| `product_id` | VARCHAR(10) | ASIN product identifier |
| `product_parent` | BIGINT | Parent product grouping |
| `product_title` | VARCHAR(500) | Product name |
| `product_category` | VARCHAR(50) | Product category |
| `star_rating` | SMALLINT | 1-5 star rating |
| `helpful_votes` | INT | Upvotes from other users |
| `total_votes` | INT | Total votes received |
| `vine` | BOOLEAN | Vine reviewer program member |
| `verified_purchase` | BOOLEAN | Verified purchase flag |
| `review_headline` | VARCHAR(500) | Review title |
| `review_body` | STRING | Full review text |

## Inverted Index Configuration (doris_indexed)

| Column | Index Type | Query Pattern |
|--------|-----------|---------------|
| `customer_id` | Posting List | Point lookup (exact match) |
| `product_id` | Posting List | Point lookup (exact match) |
| `review_id` | Posting List | Unique ID lookup |
| `star_rating` | BKD Tree | Range queries (>= 4 stars) |
| `helpful_votes` | BKD Tree | Range queries (>= 50 votes) |
| `review_body` | Tokenized (English) | Full-text search (MATCH_ALL, MATCH_ANY) |
| `review_headline` | Tokenized (English) | Full-text search |

## Query Categories

### Standard Queries (Q1-Q8)
Both benchmarks run identical queries for direct comparison:
- Q1: Count total reviews
- Q2: Platform-wide analytics (traditional OLAP)
- Q3: Customer history lookup (high-cardinality)
- Q4: Product review analysis (high-cardinality)
- Q5: Review ID lookup (unique identifier)
- Q6: Range query on ratings
- Q7: Multi-dimensional filter
- Q8: Category + product filter

### Full-Text Queries (Q1-Q8 in fulltext_queries.sql)
Both benchmarks run identical MATCH queries (falls back to full scan without index):
- MATCH_ALL: AND logic (all terms must match)
- MATCH_ANY: OR logic (any term matches)
- Combined with filters and aggregations

## Expected Performance Improvement

| Query Type | Without Index | With Index | Improvement |
|------------|--------------|------------|-------------|
| Customer lookup | ~35s | ~80ms | 400x |
| Product lookup | ~32s | ~60ms | 500x |
| Review ID lookup | ~30s | ~15ms | 2000x |
| Full-text search | ~60s | ~200ms | 300x |

## Data Source

[VeloDB/ClickHouse Amazon Reviews Dataset](https://www.velodb.io/blog/inverted-index-it-speeds-up-text)
- 135,589,433 reviews
- Snappy-compressed Parquet files (37GB total)
- Compressed size in Doris: 25.8GB (with ZSTD)
- Time period: 2010-2015 (six annual files)
- Source: `https://bench-dataset.s3.us-east-1.amazonaws.com/amazon_review/`

## Usage

```bash
# Run baseline benchmark (no inverted index)
./benchmark.sh amazon_reviews doris LOAD=true QUERY=true

# Run indexed benchmark (with inverted index)
./benchmark.sh amazon_reviews doris_indexed LOAD=true QUERY=true

# Compare results in doris/results/ and doris_indexed/results/
```

## References

- [Apache Doris Inverted Index Guide](https://doris.apache.org/docs/table-design/index/inverted-index)
- [VeloDB Inverted Index Blog](https://www.velodb.io/blog/inverted-index-it-speeds-up-text)
- [ClickHouse Amazon Reviews Dataset](https://clickhouse.com/docs/getting-started/example-datasets/amazon-reviews)
