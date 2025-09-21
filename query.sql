-- DATA CLEANING

-- ORDER TABLE
-- Show 5 top rows 
SELECT * 
FROM olist_orders_dataset ood 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_orders_dataset'
ORDER BY ordinal_position;

-- Change an empty value to a null datatype before change to timestamp datatype
UPDATE olist_orders_dataset
SET order_approved_at = NULL
WHERE order_approved_at = '';

UPDATE olist_orders_dataset
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date = '';

UPDATE olist_orders_dataset
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date = '';

UPDATE olist_orders_dataset
SET order_estimated_delivery_date = NULL
WHERE order_estimated_delivery_date = '';

-- Convert string datatype to timestamp datatype in the date columns
ALTER TABLE olist_orders_dataset
    ALTER COLUMN order_approved_at TYPE timestamp
        USING order_approved_at::timestamp,
    ALTER COLUMN order_delivered_carrier_date TYPE timestamp
        USING order_delivered_carrier_date::timestamp,
    ALTER COLUMN order_delivered_customer_date TYPE timestamp
        USING order_delivered_customer_date::timestamp,
    ALTER COLUMN order_estimated_delivery_date TYPE timestamp
        USING order_estimated_delivery_date::timestamp;

-- Check duplicates values 
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_orders_dataset
) t;

-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_orders_dataset IS NULL) AS null_count
FROM olist_orders_dataset

-- Null values in each column
SELECT 
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS purchase_nulls,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_nulls,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_nulls,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS customer_nulls,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS estimated_nulls
FROM olist_orders_dataset;

-- Check values in categorical column (order_status)
SELECT
    DISTINCT order_status
FROM olist_orders_dataset ood ;


-- REVIEW TABLE
-- 5 top rows
SELECT *
FROM olist_order_reviews_dataset oord LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_order_reviews_dataset'
ORDER BY ordinal_position;

-- Check for the values is INT or NOT
SELECT review_score
FROM olist_order_reviews_dataset
WHERE review_score !~ '^[0-9]+$';

-- Change Datatype review_score column from text to int
ALTER TABLE olist_order_reviews_dataset 
ALTER COLUMN review_score TYPE INT
USING review_score::INT;

-- Datatype ID as varchar
ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_id TYPE VARCHAR(50);

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN order_id TYPE VARCHAR(50);

-- Check string values in column date
SELECT review_creation_date
FROM olist_order_reviews_dataset
WHERE review_creation_date IS NOT NULL
AND review_creation_date !~ '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$';

-- Change datatype in column date to datatype datetime/timestamp
ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_creation_date TYPE TIMESTAMP
USING review_creation_date::timestamp;

ALTER TABLE olist_order_reviews_dataset
ALTER COLUMN review_answer_timestamp TYPE TIMESTAMP
USING review_answer_timestamp::timestamp;

-- Check duplicates values from orders data
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_order_reviews_dataset oord 
) t;

-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_order_reviews_dataset IS NULL) AS null_count
FROM olist_order_reviews_dataset;

-- Check Null Values in each column
SELECT 
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_nulls,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS review_comment_title_nulls,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS review_comment_message_nulls,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS review_creation_date_nulls,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS review_answer_timestamp_nulls
FROM olist_order_reviews_dataset;

--TABLE ORDER ITEMS 
-- Show 5 top rows
SELECT *
FROM olist_order_items_dataset ooid 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_order_items_dataset'
ORDER BY ordinal_position;

-- Change datatype date
ALTER TABLE olist_order_items_dataset 
ALTER COLUMN shipping_limit_date
TYPE timestamp
USING shipping_limit_date::timestamp;

-- Check duplicate values
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_order_items_dataset ooid 
) t;


-- Check Null Values
SELECT
    count(*) FILTER (WHERE olist_order_items_dataset IS NULL) AS null_count
FROM olist_order_items_dataset;

SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS item_id_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS shipping_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_nulls
FROM olist_order_items_dataset;

-- TABLE PRODUCTS
-- Show 5 top rows
SELECT * 
FROM olist_products_dataset opd 
LIMIT 5;

-- Check Data Information
SELECT 
    column_name, 
    data_type, 
    character_maximum_length, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'olist_products_dataset'
ORDER BY ordinal_position;

-- Check duplicate values
SELECT COUNT(*) - COUNT(*) AS duplicate_count
FROM (
    SELECT DISTINCT *
    FROM olist_products_dataset opd 
) t;


-- EXPLORATORY DATA ANALYSIS

-- DELIVERY KPIS
-- Number by Delivery Status
SELECT
	order_status,
	count(*)
FROM olist_orders_dataset ood 
GROUP BY order_status

--OUTPUT
order_status|count|
------------+-----+
shipped     | 1107|
unavailable |  609|
invoiced    |  314|
created     |    5|
approved    |    2|
processing  |  301|
delivered   |96478|
canceled    |  625|


-- Delivered orders and non delivered
SELECT
    COUNT(*) FILTER (WHERE order_status = 'delivered') AS delivered,
    COUNT(*) FILTER (WHERE order_status <> 'delivered') AS non_delivered,
    ROUND(COUNT(*) FILTER (WHERE order_status = 'delivered') * 100.0 / COUNT(*), 2) AS perc_delivered,
    ROUND(COUNT(*) FILTER (WHERE order_status <> 'delivered') * 100.0 / COUNT(*), 2) AS perc_non_delivered
