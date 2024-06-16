SELECT COLUMN_NAME, DATA_TYPE  
FROM scaler-dsml-tushar-sql.BUSCASE1.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='customers';


SELECT MIN(order_purchase_timestamp) as Inidate, 
  MAX(order_purchase_timestamp) as lastdate
FROM  `BUSCASE1.orders`


#Solution 1.1 :  Table(s): ‘customers’ Query/Code: 

SELECT COLUMN_NAME, DATA_TYPE  
FROM scaler-dsml-tushar-sql.BUSCASE1.INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME='customers';

#Solution 1.2: Table(s): ‘orders’ Query/Code:

SELECT min(order_purchase_timestamp) as Inidate, 
max(order_purchase_timestamp) as lastdate
FROM `BUSCASE1.orders`

#Solution 1.3: Tables: ‘orders’ and ‘customers’ as have requisite columns Joint ID: customer_id Query/Code:

SELECT 
  COUNT(DISTINCT a.customer_city) AS City_Nos, 
  COUNT(DISTINCT a.customer_state) AS State_Nos, 
  COUNT(DISTINCT b.customer_id) as Cutomer_Nos,
  COUNT(DISTINCT b.order_id) as Order_Nos
FROM  `BUSCASE1.customers` a, `BUSCASE1.orders` b 
WHERE a.customer_id = b.customer_id 


SELECT b.customer_city, b.customer_state, COUNT(a.order_id) as orders 
FROM `BUSCASE1.orders` a,`BUSCASE1.customers` b 
WHERE a.customer_id = b.customer_id 
GROUP BY 1, 2 
ORDER BY 3 DESC
LIMIT 10;

#Solution 2.1: Tables: ‘orders’ Query/Code:

SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS Years,
  EXTRACT(MONTH FROM order_purchase_timestamp) AS Months, 
  COUNT(order_id) AS orders
FROM `BUSCASE1.orders`
GROUP BY 1,2
ORDER BY 1 desc,2 desc
LIMIT 10;

#Solution 2.2: Table(s): orders Query/Code:

SELECT  EXTRACT(MONTH FROM order_purchase_timestamp) AS Months, 
  COUNT(order_id) AS orders
FROM `BUSCASE1.orders`
GROUP BY 1
ORDER BY 1

 
#Query/Code:

WITH ONE AS
(SELECT EXTRACT(YEAR FROM order_purchase_timestamp) AS Years,
  EXTRACT(MONTH FROM order_purchase_timestamp) AS Months, 
  COUNT(order_id) AS orders
FROM `BUSCASE1.orders`
GROUP BY 1,2
ORDER BY 1 desc,2 desc)

SELECT  
  Months,
  SUM(IF(Years < 2017, orders,0)) as Y_2016,
  SUM(IF(Years = 2017, orders,0)) as Y_2017,
  SUM(IF(Years > 2017, orders,0)) as Y_2018,
  SUM(orders) as total_orders 
FROM ONE
GROUP BY 1
ORDER BY 1;

#Solution 2.3: Third Quarter of the day i.e. Afternoon :13-18 hrs  Table(s): orders Query/Code:

SELECT 
  CASE 
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 0 AND 5 THEN '1-Dawn' 
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 6 AND 11 THEN '2-Morning' 
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 12 AND 17 THEN '3-Afternoon' 
    WHEN EXTRACT(HOUR FROM order_purchase_timestamp) BETWEEN 18 AND 23 THEN '4-Night' END AS hour, 
    COUNT(order_id) AS order_count 
FROM
`BUSCASE1.orders` 
GROUP BY 1
ORDER BY 2  DESC;


#Solution 3.1:  Table(s): ‘orders’  and ‘customers’ Joint ID: ‘customer_id’ Query/Code:

SELECT a.customer_state, 
  EXTRACT(MONTH FROM b.order_purchase_timestamp) AS Months,
  COUNT(order_id) AS order_count 
FROM `BUSCASE1.customers` a,`BUSCASE1.orders` b 
WHERE a.customer_id = b.customer_id 
GROUP BY 1,2 
ORDER BY 3 DESC ,2
LIMIT 10;

