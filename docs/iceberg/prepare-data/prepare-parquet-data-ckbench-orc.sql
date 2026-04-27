-- ckbench
USE clickbench;
CREATE TABLE iceberg_nessie.clickbench_orc.hits PROPERTIES ('write-format'='orc') AS SELECT * FROM hits;