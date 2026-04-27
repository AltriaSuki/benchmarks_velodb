-- TPC-H Q15 requires creating a revenue view, querying it, then dropping it.
-- The benchmark runner executes each query file in a fresh psql session, so the
-- view must be created/dropped within this same script.
DROP VIEW IF EXISTS revenue0;
CREATE VIEW revenue0 (supplier_no, total_revenue) AS
SELECT
    l_suppkey AS supplier_no,
    SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM
    lineitem
WHERE
    l_shipdate >= DATE '1996-01-01'
    AND l_shipdate < DATE '1996-01-01' + INTERVAL '3 months'
GROUP BY
    l_suppkey;

SELECT
    s_suppkey,
    s_name,
    s_address,
    s_phone,
    total_revenue
FROM
    supplier,
    revenue0
WHERE
        s_suppkey = supplier_no
  AND total_revenue = (
    SELECT
        max(total_revenue)
    FROM
        revenue0
)
ORDER BY
    s_suppkey;

DROP VIEW IF EXISTS revenue0;
