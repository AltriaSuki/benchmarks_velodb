-- TPC-H DDL for PostgreSQL
-- Scale Factor: 100 (~100GB)

-- NOTE:
-- Per benchmark requirement: do NOT create any indexes (including PRIMARY KEY)
-- to avoid index maintenance cost during data loading.
--
-- Drop any existing indexes/PKs from prior runs so COPY doesn't maintain them.
DROP INDEX IF EXISTS idx_supplier_nationkey;
DROP INDEX IF EXISTS idx_partsupp_partkey;
DROP INDEX IF EXISTS idx_partsupp_suppkey;
DROP INDEX IF EXISTS idx_customer_nationkey;
DROP INDEX IF EXISTS idx_orders_custkey;
DROP INDEX IF EXISTS idx_orders_orderdate;
DROP INDEX IF EXISTS idx_lineitem_orderkey;
DROP INDEX IF EXISTS idx_lineitem_partkey;
DROP INDEX IF EXISTS idx_lineitem_suppkey;
DROP INDEX IF EXISTS idx_lineitem_shipdate;

ALTER TABLE IF EXISTS nation   DROP CONSTRAINT IF EXISTS nation_pkey;
ALTER TABLE IF EXISTS region   DROP CONSTRAINT IF EXISTS region_pkey;
ALTER TABLE IF EXISTS part     DROP CONSTRAINT IF EXISTS part_pkey;
ALTER TABLE IF EXISTS supplier DROP CONSTRAINT IF EXISTS supplier_pkey;
ALTER TABLE IF EXISTS partsupp DROP CONSTRAINT IF EXISTS partsupp_pkey;
ALTER TABLE IF EXISTS customer DROP CONSTRAINT IF EXISTS customer_pkey;
ALTER TABLE IF EXISTS orders   DROP CONSTRAINT IF EXISTS orders_pkey;
ALTER TABLE IF EXISTS lineitem DROP CONSTRAINT IF EXISTS lineitem_pkey;

CREATE TABLE IF NOT EXISTS nation (
    n_nationkey  INTEGER NOT NULL,
    n_name       VARCHAR(25) NOT NULL,
    n_regionkey  INTEGER NOT NULL,
    n_comment    VARCHAR(152)
);

CREATE TABLE IF NOT EXISTS region (
    r_regionkey  INTEGER NOT NULL,
    r_name       VARCHAR(25) NOT NULL,
    r_comment    VARCHAR(152)
);

CREATE TABLE IF NOT EXISTS part (
    p_partkey     INTEGER NOT NULL,
    p_name        VARCHAR(55) NOT NULL,
    p_mfgr        VARCHAR(25) NOT NULL,
    p_brand       VARCHAR(10) NOT NULL,
    p_type        VARCHAR(25) NOT NULL,
    p_size        INTEGER NOT NULL,
    p_container   VARCHAR(10) NOT NULL,
    p_retailprice DECIMAL(15,2) NOT NULL,
    p_comment     VARCHAR(23) NOT NULL
);

CREATE TABLE IF NOT EXISTS supplier (
    s_suppkey     INTEGER NOT NULL,
    s_name        VARCHAR(25) NOT NULL,
    s_address     VARCHAR(40) NOT NULL,
    s_nationkey   INTEGER NOT NULL,
    s_phone       VARCHAR(15) NOT NULL,
    s_acctbal     DECIMAL(15,2) NOT NULL,
    s_comment     VARCHAR(101) NOT NULL
);

CREATE TABLE IF NOT EXISTS partsupp (
    ps_partkey     INTEGER NOT NULL,
    ps_suppkey     INTEGER NOT NULL,
    ps_availqty    INTEGER NOT NULL,
    ps_supplycost  DECIMAL(15,2) NOT NULL,
    ps_comment     VARCHAR(199) NOT NULL
);

CREATE TABLE IF NOT EXISTS customer (
    c_custkey     INTEGER NOT NULL,
    c_name        VARCHAR(25) NOT NULL,
    c_address     VARCHAR(40) NOT NULL,
    c_nationkey   INTEGER NOT NULL,
    c_phone       VARCHAR(15) NOT NULL,
    c_acctbal     DECIMAL(15,2) NOT NULL,
    c_mktsegment  VARCHAR(10) NOT NULL,
    c_comment     VARCHAR(117) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    o_orderkey       BIGINT NOT NULL,
    o_custkey        INTEGER NOT NULL,
    o_orderstatus    VARCHAR(1) NOT NULL,
    o_totalprice     DECIMAL(15,2) NOT NULL,
    o_orderdate      DATE NOT NULL,
    o_orderpriority  VARCHAR(15) NOT NULL,
    o_clerk          VARCHAR(15) NOT NULL,
    o_shippriority   INTEGER NOT NULL,
    o_comment        VARCHAR(79) NOT NULL
);

CREATE TABLE IF NOT EXISTS lineitem (
    l_orderkey       BIGINT NOT NULL,
    l_partkey        INTEGER NOT NULL,
    l_suppkey        INTEGER NOT NULL,
    l_linenumber     INTEGER NOT NULL,
    l_quantity       DECIMAL(15,2) NOT NULL,
    l_extendedprice  DECIMAL(15,2) NOT NULL,
    l_discount       DECIMAL(15,2) NOT NULL,
    l_tax            DECIMAL(15,2) NOT NULL,
    l_returnflag     VARCHAR(1) NOT NULL,
    l_linestatus     VARCHAR(1) NOT NULL,
    l_shipdate       DATE NOT NULL,
    l_commitdate     DATE NOT NULL,
    l_receiptdate    DATE NOT NULL,
    l_shipinstruct   VARCHAR(25) NOT NULL,
    l_shipmode       VARCHAR(10) NOT NULL,
    l_comment        VARCHAR(44) NOT NULL
);

-- Foreign key constraints (optional, can be commented out for faster loading)
-- ALTER TABLE supplier ADD FOREIGN KEY (s_nationkey) REFERENCES nation(n_nationkey);
-- ALTER TABLE customer ADD FOREIGN KEY (c_nationkey) REFERENCES nation(n_nationkey);
-- ALTER TABLE nation ADD FOREIGN KEY (n_regionkey) REFERENCES region(r_regionkey);
-- ALTER TABLE partsupp ADD FOREIGN KEY (ps_suppkey) REFERENCES supplier(s_suppkey);
-- ALTER TABLE partsupp ADD FOREIGN KEY (ps_partkey) REFERENCES part(p_partkey);
-- ALTER TABLE orders ADD FOREIGN KEY (o_custkey) REFERENCES customer(c_custkey);
-- ALTER TABLE lineitem ADD FOREIGN KEY (l_orderkey) REFERENCES orders(o_orderkey);
-- ALTER TABLE lineitem ADD FOREIGN KEY (l_partkey, l_suppkey) REFERENCES partsupp(ps_partkey, ps_suppkey);
