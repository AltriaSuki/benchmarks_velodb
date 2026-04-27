-- 100% Update: Insert 10 additional lineorder files (files 1-10)
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.1.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.2.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.3.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.4.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.5.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.6.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.7.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.8.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.9.gz', CSV);
INSERT INTO lineorder SELECT * FROM url('https://yyq-test.s3.us-west-2.amazonaws.com/regression/ssb/sf100/lineorder.tbl.10.gz', CSV);
