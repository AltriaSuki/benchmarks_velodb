SELECT sleep(60);
DROP STATS lineorder_flat;
ANALYZE TABLE lineorder_flat WITH SYNC;
