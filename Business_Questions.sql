USE magist;

/* In relation to the products:
What categories of tech products does Magist have?
How many products of these tech categories have been sold (within the time window of the database snapshot)?
What percentage does that represent from the overall number of products sold?
What’s the average price of the products being sold?
Are expensive tech products popular? */

SELECT product_category_name, COUNT(*)
FROM products
WHERE product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY product_category_name;


SELECT products.product_category_name, COUNT(order_items.product_id) AS num_items
FROM order_items
INNER JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY products.product_category_name;

SELECT SUM(num_items)
FROM (
	SELECT products.product_category_name, COUNT(*) AS num_items
	FROM order_items
I	INNER JOIN products
	ON order_items.product_id = products.product_id
	WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
	"pc_gamer", "pcs")
	GROUP BY products.product_category_name
) AS tech_sales;

SELECT COUNT(product_id)
FROM order_items;


SELECT products.product_category_name, ROUND(AVG(order_items.price), 2)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY products.product_category_name;


SELECT products.product_category_name, order_items.price,
	CASE
		WHEN price <= 100 THEN "very cheap"
        WHEN price <= 300 THEN "cheap"
        WHEN price <= 1000 THEN "moderate"
        WHEN price > 1000 THEN "expensive"
        END AS price_category        
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
ORDER BY order_items.price DESC;

SELECT COUNT(*)
FROM (
SELECT products.product_category_name, order_items.price,
	CASE
		WHEN price <= 100 THEN "very cheap"
        WHEN price <= 300 THEN "cheap"
        WHEN price <= 1000 THEN "moderate"
        WHEN price > 1000 THEN "expensive"
        END AS price_category        
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
ORDER BY order_items.price
) AS sales_table
WHERE price_category = "expensive";

SELECT COUNT(*)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs");

SELECT products.product_category_name, COUNT(order_items.price)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
AND order_items.price > 1000
GROUP BY products.product_category_name;

/* In relation to the sellers:
How many sellers are there?
What’s the average monthly revenue of Magist’s sellers?
What’s the average revenue of sellers that sell tech products? */
SELECT COUNT(*)
FROM sellers;


SELECT seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT sellers.seller_id, YEAR(order_items.shipping_limit_date) AS year,
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM sellers
LEFT JOIN order_items
ON sellers.seller_id = order_items.seller_id
GROUP BY sellers.seller_id, year, month
ORDER BY year, month
) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC;


SELECT seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT sellers.seller_id, YEAR(order_items.shipping_limit_date) AS year,
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM sellers
LEFT JOIN order_items
ON sellers.seller_id = order_items.seller_id
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "electronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY sellers.seller_id, year, month
ORDER BY year, month
) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC;

/* In relation to the delivery time:
What’s the average time between the order being placed and the product being delivered?
How many orders are delivered on time vs orders delivered with a delay?
Is there any pattern for delayed orders, e.g. big products being delayed more often? */
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_del_time
FROM orders;

SELECT order_id, order_status, order_delivered_customer_date, order_estimated_delivery_date
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0;

SELECT COUNT(*)
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) <= 0;

SELECT order_id, order_status, order_delivered_customer_date, order_estimated_delivery_date
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0;

SELECT COUNT(*)
FROM orders
WHERE order_status = "delivered"
AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0;


SELECT orders.order_id, order_payments.payment_value AS amount
FROM orders
LEFT JOIN order_payments
ON orders.order_id = order_payments.order_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) <= 0
ORDER BY amount DESC;

SELECT orders.order_id, order_payments.payment_value AS amount
FROM orders
LEFT JOIN order_payments
ON orders.order_id = order_payments.order_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0
ORDER BY amount DESC;

SELECT AVG(order_payments.payment_value) AS avg_amount
FROM orders
LEFT JOIN order_payments
ON orders.order_id = order_payments.order_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) <= 0;

SELECT AVG(order_payments.payment_value) AS avg_amount
FROM orders
LEFT JOIN order_payments
ON orders.order_id = order_payments.order_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0



















    
    






