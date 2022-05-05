USE magist;

# In relation to the products:

# What categories of tech products does Magist have?
SELECT product_category_name, COUNT(*)
FROM products
WHERE product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY product_category_name
ORDER BY COUNT(*) DESC;

SELECT COUNT(product_id)
FROM products;

# How many products of these tech categories have been sold (within the time window of the database snapshot)?
# What percentage does that represent from the overall number of products sold?
SELECT products.product_category_name, COUNT(order_items.product_id) AS num_items_sold
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY products.product_category_name
ORDER BY COUNT(order_items.product_id) DESC;

SELECT SUM(num_items_sold)
FROM (
	SELECT products.product_category_name, COUNT(*) AS num_items_sold
	FROM order_items
	LEFT JOIN products
	ON order_items.product_id = products.product_id
	WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
	GROUP BY products.product_category_name
) AS tech_sales;

SELECT COUNT(product_id)
FROM order_items;

# What’s the average price of the products being sold?
SELECT products.product_category_name, ROUND(AVG(order_items.price), 2)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY products.product_category_name;

# Are expensive tech products popular?
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
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
ORDER BY order_items.price DESC;

SELECT price_category, COUNT(*)
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
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
    "pc_gamer", "pcs", "tablets_impressao_imagem")
ORDER BY order_items.price
) AS sales_table
GROUP BY price_category
ORDER BY COUNT(*) DESC;

SELECT COUNT(order_items.price)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
AND order_items.price > 1000;


# In relation to the sellers:

# How many sellers are there?
SELECT DISTINCT COUNT(*)
FROM sellers;

# What’s the average monthly revenue of Magist’s sellers?
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

SELECT ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT order_items.seller_id, YEAR(order_items.shipping_limit_date) AS year, 
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM order_items
GROUP BY seller_id, year, month
) AS avg_monthly_rev;

# What’s the average revenue of sellers that sell tech products?
SELECT seller_id, ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT sellers.seller_id, YEAR(order_items.shipping_limit_date) AS year,
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM sellers
LEFT JOIN order_items
ON sellers.seller_id = order_items.seller_id
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY sellers.seller_id, year, month
ORDER BY year, month
) AS monthly_rev
GROUP BY seller_id
ORDER BY avg_rev DESC;

SELECT ROUND(AVG(total_rev), 2) AS avg_rev
FROM (
SELECT order_items.seller_id, YEAR(order_items.shipping_limit_date) AS year, 
MONTH(order_items.shipping_limit_date) AS month, ROUND(SUM(order_items.price), 2) AS total_rev
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs", "tablets_impressao_imagem")
GROUP BY seller_id, year, month
) AS avg_monthly_rev;


# In relation to the delivery time:

# What’s the average time between the order being placed and the product being delivered?
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_del_time
FROM orders;

# How many orders are delivered on time vs orders delivered with a delay?
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

# Is there any pattern for delayed orders, e.g. big products being delayed more often?
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
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0;

SELECT products.product_category_name, ROUND(AVG(order_items.price), 2) AS avg_price
FROM orders
LEFT JOIN order_items
ON orders.order_id = order_items.order_id
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) <= 0
AND products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY products.product_category_name;

SELECT products.product_category_name, ROUND(AVG(order_items.price), 2) AS avg_price
FROM orders
LEFT JOIN order_items
ON orders.order_id = order_items.order_id
LEFT JOIN products
ON order_items.product_id = products.product_id
WHERE orders.order_status = "delivered"
AND DATEDIFF(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0
AND products.product_category_name IN ("audio", "consoles_games", "eletronicos", "informatica_acessorios",
"pc_gamer", "pcs")
GROUP BY products.product_category_name;
























    
    






