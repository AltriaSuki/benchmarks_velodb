drop table if exists lineorder;
CREATE TABLE IF NOT EXISTS `lineorder` (
  `lo_orderkey` int(11) NOT NULL COMMENT "",
  `lo_linenumber` int(11) NOT NULL COMMENT "",
  `lo_custkey` int(11) NOT NULL COMMENT "",
  `lo_partkey` int(11) NOT NULL COMMENT "",
  `lo_suppkey` int(11) NOT NULL COMMENT "",
  `lo_orderdate` int(11) NOT NULL COMMENT "",
  `lo_orderpriority` varchar(16) NOT NULL COMMENT "",
  `lo_shippriority` int(11) NOT NULL COMMENT "",
  `lo_quantity` int(11) NOT NULL COMMENT "",
  `lo_extendedprice` int(11) NOT NULL COMMENT "",
  `lo_ordtotalprice` int(11) NOT NULL COMMENT "",
  `lo_discount` int(11) NOT NULL COMMENT "",
  `lo_revenue` int(11) NOT NULL COMMENT "",
  `lo_supplycost` int(11) NOT NULL COMMENT "",
  `lo_tax` int(11) NOT NULL COMMENT "",
  `lo_commitdate` int(11) NOT NULL COMMENT "",
  `lo_shipmode` varchar(11) NOT NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(`lo_orderkey`)
COMMENT "OLAP"
PARTITION BY RANGE(`lo_orderdate`)
(
PARTITION p1 VALUES [("-2147483648"), ("19930101")),
PARTITION p2 VALUES [("19930101"), ("19940101")),
PARTITION p3 VALUES [("19940101"), ("19950101")),
PARTITION p4 VALUES [("19950101"), ("19960101")),
PARTITION p5 VALUES [("19960101"), ("19970101")),
PARTITION p6 VALUES [("19970101"), ("19980101")),
PARTITION p7 VALUES [("19980101"), ("19990101"))
)
DISTRIBUTED BY HASH(`lo_orderkey`) BUCKETS 48
PROPERTIES (
  "replication_num" = "1",
  "colocate_with" = "groupa1"
);

drop table if exists customer;
CREATE TABLE IF NOT EXISTS `customer` (
  `c_custkey` int(11) NOT NULL COMMENT "",
  `c_name` varchar(26) NOT NULL COMMENT "",
  `c_address` varchar(41) NOT NULL COMMENT "",
  `c_city` varchar(11) NOT NULL COMMENT "",
  `c_nation` varchar(16) NOT NULL COMMENT "",
  `c_region` varchar(13) NOT NULL COMMENT "",
  `c_phone` varchar(16) NOT NULL COMMENT "",
  `c_mktsegment` varchar(11) NOT NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(`c_custkey`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`c_custkey`) BUCKETS 12
PROPERTIES (
  "replication_num" = "1",
  "colocate_with" = "groupa2"
);

drop table if exists dates;
CREATE TABLE IF NOT EXISTS `dates` (
  `d_datekey` int(11) NOT NULL COMMENT "",
  `d_date` varchar(20) NOT NULL COMMENT "",
  `d_dayofweek` varchar(10) NOT NULL COMMENT "",
  `d_month` varchar(11) NOT NULL COMMENT "",
  `d_year` int(11) NOT NULL COMMENT "",
  `d_yearmonthnum` int(11) NOT NULL COMMENT "",
  `d_yearmonth` varchar(9) NOT NULL COMMENT "",
  `d_daynuminweek` int(11) NOT NULL COMMENT "",
  `d_daynuminmonth` int(11) NOT NULL COMMENT "",
  `d_daynuminyear` int(11) NOT NULL COMMENT "",
  `d_monthnuminyear` int(11) NOT NULL COMMENT "",
  `d_weeknuminyear` int(11) NOT NULL COMMENT "",
  `d_sellingseason` varchar(14) NOT NULL COMMENT "",
  `d_lastdayinweekfl` int(11) NOT NULL COMMENT "",
  `d_lastdayinmonthfl` int(11) NOT NULL COMMENT "",
  `d_holidayfl` int(11) NOT NULL COMMENT "",
  `d_weekdayfl` int(11) NOT NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(`d_datekey`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`d_datekey`) BUCKETS 1
PROPERTIES (
  "replication_num" = "1",
  "colocate_with" = "groupa3"
);

drop table if exists supplier;
CREATE TABLE IF NOT EXISTS `supplier` (
  `s_suppkey` int(11) NOT NULL COMMENT "",
  `s_name` varchar(26) NOT NULL COMMENT "",
  `s_address` varchar(26) NOT NULL COMMENT "",
  `s_city` varchar(11) NOT NULL COMMENT "",
  `s_nation` varchar(16) NOT NULL COMMENT "",
  `s_region` varchar(13) NOT NULL COMMENT "",
  `s_phone` varchar(16) NOT NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(`s_suppkey`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`s_suppkey`) BUCKETS 12
PROPERTIES (
  "replication_num" = "1",
  "colocate_with" = "groupa4"
);

drop table if exists part;
CREATE TABLE IF NOT EXISTS `part` (
  `p_partkey` int(11) NOT NULL COMMENT "",
  `p_name` varchar(23) NOT NULL COMMENT "",
  `p_mfgr` varchar(7) NOT NULL COMMENT "",
  `p_category` varchar(8) NOT NULL COMMENT "",
  `p_brand` varchar(10) NOT NULL COMMENT "",
  `p_color` varchar(12) NOT NULL COMMENT "",
  `p_type` varchar(26) NOT NULL COMMENT "",
  `p_size` int(11) NOT NULL COMMENT "",
  `p_container` varchar(11) NOT NULL COMMENT ""
) ENGINE=OLAP
DUPLICATE KEY(`p_partkey`)
COMMENT "OLAP"
DISTRIBUTED BY HASH(`p_partkey`) BUCKETS 12
PROPERTIES (
  "replication_num" = "1",
  "colocate_with" = "groupa5"
);


drop table if exists lineorder_flat;
CREATE TABLE IF NOT EXISTS `lineorder_flat` (
    `LO_ORDERDATE` int(11) NOT NULL COMMENT "",
    `LO_ORDERKEY` int(11) NOT NULL COMMENT "",
    `LO_LINENUMBER` tinyint(4) NOT NULL COMMENT "",
    `LO_CUSTKEY` int(11) NOT NULL COMMENT "",
    `LO_PARTKEY` int(11) NOT NULL COMMENT "",
    `LO_SUPPKEY` int(11) NOT NULL COMMENT "",
    `LO_ORDERPRIORITY` varchar(100) NOT NULL COMMENT "",
    `LO_SHIPPRIORITY` tinyint(4) NOT NULL COMMENT "",
    `LO_QUANTITY` tinyint(4) NOT NULL COMMENT "",
    `LO_EXTENDEDPRICE` int(11) NOT NULL COMMENT "",
    `LO_ORDTOTALPRICE` int(11) NOT NULL COMMENT "",
    `LO_DISCOUNT` tinyint(4) NOT NULL COMMENT "",
    `LO_REVENUE` int(11) NOT NULL COMMENT "",
    `LO_SUPPLYCOST` int(11) NOT NULL COMMENT "",
    `LO_TAX` tinyint(4) NOT NULL COMMENT "",
    `LO_COMMITDATE` date NOT NULL COMMENT "",
    `LO_SHIPMODE` varchar(100) NOT NULL COMMENT "",
    `C_NAME` varchar(100) NOT NULL COMMENT "",
    `C_ADDRESS` varchar(100) NOT NULL COMMENT "",
    `C_CITY` varchar(100) NOT NULL COMMENT "",
    `C_NATION` varchar(100) NOT NULL COMMENT "",
    `C_REGION` varchar(100) NOT NULL COMMENT "",
    `C_PHONE` varchar(100) NOT NULL COMMENT "",
    `C_MKTSEGMENT` varchar(100) NOT NULL COMMENT "",
    `S_NAME` varchar(100) NOT NULL COMMENT "",
    `S_ADDRESS` varchar(100) NOT NULL COMMENT "",
    `S_CITY` varchar(100) NOT NULL COMMENT "",
    `S_NATION` varchar(100) NOT NULL COMMENT "",
    `S_REGION` varchar(100) NOT NULL COMMENT "",
    `S_PHONE` varchar(100) NOT NULL COMMENT "",
    `P_NAME` varchar(100) NOT NULL COMMENT "",
    `P_MFGR` varchar(100) NOT NULL COMMENT "",
    `P_CATEGORY` varchar(100) NOT NULL COMMENT "",
    `P_BRAND` varchar(100) NOT NULL COMMENT "",
    `P_COLOR` varchar(100) NOT NULL COMMENT "",
    `P_TYPE` varchar(100) NOT NULL COMMENT "",
    `P_SIZE` tinyint(4) NOT NULL COMMENT "",
    `P_CONTAINER` varchar(100) NOT NULL COMMENT ""
    ) ENGINE=OLAP
    DUPLICATE KEY(`LO_ORDERDATE`, `LO_ORDERKEY`)
    COMMENT "OLAP"
    PARTITION BY RANGE(`LO_ORDERDATE`)
(
    PARTITION p1992 VALUES [("-2147483648"), ("19930101")),
    PARTITION p1993 VALUES [("19930101"), ("19940101")),
    PARTITION p1994 VALUES [("19940101"), ("19950101")),
    PARTITION p1995 VALUES [("19950101"), ("19960101")),
    PARTITION p1996 VALUES [("19960101"), ("19970101")),
    PARTITION p1997 VALUES [("19970101"), ("19980101")),
    PARTITION p1998 VALUES [("19980101"), ("19990101"))
)
DISTRIBUTED BY HASH(`LO_ORDERKEY`) BUCKETS 48
PROPERTIES (
   "replication_num" = "1",
   "colocate_with" = "groupxx1"
);