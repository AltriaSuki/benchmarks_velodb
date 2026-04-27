TRUNCATE TABLE supplier;
\copy supplier FROM PROGRAM 'sed "s/|$//" supplier.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
