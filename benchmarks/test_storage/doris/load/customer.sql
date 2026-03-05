INSERT INTO customer SELECT * FROM S3 (
    "uri" = "s3://${STORAGE_BUCKET}/${STORAGE_PREFIX}/customer.tbl",
    "s3.endpoint" = "${STORAGE_ENDPOINT}",
    "s3.region" = "${STORAGE_REGION}"
);
