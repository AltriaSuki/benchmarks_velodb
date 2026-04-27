## TODO
20251224  

- [ ] Support more databases or query engines.
- [ ] Ensure the compression of OSS test sets is consistent with S3 to guarantee fairness of load performance data.
- [ ] Script improvements: 1. Each system's script should support automatic version and data size detection 2. Some systems do not support JMeter testing, such as Redshift.
- [ ] Improve script usability: 1. Dependency installation 2. Simplified configuration.
- [ ] Add a test result validation step to ensure correctness.
- [ ] Performance data correction: ClickHouse Cloud ckbench missed 1 query; about 10 queries in TPC-DS are not supported due to syntax, need to fix; most TPC-DS queries failed due to OOM or timeout, will rerun and update data next time.
