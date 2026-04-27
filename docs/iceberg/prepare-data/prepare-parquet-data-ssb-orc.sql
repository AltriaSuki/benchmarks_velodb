-- ssb sf1000
USE ssb_sf1000;
CREATE TABLE iceberg_nessie.ssb_sf1000_orc.lineorder PROPERTIES ('write-format'='orc') AS SELECT * FROM lineorder;
CREATE TABLE iceberg_nessie.ssb_sf1000_orc.customer PROPERTIES ('write-format'='orc') AS SELECT * FROM customer;
CREATE TABLE iceberg_nessie.ssb_sf1000_orc.dates PROPERTIES ('write-format'='orc') AS SELECT * FROM dates;
CREATE TABLE iceberg_nessie.ssb_sf1000_orc.supplier PROPERTIES ('write-format'='orc') AS SELECT * FROM supplier;
CREATE TABLE iceberg_nessie.ssb_sf1000_orc.part PROPERTIES ('write-format'='orc') AS SELECT * FROM part;