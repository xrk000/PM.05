WITH latest_prices AS (
    SELECT DISTINCT ON (nomenclat_id) 
        nomenclat_id,
        price
    FROM prices
    ORDER BY nomenclat_id, date DESC
),
product_material_cost AS (
    SELECT 
        s.product_id,
        SUM(si.quantity * lp.price) AS material_cost_per_unit
    FROM specifications s
    JOIN specification_items si ON s.id = si.specification_id
    JOIN latest_prices lp ON si.material_id = lp.nomenclat_id
    GROUP BY s.product_id
)
SELECT 
    o.id AS order_id,
    o.number AS order_number,
    o.date AS order_date,
    SUM(oi.quantity * COALESCE(pmc.material_cost_per_unit, 0)) AS total_material_cost
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN product_material_cost pmc ON oi.product_id = pmc.product_id
GROUP BY o.id, o.number, o.date
ORDER BY o.id;