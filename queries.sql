-- считает общее количество покупателей из таблицы customers и присваивает колонке псевдоним customers_count
SELECT
    COUNT(*) AS customers_count  
FROM customers;


--
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    SUM(p.price * s.quantity) AS income
From sales s
JOIN
    employees e ON s.sales_person_id = e.employee_id
JOIN
    products p ON s.product_id = p.product_id
GROUP by 1
ORDER by 3 DESC
LIMIT 10;


--
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM sales s
JOIN employees e 
   ON s.sales_person_id = e.employee_id
JOIN products p 
   ON s.product_id = p.product_id
GROUP BY 1
HAVING AVG(p.price * s.quantity) < (
    SELECT AVG(p.price * s.quantity)
    FROM sales s
    JOIN products p ON s.product_id = p.product_id)
ORDER BY 2 ASC;


--
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    LOWER(TRIM(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN employees e 
   ON s.sales_person_id = e.employee_id
JOIN products p 
   ON s.product_id = p.product_id
GROUP BY 1, 2, EXTRACT(DOW FROM s.sale_date)
ORDER BY 
   CASE 
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7   
        ELSE EXTRACT(DOW FROM s.sale_date)            
   END, 
    1;





--
SELECT
  CASE
    WHEN age BETWEEN 16 AND 25 THEN '16-25'
    WHEN age BETWEEN 26 AND 40 THEN '26-40'
    ELSE '40+'
  END AS age_category,
  COUNT(DISTINCT customer_id) AS age_count
FROM customers
GROUP BY 1
ORDER by 1;

--
SELECT
  TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
  COUNT(DISTINCT s.customer_id) AS total_customers,
  SUM(s.quantity * p.price) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1;

--
SELECT DISTINCT ON (c.customer_id)
  c.first_name || ' ' || c.last_name AS customer,
  s.sale_date,
  e.first_name || ' ' || e.last_name AS seller
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
JOIN products p ON s.product_id = p.product_id
JOIN employees e ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY c.customer_id, 2;
