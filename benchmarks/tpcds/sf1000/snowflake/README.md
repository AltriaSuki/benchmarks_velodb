# TPC-DS SF1000 on Snowflake

## DDL
There are sample data on snowflake and when viewing definition of a table of tpcds
It gives an error like this:  
> Something went wrong: This operation is not supported on shared database 'SNOWFLAKE_SAMPLE_DATA'.

But create table t1 like t2 works fine.
So you can create your own tables and view definition of them to get the DDL.

## Data Loading
COPY INTO command can be used to load data from s3 to snowflake tables.


## Queries
The TPC-DS queries are available [here](https://docs.snowflake.com/en/_downloads/0eec2c68e78863a07eb994c85e76b188/tpc-ds-all-queries.sql)  
To ensure query results align with others, the queries are identical to Redshift's TPC-DS queries.


## References
[Sample Data TPC-DS on Snowflake](https://docs.snowflake.com/en/user-guide/sample-data-tpcds)


