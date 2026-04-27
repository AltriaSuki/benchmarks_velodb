CREATE TABLE lineorder 
(
  lo_orderkey            BIGINT NOT NULL,
  lo_linenumber          INTEGER NOT NULL,
  lo_custkey             INTEGER NOT NULL,
  lo_partkey             INTEGER NOT NULL,
  lo_suppkey             INTEGER NOT NULL,
  lo_orderdate           INTEGER NOT NULL,
  lo_orderpriority       VARCHAR(16) NOT NULL,
  lo_shippriority        INTEGER NOT NULL,
  lo_quantity            INTEGER NOT NULL,
  lo_extendedprice       INTEGER NOT NULL,
  lo_ordtotalprice       INTEGER NOT NULL,
  lo_discount            INTEGER NOT NULL,
  lo_revenue             INTEGER NOT NULL,
  lo_supplycost          INTEGER NOT NULL,
  lo_tax                 INTEGER NOT NULL,
  lo_commitdate          INTEGER NOT NULL,
  lo_shipmode            VARCHAR(11) NOT NULL
)
distkey (lo_custkey) 
sortkey (lo_orderdate, lo_custkey);

CREATE TABLE customer 
(
  c_custkey          INTEGER NOT NULL,
  c_name             VARCHAR(26) NOT NULL,
  c_address          VARCHAR(41) NOT NULL,
  c_city             VARCHAR(11) NOT NULL,
  c_nation           VARCHAR(16) NOT NULL,
  c_region           VARCHAR(13) NOT NULL,
  c_phone            VARCHAR(16) NOT NULL,
  c_mktsegment       VARCHAR(11) NOT NULL
)
diststyle all;


CREATE TABLE supplier 
(
  s_suppkey          INTEGER NOT NULL,
  s_name             VARCHAR(26) NOT NULL,
  s_address          VARCHAR(26) NOT NULL,
  s_city             VARCHAR(11) NOT NULL,
  s_nation           VARCHAR(16) NOT NULL,
  s_region           VARCHAR(13) NOT NULL,
  s_phone            VARCHAR(16) NOT NULL
)
diststyle all;


CREATE TABLE part 
(
  p_partkey          INTEGER NOT NULL,
  p_name             VARCHAR(23) NOT NULL,
  p_mfgr             VARCHAR(7) NOT NULL,
  p_category         VARCHAR(8) NOT NULL,
  p_brand            VARCHAR(10) NOT NULL,
  p_color            VARCHAR(12) NOT NULL,
  p_type             VARCHAR(26) NOT NULL,
  p_size             INTEGER NOT NULL,
  p_container        VARCHAR(11) NOT NULL
)
diststyle all;


CREATE TABLE dates 
(
  d_datekey          INTEGER NOT NULL,
  d_date             VARCHAR(20) NOT NULL,
  d_dayofweek        VARCHAR(10) NOT NULL,
  d_month            VARCHAR(11) NOT NULL,
  d_year             INTEGER NOT NULL,
  d_yearmonthnum     INTEGER NOT NULL,
  d_yearmonth        VARCHAR(9) NOT NULL,
  d_daynuminweek     INTEGER NOT NULL,
  d_daynuminmonth    INTEGER NOT NULL,
  d_daynuminyear     INTEGER NOT NULL,
  d_monthnuminyear   INTEGER NOT NULL,
  d_weeknuminyear    INTEGER NOT NULL,
  d_sellingseason    VARCHAR(14) NOT NULL,
  d_lastdayinweekfl  INTEGER NOT NULL,
  d_lastdayinmonthfl INTEGER NOT NULL,
  d_holidayfl        INTEGER NOT NULL,
  d_weekdayfl        INTEGER NOT NULL
)
diststyle all
sortkey (d_datekey);