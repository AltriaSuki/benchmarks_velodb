TRUNCATE TABLE orders;
\copy orders FROM PROGRAM 'sed "s/|$//" orders.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
