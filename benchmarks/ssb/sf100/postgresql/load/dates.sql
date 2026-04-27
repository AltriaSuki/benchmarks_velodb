TRUNCATE TABLE date;
\copy date FROM PROGRAM 'sed "s/|$//" dates.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
