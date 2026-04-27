-- ssb sf1000
USE ssb_sf1000;
CREATE TABLE iceberg_nessie.ssb_sf1000_parquet.lineorder PROPERTIES ('write-format'='parquet') AS SELECT * FROM lineorder;
CREATE TABLE iceberg_nessie.ssb_sf1000_parquet.customer PROPERTIES ('write-format'='parquet') AS SELECT * FROM customer;
CREATE TABLE iceberg_nessie.ssb_sf1000_parquet.dates PROPERTIES ('write-format'='parquet') AS SELECT * FROM dates;
CREATE TABLE iceberg_nessie.ssb_sf1000_parquet.supplier PROPERTIES ('write-format'='parquet') AS SELECT * FROM supplier;
CREATE TABLE iceberg_nessie.ssb_sf1000_parquet.part PROPERTIES ('write-format'='parquet') AS SELECT * FROM part;