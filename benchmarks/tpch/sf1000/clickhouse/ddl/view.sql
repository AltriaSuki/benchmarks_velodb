CREATE OR REPLACE  VIEW revenue0 (supplier_no, total_revenue) AS
SELECT
    l_suppkey,
    sum(l_extendedprice * (1 - l_discount))
FROM
    lineitem
WHERE
        l_shipdate >= DATE '1996-01-01'
  AND l_shipdate < DATE '1996-01-01' + INTERVAL '3' MONTH
GROUP BY
    l_suppkey;