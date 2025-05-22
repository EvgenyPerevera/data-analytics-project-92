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
