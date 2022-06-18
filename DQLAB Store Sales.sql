-- we need to check all the records in the table
SELECT * FROM dqlab_sales
-- we need to change order_date data type to date 
UPDATE dqlab_sales
SET order_date = order_date::DATE

--we need to extract year from oder_date to create a new column
ALTER TABLE dqlab_sales ADD COLUMN years NUMERIC

--we need to fill in value into new column
UPDATE dqlab_sales 
SET years = EXTRACT(YEAR FROM order_date)

--order numbers and total sales from 2009 to 2012 which order status is finished
SELECT years, 
       SUM(sales) sales,
	   COUNT(order_status) AS number_of_order
FROM dqlab_sales
WHERE order_status = 'Order Finished'
GROUP BY years
ORDER BY years

--total sales for each sub_category of product on 2011 and 2012
SELECT *,
       ROUND((sale2012-sale2011)*100/sale2012,1) AS growth_sales_percent
FROM(
      SELECT product_sub_category,
             SUM(sales) FILTER(WHERE years = 2011) AS sale2011,
	         SUM(sales) FILTER(WHERE years = 2012) AS sale2012
     FROM dqlab_sales
     WHERE years BETWEEN 2011 AND 2012 and order_status='Order Finished'
     GROUP BY product_sub_category) AS sub_category
     ORDER BY growth_sales_percent DESC

--promotion effectiveness and efficiency by years 
SELECT years,
       SUM(sales) AS sales,
	   SUM(discount_value) AS promotion_value,
	   round(SUM(discount_value)*100/SUM(sales),2) AS burn_rate
FROM dqlab_sales
WHERE order_status = 'Order Finished'
GROUP BY years	   
ORDER BY years

-- promotion effectiveness and efficiency by product_sub_category
SELECT product_sub_category,
       product_category,
	   SUM(sales) AS sales,
	   SUM(discount_value) AS promotion_value,
	   round(SUM(discount_value)*100/SUM(sales),2) AS burn_rate
FROM dqlab_sales
WHERE order_status = 'Order Finished' AND years=2012
GROUP BY product_sub_category, product_category   
ORDER BY burn_rate

--number of customers transactions for each year
SELECT years,
       COUNT(DISTINCT customer) AS number_of_customer
FROM dqlab_sales
WHERE order_status = 'Order Finished'
GROUP BY years
ORDER BY years

--the number of new customers for each year
SELECT EXTRACT(YEAR FROM first_year) AS years,
       COUNT(customer) AS new_customer
FROM(
	  SELECT customer,
             MIN(order_date) AS first_year
      FROM dqlab_sales
      WHERE order_status = 'Order Finished'
	  GROUP BY customer) AS first
GROUP BY years
ORDER BY years

SELECT *,
       ROUND((sale2012-sale2011)*100/sale2012,1) AS growth_sales_percent
FROM(
     SELECT product_sub_category,
             sum(case when years=2011 then sales else null end) as sale2011,
	         sum(case when years=2012 then sales else null end) as sale2012
     FROM dqlab_sales
     WHERE years BETWEEN 2011 AND 2012 and order_status='Order Finished'
     GROUP BY product_sub_category
     ) AS sub_category
     ORDER BY growth_sales_percent DESC