FROM olist_orders_dataset ood ;

-- On time and late delivery
SELECT
    COUNT(*) FILTER (WHERE order_delivered_customer_date::date <= order_delivered_carrier_date::date) AS on_time,
    COUNT(*) FILTER (WHERE order_delivered_customer_date::date > order_delivered_carrier_date::date)  AS late,
    ROUND(COUNT(*) FILTER (WHERE order_delivered_customer_date::date <= order_delivered_carrier_date::date) * 100.0 / COUNT(*), 2) AS perc_on_time,
    ROUND(COUNT(*) FILTER (WHERE order_delivered_customer_date::date > order_delivered_carrier_date::date) * 100.0 / COUNT(*), 2) AS perc_late
FROM olist_orders_dataset ood 
WHERE 
	order_delivered_customer_date IS NOT NULL AND 
	order_delivered_carrier_date IS NOT NULL;

-- Average Delivery Time
SELECT    
	ROUND(AVG(ood.order_delivered_customer_date::date - ood.order_delivered_carrier_date::date)
		FILTER(WHERE order_delivered_customer_date::date <= order_delivered_carrier_date::date), 2) AS avg_on_time_delivery_in_days,
	ROUND(AVG(ood.order_delivered_customer_date::date - ood.order_delivered_carrier_date::date)
		FILTER(WHERE order_delivered_customer_date::date > order_delivered_carrier_date::date), 2) AS avg_late_time_delivery_in_day
FROM olist_orders_dataset ood 
WHERE 
	order_delivered_customer_date IS NOT NULL AND 
	order_delivered_carrier_date IS NOT NULL;

-- Courier/Seller Performance Index
SELECT
    seller_id,
    ROUND(AVG(order_delivered_customer_date::date - order_delivered_carrier_date::date), 2) AS avg_delivery_time,
    ROUND(100.0 * SUM(CASE WHEN order_delivered_customer_date::date <= order_estimated_delivery_date::date THEN 1 ELSE 0 END) / COUNT(*), 2) AS otd_percent
FROM olist_orders_dataset ood  
JOIN olist_order_items_dataset ooid
ON ood.order_id = ooid.order_id
WHERE ood.order_status = 'delivered'
GROUP BY seller_id
ORDER BY otd_percent DESC;


-- PRODUCT QUALITY KPIS
-- Average Review Score: avg. rating customer by product/supplier.
SELECT
    pcnt.product_category_name AS product_name,
    pcnt.product_category_name_english AS product_english_name,
    ROUND(AVG(oord.review_score ), 2) AS avg
FROM olist_order_reviews_dataset oord 
JOIN olist_order_items_dataset ooid 
    USING(order_id)
JOIN olist_products_dataset opd 
    USING(product_id)
JOIN product_category_name_translation pcnt 
    USING(product_category_name)
GROUP BY product_name, product_english_name 
ORDER BY avg DESC 
LIMIT 10;


-- CUSTOMER LIFETIME VALUE 
-- Average Purchase Value (APV)
SELECT 
	customer_id,
	ROUND(AVG(payment_value::numeric), 2) AS avg_purchase_value
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY customer_id

-- Purchase Frequency (PF)
SELECT 
	customer_id,
	COUNT(order_id) AS total_orders
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	using(customer_id)
GROUP BY customer_id
ORDER BY total_orders desc
;

--Customer Lifespan (CL)
SELECT 
	ocd.customer_unique_id,
    DATE_PART('day', MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp))/365.0 AS lifespan_years
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	USING(customer_id)
GROUP BY customer_unique_id
ORDER BY lifespan_years DESC;

-- CLV per Customer
SELECT
	customer_unique_id,
	(AVG(payment_value::numeric) * COUNT(order_id)) *
	DATE_PART('day', MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp))/365.0 AS clv
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)
GROUP BY customer_unique_id
ORDER BY clv DESC;

-- create dataset for visualization 

-- Performance Delivery
WITH performance AS (
SELECT
	*
FROM olist_orders_dataset ood
JOIN olist_order_items_dataset ooid
	USING(order_id)
)
SELECT
	order_status,
	count(*)
FROM performance
GROUP BY order_status
;

--OUTPUT

order_status|count |
------------+------+
approved    |     3|
canceled    |   542|
delivered   |110197|
invoiced    |   359|
processing  |   357|
shipped     |  1185|
unavailable |     7|
	

-- Product Quality
SELECT	
	opd.product_category_name,
	pcnt.product_category_name_english,
	oord.review_score 
FROM olist_order_reviews_dataset oord 
JOIN olist_order_items_dataset ooid 
    USING(order_id)
JOIN olist_products_dataset opd 
    USING(product_id)
JOIN product_category_name_translation pcnt 
    USING(product_category_name);

-- CLV
SELECT
	order_id,
	customer_id,
	ocd.customer_unique_id,
	ood.order_purchase_timestamp,
	oopd.payment_value 
FROM olist_customers_dataset ocd 
JOIN olist_orders_dataset ood 
	USING(customer_id)
JOIN olist_order_payments_dataset oopd 
	USING(order_id)












