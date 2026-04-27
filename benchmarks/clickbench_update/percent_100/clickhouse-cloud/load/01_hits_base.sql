-- Base load: Insert all 100 parquet files (hits_0 to hits_99)
INSERT INTO hits SELECT * FROM url('https://datasets.clickhouse.com/hits_compatible/athena_partitioned/hits_{0..99}.parquet');
