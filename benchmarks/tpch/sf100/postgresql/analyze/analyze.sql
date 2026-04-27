-- Analyze tables for PostgreSQL query optimizer
--
-- This updates planner statistics after data load so TPC-H queries (especially
-- heavy join/correlated subquery ones like Q20) can get a reasonable plan.

ANALYZE nation;
ANALYZE region;
ANALYZE part;
ANALYZE supplier;
ANALYZE partsupp;
ANALYZE customer;
ANALYZE orders;
ANALYZE lineitem;

