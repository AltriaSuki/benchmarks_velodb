-- Amazon Reviews Benchmark: Baseline (No Inverted Index)
-- Reference: https://www.velodb.io/blog/inverted-index-it-speeds-up-text
-- Data: 135,589,433 reviews, 37GB Parquet -> 25.8GB compressed in Doris

CREATE TABLE IF NOT EXISTS amazon_reviews (
    review_date INT NULL,
    marketplace VARCHAR(20) NULL,
    customer_id BIGINT NULL,
    review_id VARCHAR(40) NULL,
    product_id VARCHAR(10) NULL,
    product_parent BIGINT NULL,
    product_title VARCHAR(500) NULL,
    product_category VARCHAR(50) NULL,
    star_rating SMALLINT NULL,
    helpful_votes INT NULL,
    total_votes INT NULL,
    vine BOOLEAN NULL,
    verified_purchase BOOLEAN NULL,
    review_headline VARCHAR(500) NULL,
    review_body STRING NULL
)
DUPLICATE KEY(review_date)
DISTRIBUTED BY HASH(review_date) BUCKETS 16
PROPERTIES (
    "compression" = "ZSTD"
);
