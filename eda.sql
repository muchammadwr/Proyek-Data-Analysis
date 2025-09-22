-- EXPLORATORY DATA ANALYSIS

-- DELIVERY KPIS
-- Number by Delivery Status
SELECT
	order_status,
	count(*)
FROM olist_orders_dataset ood 
GROUP BY order_status;

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
FROM olist_orders_dataset ood;

delivered|non_delivered|perc_delivered|perc_non_delivered|
---------+-------------+--------------+------------------+
    96478|         2963|         97.02|              2.98|

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

on_time|late |perc_on_time|perc_late|
-------+-----+------------+---------+
    325|96150|        0.34|    99.66|
    
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

avg_on_time_delivery_in_days|avg_late_time_delivery_in_day|
----------------------------+-----------------------------+
                       -0.24|                         9.31|

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
ORDER BY otd_percent DESC
LIMIT 10;

seller_id                       |avg_delivery_time|otd_percent|
--------------------------------+-----------------+-----------+
6d2f2e3b539480db1e0842b3a4e32e6e|             1.83|     100.00|
a61cc04793308395a840807104365121|             7.00|     100.00|
f9ec7093df3a7b346b7bcf7864069ca3|             4.67|     100.00|
fc38b5dceee1a730fad8853453437fbd|             4.40|     100.00|
5def4c3732941a971cba8fdee992ede1|             3.33|     100.00|
c53bcd3be457a342a97e39e5a9f0be22|             9.20|     100.00|
ea65d8b58316a6f2362f2a9e4b3e86ad|             7.63|     100.00|
a45765f8afb1e594b22bf9e974b46765|             4.00|     100.00|
be67f78487e2cecb0d55bc769709e4f5|             7.00|     100.00|
c113b8df1fc375bc3d73d29c1b1144d1|             5.60|     100.00|

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
GROUP BY customer_id;

product_name                      |product_english_name                 |avg |
----------------------------------+-------------------------------------+----+
cds_dvds_musicais                 |cds_dvds_musicals                    |4.64|
fashion_roupa_infanto_juvenil     |fashion_childrens_clothes            |4.50|
livros_interesse_geral            |books_general_interest               |4.45|
construcao_ferramentas_ferramentas|costruction_tools_tools              |4.44|
flores                            |flowers                              |4.42|
livros_importados                 |books_imported                       |4.40|
livros_tecnicos                   |books_technical                      |4.37|
alimentos_bebidas                 |food_drink                           |4.32|
malas_acessorios                  |luggage_accessories                  |4.32|
portateis_casa_forno_e_cafe       |small_appliances_home_oven_and_coffee|4.30|

-- Purchase Frequency (PF)
SELECT 
	customer_id,
	COUNT(order_id) AS total_orders
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	using(customer_id)
GROUP BY customer_id
ORDER BY total_orders DESC;

customer_id                     |total_orders|
--------------------------------+------------+
000161a058600d5901f007fab4c27140|           1|
0001fd6190edaaf884bcaf3d49edf079|           1|
0002414f95344307404f0ace7a26f1d5|           1|
000379cdec625522490c315e70c7a9fb|           1|
0004164d20a9e969af783496f3408652|           1|
000419c5494106c306a97b5635748086|           1|
00046a560d407e99b969756e0b10f282|           1|
00050bf6e01e69d5c0fd612f1bcfb69c|           1|
000598caf2ef4117407665ac33275130|           1|
00012a2ce6f8dcda20d059ce98491703|           1|

--Customer Lifespan (CL)
SELECT 
	ocd.customer_unique_id,
    DATE_PART('day', MAX(order_purchase_timestamp) - MIN(order_purchase_timestamp))/365.0 AS lifespan_years
FROM olist_orders_dataset ood 
JOIN olist_customers_dataset ocd 
	USING(customer_id)
GROUP BY customer_unique_id
ORDER BY lifespan_years DESC;

customer_unique_id              |lifespan_years    |
--------------------------------+------------------+
32ea3bdedab835c3aa6cb68ce66565ef|1.7342465753424658|
ccafc1c3f270410521c3c6f3b249870f|1.6657534246575343|
d8f3c4f441a9b59a29f977df16724f38|1.5945205479452054|
94e5ea5a8c1bf546db2739673060c43f|1.5890410958904109|
87b3f231705783eb2217e25851c0a45d|1.5671232876712329|
8f6ce2295bdbec03cd50e34b4bd7ba0a|1.4712328767123288|
30b782a79466007756f170cb5bd6bbd8|1.4383561643835616|
4e23e1826902ec9f208e8cc61329b494|1.4356164383561645|
a1c61f8566347ec44ea37d22854634a1|1.4356164383561645|
a262442e3ab89611b44877c7aaf77468|1.4273972602739726|
5eefb861d4921a3e628bbc65c50a480a|1.4164383561643836|
18bc87094128bbfe943cf88adcf72059|1.4082191780821918|
7e7301841ddb4064c2f3a31e4c154932|1.4082191780821918|

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

