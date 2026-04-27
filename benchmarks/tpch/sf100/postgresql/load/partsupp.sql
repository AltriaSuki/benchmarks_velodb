TRUNCATE TABLE partsupp;
\copy partsupp FROM PROGRAM 'sed "s/|$//" partsupp.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
