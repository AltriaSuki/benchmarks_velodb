TRUNCATE TABLE part;
\copy part FROM PROGRAM 'sed "s/|$//" part.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
