WITH AvgQuantity AS (
    SELECT
        l_partkey,
        AVG(l_quantity) * 0.2 AS avg_quantity
    FROM
        lineitem
    GROUP BY
        l_partkey
)
SELECT
        SUM(l.l_extendedprice) / 7.0 AS avg_yearly
FROM
    lineitem l
        JOIN
    part p ON p.p_partkey = l.l_partkey
        JOIN
    AvgQuantity aq ON l.l_partkey = aq.l_partkey
WHERE
        p.p_brand = 'Brand#23'
  AND p.p_container = 'MED BOX'
  AND l.l_quantity < aq.avg_quantity;
