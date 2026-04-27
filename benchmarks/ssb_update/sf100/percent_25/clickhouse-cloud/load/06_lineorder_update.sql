-- 25% Update: Insert 2 additional lineorder files (files 1-2)
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.1.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.2.gz', CSV);
