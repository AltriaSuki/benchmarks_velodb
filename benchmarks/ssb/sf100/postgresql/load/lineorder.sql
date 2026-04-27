TRUNCATE TABLE lineorder;
\copy lineorder FROM PROGRAM 'sed "s/|$//" lineorder.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
