-- tpch sf1000
USE tpch_sf1000;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.lineitem PROPERTIES ('write-format'='parquet') AS SELECT * FROM lineitem;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.orders PROPERTIES ('write-format'='parquet') AS SELECT * FROM orders;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.partsupp PROPERTIES ('write-format'='parquet') AS SELECT * FROM partsupp;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.part PROPERTIES ('write-format'='parquet') AS SELECT * FROM part;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.customer PROPERTIES ('write-format'='parquet') AS SELECT * FROM customer;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.supplier PROPERTIES ('write-format'='parquet') AS SELECT * FROM supplier;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.nation PROPERTIES ('write-format'='parquet') AS SELECT * FROM nation;
CREATE TABLE iceberg_nessie.tpch_sf1000_parquet.region PROPERTIES ('write-format'='parquet') AS SELECT * FROM region;
