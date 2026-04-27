set global enable_auto_analyze=false;
-- Increase timeout and avoid sleep() which can fail due to fragment RPC timeouts
-- under load; ANALYZE itself is sufficient synchronization for this benchmark.
set query_timeout=86400;
DROP STATS hits;
ANALYZE TABLE hits WITH SYNC;