customer_unique_id              |clv               |
--------------------------------+------------------+
4facc2e6fbc2bffab2fea92d2b4aa7e4|2026.0684931506848|
cef29e793e232d30250331804cdb7000|1645.4909589041097|
59d66d72939bc9497e19d89c61a96d5f|1570.2969589041097|
1da09dd64e235e7c2f29a4faff33535c|1452.8164383561643|
dc813062e0fc23409cd255f7f53c7074|1250.5772876712329|
423d40b193638955a782839886648464|1239.0064657534247|
d132b863416f85f2abb1a988ca05dd12|1192.5844383561644|
8d50f5eadf50201ccdcedfb9e2ac8455| 1171.609397260274|
fe81bb32c243a86b2f86fbf053fe6140|1054.6956712328767|
345759b8cb3d30586551de1ca6905df0|1006.9308493150684|
b9badb100ff8ecc16a403111209e3a06| 978.3015342465753|
12d8b5ed661190a3a08183644dfc504d| 942.5697260273973|
4e1cce07cd5937c69dacac3c8b13d965| 876.0717808219176|
8c21dd8c37144807c601f99f2a209dfb| 871.2534246575342|
63cfc61cee11cbe306bff5857d00bfe4| 864.8061369863013|
cecc19ff12c206e6368dd1e9c22a848d| 857.6894246575342|
da8ac849037c7201a41a4db0b1fa963e| 847.6130136986301|

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
	COUNT(DISTINCT order_id) AS unique_orders
FROM performance
GROUP BY order_status
;

order_status|unique_orders|
------------+-------------+
approved    |            2|
canceled    |          461|
delivered   |        96478|
invoiced    |          312|
processing  |          301|
shipped     |         1106|
unavailable |            6|

WITH performance AS (
SELECT
	*
FROM olist_orders_dataset ood
JOIN olist_order_items_dataset ooid
	USING(order_id)
)
SELECT
	order_status,
	COUNT(*) AS count
FROM performance
GROUP BY order_status
;

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

product_category_name            |product_category_name_english  |review_score|
---------------------------------+-------------------------------+------------+
informatica_acessorios           |computers_accessories          |           5|
informatica_acessorios           |computers_accessories          |           5|
esporte_lazer                    |sports_leisure                 |           5|
cama_mesa_banho                  |bed_bath_table                 |           1|
cama_mesa_banho                  |bed_bath_table                 |           1|
cama_mesa_banho                  |bed_bath_table                 |           1|
cama_mesa_banho                  |bed_bath_table                 |           1|
cama_mesa_banho                  |bed_bath_table                 |           5|
brinquedos                       |toys                           |           5|
eletroportateis                  |small_appliances               |           4|
beleza_saude                     |health_beauty                  |           4|
beleza_saude                     |health_beauty                  |           4|
pet_shop                         |pet_shop                       |           3|
pet_shop                         |pet_shop                       |           3|
eletronicos                      |electronics                    |           5|
malas_acessorios                 |luggage_accessories            |           1|
utilidades_domesticas            |housewares                     |           4|

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
	USING(order_id);

order_id                        |customer_id                     |customer_unique_id              |order_purchase_timestamp|payment_value|
--------------------------------+--------------------------------+--------------------------------+------------------------+-------------+
b81ef226f3fe1789b1e8b2acac839d17|0a8556ac6be836b46b3e89920d59291c|708ab75d2a007f0564aedd11139c7708| 2018-04-25 22:01:49.000|        99.33|
a9810da82917af2d9aefd1278f1dcfa0|f2c7fc58a9de810828715166c672f10a|a8b9d3a27068454b1c98cc67d4e31e6f| 2018-06-26 11:01:38.000|        24.39|
3d7239c394a212faae122962df514ac7|4d7a9b8bba459dce09d1b8fa637a0cba|9db67268a3fee1d4b13faaeb90af07c0| 2017-06-05 10:45:54.000|        51.84|
2480f727e869fdeb397244a21b721b67|94967f1e8a9ea8ec6c7129f098f32155|2faf4a1d502b10555a9f39353ea20148| 2017-12-13 18:51:45.000|        141.9|
12e5cfe0e4716b59afb0e0f4a3bd6570|041cd6848abb3d3ca45e83dc971488fd|0ae522661311f598df20272643d39ce6| 2018-03-22 09:46:07.000|       157.45|
61059985a6fc0ad64e95d9944caacdad|89bca1b7e71b59a7d206d9d1da65c1f6|3129dce5dc566246ea1354bff5bb6fea| 2018-08-13 15:43:16.000|       132.04|
8ac09207f415d55acff302df7d6a895c|2d8bf5f6862af587af2e0b085a04bf0d|501598d5821539430a35385474cd44d9| 2018-01-29 14:50:01.000|       244.15|
5a1f6d22f7dfb061ef29216b9af687a1|4c7ef01bf8ed05e43a5e9e44bb08358e|5986b5f70bf08b414d16a93ac5b1d76c| 2017-09-01 23:13:57.000|        47.69|
8cd68144cdb62dc0d60848cf8616d2a4|c03b40c7971bc52b3d018247891270c5|d0c437f172b9c527c0d196815b92c5ce| 2017-08-04 10:08:27.000|       330.66|
d0a945f85ba1074b60aac97ade7e240e|4a44c8f258b8780e1da133c1f1c39854|d132b863416f85f2abb1a988ca05dd12| 2018-04-30 20:24:53.000|        541.0|
c39414c195d0f94c9d9c35e7c6ed4f1a|0dac2ac6dcbbda827846734c0dc2dde6|53829feb906370f277393325399b8487| 2018-08-01 11:57:29.000|       139.22|
5d9c5817e278892b7498d90bfa28ade8|b583a7efe4522c8ce8942bd47f33d487|67a7e94ec59ef6d6ba83942c81d39b9a| 2018-04-26 08:13:54.000|       290.16|
b69b9260e79a0da00e15f48de1bd2524|0b34456a261dcc179512d6652e8cb276|e9dc392ca45bbd1c3faf921ccd7ebbd1| 2017-05-31 16:27:58.000|       283.34|












