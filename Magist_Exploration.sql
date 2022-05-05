USE magist;

# 1. How many orders are there in the dataset?
SELECT COUNT(*) As num_orders
FROM orders;

# 2. Are orders actually delivered? 
SELECT order_status, COUNT(*) AS num_orders
FROM orders
GROUP BY order_status;

# 3. Is Magist having user growth?                            
SELECT YEAR(order_purchase_timestamp) AS year, MONTH(order_purchase_timestamp) AS month, COUNT(*)
FROM orders
GROUP BY year, month
ORDER BY year, month;

# 4. How many products are there in the products table?
SELECT DISTINCT COUNT(*) AS product_count
FROM products;

# 5. Which are the categories with most products?
SELECT DISTINCT product_category_name, COUNT(*)
FROM products
GROUP BY product_category_name
ORDER BY COUNT(*) DESC;
																						  
SELECT DISTINCT products.product_category_name, prod_trans.product_category_name_english, COUNT(*)
FROM products
LEFT JOIN product_category_name_translation AS prod_trans
ON products.product_category_name = prod_trans.product_category_name
GROUP BY prod_trans.product_category_name_english, products.product_category_name
ORDER BY COUNT(*) DESC;

# 6. How many of those products were present in actual transactions?
SELECT COUNT(DISTINCT product_id) AS num_product
FROM order_items;

# 7. What’s the price for the most expensive and cheapest products?
SELECT products.product_category_name, prod_trans.product_category_name_english, MAX(price)
FROM order_items
LEFT JOIN products
ON order_items.product_id = products.product_id
LEFT JOIN product_category_name_translation AS prod_trans
ON products.product_category_name = prod_trans.product_category_name
GROUP BY products.product_category_name, prod_trans.product_category_name_english
ORDER BY MAX(price) DESC;

SELECT MIN(price)
FROM order_items;

# 8. What are the highest and lowest payment values?
SELECT MAX(payment_value), MIN(payment_value)
FROM order_payments;












