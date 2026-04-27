TRUNCATE TABLE lineitem;
\copy lineitem FROM PROGRAM 'sed "s/|$//" lineitem.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
