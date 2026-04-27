TRUNCATE TABLE nation;
\copy nation FROM PROGRAM 'sed "s/|$//" nation.tbl' WITH (FORMAT csv, DELIMITER '|', NULL '');
