-- ckbench
USE clickbench;
CREATE TABLE iceberg_nessie.clickbench_parquet.hits PROPERTIES ('write-format'='parquet') AS SELECT * FROM hits;