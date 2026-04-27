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