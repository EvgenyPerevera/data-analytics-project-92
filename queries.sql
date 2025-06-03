-- Общее количество покупателей
SELECT
  COUNT(*) AS customers_count
FROM customers;

-- Топ-10 продавцов по выручке
SELECT
  CONCAT(e.first_name, ' ', e.last_name) AS seller,
  COUNT(s.sales_id) AS operations,
  FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
INNER JOIN employees AS e
  ON s.sales_person_id = e.employee_id
INNER JOIN products AS p
  ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10;

-- Продавцы с доходом ниже среднего по сделке
SELECT
  CONCAT(e.first_name, ' ', e.last_name) AS seller,
  ROUND(AVG(p.price * s.quantity)) AS average_income
FROM sales AS s
JOIN employees AS e
  ON s.sales_person_id = e.employee_id
JOIN products AS p
  ON s.product_id = p.product_id
GROUP BY 1
HAVING AVG(p.price * s.quantity) < (
  SELECT
    AVG(p.price * s.quantity)
  FROM sales AS s
  JOIN products AS p
    ON s.product_id = p.product_id
)
ORDER BY 2;

-- Выручка продавцов по дням недели
SELECT
  CONCAT(e.first_name, ' ', e.last_name) AS seller,
  TO_CHAR(s.sale_date, 'Day') AS day_of_week,
  FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales AS s
JOIN employees AS e
  ON s.sales_person_id = e.employee_id
JOIN products AS p
  ON s.product_id = p.product_id
GROUP BY 1, 2, EXTRACT(DOW FROM s.sale_date)
ORDER BY
  CASE
    WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7
    ELSE EXTRACT(DOW FROM s.sale_date)
  END,
  1;

-- Возрастные категории покупателей
SELECT
  CASE
    WHEN age BETWEEN 16 AND 25 THEN '16-25'
    WHEN age BETWEEN 26 AND 40 THEN '26-40'
    ELSE '40+'
  END AS age_category,
  COUNT(DISTINCT customer_id) AS age_count
FROM customers
GROUP BY 1
ORDER BY 1;

-- Продажи по месяцам
SELECT
  TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
  COUNT(DISTINCT s.customer_id) AS total_customers,
  FLOOR(SUM(s.quantity * p.price)) AS income
FROM sales AS s
JOIN products AS p
  ON s.product_id = p.product_id
GROUP BY 1
ORDER BY 1;

-- Первая акция с бесплатным товаром для каждого клиента
SELECT DISTINCT ON (c.customer_id)
  c.first_name || ' ' || c.last_name AS customer,
  s.sale_date,
  e.first_name || ' ' || e.last_name AS seller
FROM sales AS s
JOIN customers AS c
  ON s.customer_id = c.customer_id
JOIN products AS p
  ON s.product_id = p.product_id
JOIN employees AS e
  ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY c.customer_id, s.sale_date;
