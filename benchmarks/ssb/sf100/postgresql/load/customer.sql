TRUNCATE TABLE customer;
\copy customer FROM PROGRAM 'sed "s/|$//" customer.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
