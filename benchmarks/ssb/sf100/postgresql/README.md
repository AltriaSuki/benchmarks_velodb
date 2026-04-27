# PostgreSQL Benchmark Data

## Data Source

All benchmark data can be downloaded from the public S3 bucket:
- Base URL: `https://bench-dataset.s3.amazonaws.com/`
- SSB SF100: `https://bench-dataset.s3.amazonaws.com/ssb/sf100/`
- TPC-H SF100: `https://bench-dataset.s3.amazonaws.com/tpch/sf100/`
- TPC-DS SF100: `https://bench-dataset.s3.amazonaws.com/tpcds/sf100/`

## Download Data

Use `wget` to download the data files to the corresponding `load/` directory:

```bash
# Example for SSB
cd benchmarks/ssb/sf100/postgresql/load/
wget https://bench-dataset.s3.amazonaws.com/ssb/sf100/customer.tbl.gz
gunzip customer.tbl.gz
# Repeat for other files...
```

## Load Data

The `*.sql` files in the `load/` directory use relative paths. Execute them from the `load/` directory:

```bash
cd benchmarks/ssb/sf100/postgresql/load/
psql -h <host> -p <port> -U <user> -d <database> -f customer.sql
```

Or run the full benchmark using the framework:
```bash
export PG_HOST=127.0.0.1 PG_PORT=5432 PG_USER=postgres PG_PASSWORD='' DB=ssb LOAD=true QUERY=true
bash benchmark.sh --config benchmarks/ssb/sf100/postgresql/benchmark.yaml
```

## Notes

- Data files should be placed in the same directory as the SQL load scripts
- Each table has a separate SQL file matching the Redshift structure
- DDL has been adapted from Redshift to be PostgreSQL-compatible
