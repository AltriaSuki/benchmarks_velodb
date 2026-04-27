-- Analyze tables for PostgreSQL query optimizer
--
-- Run after data load so the planner has statistics for the TPC-DS schema.

ANALYZE call_center;
ANALYZE catalog_page;
ANALYZE catalog_returns;
ANALYZE catalog_sales;
ANALYZE customer;
ANALYZE customer_address;
ANALYZE customer_demographics;
ANALYZE date_dim;
ANALYZE dbgen_version;
ANALYZE household_demographics;
ANALYZE income_band;
ANALYZE inventory;
ANALYZE item;
ANALYZE promotion;
ANALYZE reason;
ANALYZE ship_mode;
ANALYZE store;
ANALYZE store_returns;
ANALYZE store_sales;
ANALYZE time_dim;
ANALYZE warehouse;
ANALYZE web_page;
ANALYZE web_returns;
ANALYZE web_sales;
ANALYZE web_site;

