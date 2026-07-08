SELECT 
CASE 
    WHEN ROUND(100 * revenue :: DECIMAL / summary_revenue, 2) >= 0.5 THEN name 
    ELSE 'ДРУГОЕ'
END AS product_name, 
SUM(revenue) AS revenue,
SUM(ROUND(100 * revenue :: DECIMAL / summary_revenue, 2)) AS share_in_revenue
FROM (SELECT DISTINCT t1.product_id, name, 
SUM(price) OVER (PARTITION BY t1.product_id) AS revenue,
SUM(price) OVER () AS summary_revenue FROM
(SELECT creation_time :: DATE AS date, order_id, UNNEST(product_ids) AS product_id FROM orders
WHERE order_id NOT IN (SELECT order_id FROM user_actions WHERE action = 'cancel_order')) t1
LEFT JOIN products 
ON t1.product_id = products.product_id) t2
GROUP BY product_name
ORDER BY revenue DESC
