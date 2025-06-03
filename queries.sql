-- Общее количество покупателей
SELECT COUNT(*) AS customers_count
FROM public.customers;

-- Топ-10 продавцов по выручке
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM public.sales AS s
INNER JOIN public.employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN public.products AS p ON s.product_id = p.product_id
GROUP BY seller
ORDER BY income DESC
LIMIT 10;

-- Продавцы с доходом ниже среднего по сделке
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    ROUND(AVG(p.price * s.quantity)) AS average_income
FROM public.sales AS s
INNER JOIN public.employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN public.products AS p ON s.product_id = p.product_id
GROUP BY seller
HAVING
    AVG(p.price * s.quantity) < (
        SELECT AVG(p2.price * s2.quantity)
        FROM public.sales AS s2
        INNER JOIN public.products AS p2 ON s2.product_id = p2.product_id
    )
ORDER BY average_income;

-- Выручка продавцов по дням недели
SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TO_CHAR(s.sale_date, 'Day') AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM public.sales AS s
INNER JOIN public.employees AS e ON s.sales_person_id = e.employee_id
INNER JOIN public.products AS p ON s.product_id = p.product_id
GROUP BY
    seller,
    day_of_week,
    EXTRACT(DOW FROM s.sale_date)
ORDER BY
    CASE
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7
        ELSE EXTRACT(DOW FROM s.sale_date)
    END,
    seller;

-- Возрастные категории покупателей
SELECT
    CASE
        WHEN c.age BETWEEN 16 AND 25 THEN '16-25'
        WHEN c.age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(DISTINCT c.customer_id) AS age_count
FROM public.customers AS c
GROUP BY age_category
ORDER BY age_category;

-- Продажи по месяцам
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM public.sales AS s
INNER JOIN public.products AS p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;

-- Первая акция с бесплатным товаром для каждого клиента
SELECT DISTINCT ON (c.customer_id)
    s.sale_date,
    c.first_name || ' ' || c.last_name AS customer,
    e.first_name || ' ' || e.last_name AS seller
FROM public.sales AS s
INNER JOIN public.customers AS c ON s.customer_id = c.customer_id
INNER JOIN public.products AS p ON s.product_id = p.product_id
INNER JOIN public.employees AS e ON s.sales_person_id = e.employee_id
WHERE p.price = 0
ORDER BY c.customer_id, s.sale_date;