#Solution 3.2:  Table(s):  ‘customers’ Query/Code:

SELECT customer_state, 
  COUNT(customer_id) AS customer_nos 
  FROM `BUSCASE1.customers`  
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 10;


#Solution 4.1:  Table(s):  ‘orders’ Query/Code:


WITH ONE AS 
(SELECT order_id,
  EXTRACT(YEAR FROM order_purchase_timestamp) AS Years, 
  EXTRACT(MONTH FROM order_purchase_timestamp) AS Months 
FROM `BUSCASE1.orders` 
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) IN (2017, 2018) 
AND EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8 
ORDER BY 3,2)

SELECT 
ROUND(SUM(IF(a.Years = 2018 AND Months BETWEEN 1 AND 8, b.payment_value,null)),2) as Y_2018,
ROUND(SUM(IF(a.Years = 2017 AND Months BETWEEN 1 AND 8, b.payment_value,null)),2) as Y_2017,
      ROUND((
        (SUM(IF(a.Years = 2018 AND a.Months BETWEEN 1 AND 8, b.payment_value,null))/
        SUM(IF(a.Years = 2017 AND a.Months BETWEEN 1 AND 8, b.payment_value,null))) - 1 )* 100,2) AS Percentage_change
FROM ONE a
INNER JOIN `BUSCASE1.payments` b
ON a.order_id=b.order_id


WITH ONE AS 
(SELECT order_id,
  EXTRACT(YEAR FROM order_purchase_timestamp) AS Years, 
  EXTRACT(MONTH FROM order_purchase_timestamp) AS Months 
FROM `BUSCASE1.orders` 
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) IN (2017, 2018) 
AND EXTRACT(MONTH FROM order_purchase_timestamp) BETWEEN 1 AND 8 
ORDER BY 3,2)

SELECT a.Months,
ROUND(SUM(IF(a.Years = 2018 AND Months BETWEEN 1 AND 8, b.payment_value,null)),2) as Y_2018,
ROUND(SUM(IF(a.Years = 2017 AND Months BETWEEN 1 AND 8, b.payment_value,null)),2) as Y_2017,
      ROUND((
        (SUM(IF(a.Years = 2018 AND a.Months BETWEEN 1 AND 8, b.payment_value,null))/
        SUM(IF(a.Years = 2017 AND a.Months BETWEEN 1 AND 8, b.payment_value,null))) - 1 )* 100,2) AS Percentage_change
FROM ONE a
INNER JOIN `BUSCASE1.payments` b
ON a.order_id=b.order_id
GROUP BY 1
ORDER BY 1

#Solution 4.2: Table(s):  ‘customers’, ‘orders’ and ‘order_item’ Joint ID: ‘cutomer_id’ and ‘order_id’ Query/Code: 

SELECT a.customer_state, 
  ROUND(AVG(c.price), 2) AS avg_value_of_price, 
  ROUND(SUM(c.price), 2) AS total_value_of_price,
FROM `BUSCASE1.customers` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.customer_id = b.customer_id
INNER JOIN `BUSCASE1.order_items` c 
ON b.order_id = c.order_id 
GROUP BY 1
ORDER BY 3 desc,2 desc
LIMIT 10;

#Solution 4.3: Table(s):  ‘customers’, ‘orders’ and ‘order_item’ Joint ID: ‘cutomer_id’ and ‘order_id’ Query/Code: 


SELECT a.customer_state, 
  ROUND(AVG(c.freight_value), 2) AS avg_freight_value, 
  ROUND(SUM(c.freight_value), 2) AS total_freight_value,
FROM `BUSCASE1.customers` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.customer_id = b.customer_id
INNER JOIN `BUSCASE1.order_items` c 
ON b.order_id = c.order_id 
GROUP BY 1
ORDER BY 3 desc,2 desc
LIMIT 10;

# Solution 5.1

SELECT order_id,order_purchase_timestamp,order_estimated_delivery_date, order_delivered_customer_date,
DATE_DIFF(order_delivered_customer_date,order_purchase_timestamp, Day) AS time_to_deliver,
DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, Day) AS diff_estimated_delivery 
FROM `BUSCASE1.orders` 
WHERE order_status ='delivered'
ORDER BY 5 DESC,6 DESC
LIMIT 10


