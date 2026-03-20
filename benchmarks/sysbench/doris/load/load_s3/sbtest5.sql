LOAD LABEL sbtest5_${TIMESTAMP}
(
    DATA INFILE("s3://${STORAGE_BUCKET}/performance/data/sysbench/sbtest5.csv")
    INTO TABLE sbtest5
    COLUMNS TERMINATED BY "\t"
    LINES TERMINATED BY "\n"
)
WITH S3
(
    "AWS_ENDPOINT" = "${STORAGE_ENDPOINT}",
    "AWS_ACCESS_KEY" = "${STORAGE_ACCESS_KEY}",
    "AWS_SECRET_KEY" = "${STORAGE_SECRET_KEY}",
    "AWS_REGION" = "${STORAGE_REGION}",
    "use_path_style" = "false"
)
PROPERTIES
(
    "timeout" = "36000",
    "load_parallelism" = "8",
    "max_filter_ratio" = "0.1"
);
