set global enable_auto_analyze=false;
SELECT sleep(60);
DROP STATS hits;
ANALYZE TABLE hits WITH SYNC;