SELECT order_id,
  DATE_DIFF(order_delivered_customer_date,order_purchase_timestamp, Day) AS time_to_deliver,
  DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, Day) AS diff_estimated_delivery 
FROM `BUSCASE1.orders` 
WHERE order_status ='delivered'
ORDER BY 2 DESC,3 DESC
LIMIT 10

# Solution 5.2

WITH ONE AS
(SELECT a.customer_state,
  ROUND(AVG(c.freight_value), 2) AS avg_freight_value
FROM `BUSCASE1.customers` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.customer_id = b.customer_id
INNER JOIN `BUSCASE1.order_items` c 
ON b.order_id = c.order_id 
GROUP BY 1),
TWO AS
(SELECT MAX('Highiest')OVER() AS TOP_5,
  DENSE_RANK()OVER(ORDER BY avg_freight_value DESC) as top_rank,
  customer_state, avg_freight_value
FROM ONE
ORDER BY top_rank   
LIMIT 5),
THREE AS 
(SELECT MAX('Lowest')OVER() AS TOP_5,
  DENSE_RANK()OVER(ORDER BY avg_freight_value) as top_rank,
  customer_state, avg_freight_value
FROM ONE
ORDER BY top_rank   
LIMIT 5)

SELECT * FROM TWO
UNION DISTINCT
SELECT * FROM THREE


# Solution 5.3

WITH ONE AS
(SELECT a.customer_state,
  ROUND(AVG(DATE_DIFF(order_delivered_customer_date,order_purchase_timestamp, Day)),2) AS Avg_delivery_time
FROM `BUSCASE1.customers` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.customer_id = b.customer_id
GROUP BY 1),
TWO AS
(SELECT MAX('Highiest')OVER() AS TOP_5,
  DENSE_RANK()OVER(ORDER BY Avg_delivery_time DESC) as top_rank,
  customer_state, Avg_delivery_time
FROM ONE
ORDER BY top_rank   
LIMIT 5),
THREE AS 
(SELECT MAX('Lowest')OVER() AS TOP_5,
  DENSE_RANK()OVER(ORDER BY Avg_delivery_time) as top_rank,
  customer_state, Avg_delivery_time
FROM ONE
ORDER BY top_rank   
LIMIT 5)

SELECT * FROM TWO
UNION DISTINCT
SELECT * FROM THREE


# Solution 5.4


SELECT a.customer_state,
  ROUND(AVG(DATE_DIFF(order_estimated_delivery_date, order_delivered_customer_date, Day)),2) AS delivery_time_diff
FROM `BUSCASE1.customers` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.customer_id = b.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5




# Solution 6.1

SELECT EXTRACT(MONTH FROM a.order_purchase_timestamp) AS Months,
  b.payment_type,
  COUNT(a.order_id) AS Orders
FROM `BUSCASE1.orders` a 
INNER JOIN `BUSCASE1.payments` b 
ON a.order_id = b.order_id 
GROUP BY 1, 2 
ORDER BY 1, 2
LIMIT 10;


# Solution 6.2

SELECT a.payment_installments, COUNT(b.order_id) AS Orders 
FROM `BUSCASE1.payments` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.order_id = b.order_id 
GROUP BY 1 
ORDER BY 1,2 DESC
LIMIT 10;

SELECT order_status, COUNT(order_id) as No_of_count
FROM `BUSCASE1.orders`
GROUP BY 1


SELECT a.payment_installments, COUNT(b.order_id) AS Orders 
FROM `BUSCASE1.payments` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.order_id = b.order_id 
WHERE b.order_status != 'canceled'
GROUP BY 1 
ORDER BY 1,2 DESC
LIMIT 10;

SELECT a.payment_installments, COUNT(b.order_id) AS Orders 
FROM `BUSCASE1.payments` a 
INNER JOIN `BUSCASE1.orders` b 
ON a.order_id = b.order_id 
WHERE o.order_status != 'canceled' GROUP BY 1 ORDER BY 2 DESC;
