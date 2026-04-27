-- tpch sf1000
USE tpch_sf1000;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.lineitem PROPERTIES ('write-format'='orc') AS SELECT * FROM lineitem;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.orders PROPERTIES ('write-format'='orc') AS SELECT * FROM orders;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.partsupp PROPERTIES ('write-format'='orc') AS SELECT * FROM partsupp;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.part PROPERTIES ('write-format'='orc') AS SELECT * FROM part;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.customer PROPERTIES ('write-format'='orc') AS SELECT * FROM customer;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.supplier PROPERTIES ('write-format'='orc') AS SELECT * FROM supplier;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.nation PROPERTIES ('write-format'='orc') AS SELECT * FROM nation;
CREATE TABLE iceberg_nessie.tpch_sf1000_orc.region PROPERTIES ('write-format'='orc') AS SELECT * FROM region;
