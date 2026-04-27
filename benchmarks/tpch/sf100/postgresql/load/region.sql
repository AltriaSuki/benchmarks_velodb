TRUNCATE TABLE region;
\copy region FROM PROGRAM 'sed "s/|$//" region.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
