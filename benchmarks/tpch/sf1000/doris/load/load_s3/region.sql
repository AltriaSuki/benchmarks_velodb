LOAD LABEL region_${TIMESTAMP}
(
    DATA INFILE("s3://${STORAGE_BUCKET}/tpch/sf1000/region/region.tbl.gz")
    INTO TABLE region
    COLUMNS TERMINATED BY "|"
    FORMAT AS "csv"
    (r_regionkey, r_name, r_comment, r_dummy)
    PROPERTIES('skip_lines' = '0')
)
WITH S3
(
    "AWS_ENDPOINT" = "${STORAGE_ENDPOINT}",
    "AWS_REGION" = "${STORAGE_REGION}",
    "use_path_style" = "false"
)
PROPERTIES
(
    "timeout" = "36000",

    "max_filter_ratio" = "0.1"
);
