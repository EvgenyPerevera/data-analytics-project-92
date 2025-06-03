SELECT
    COUNT(*) AS customers_count --считает общее количество покупателей из таблицы customers, присваивает колонке псевдоним customers_count
FROM customers;


SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, 
    /* берем имя и фамилию из таблицы employees, объединяем 
    в одну строку с пробелом с помощью CONCAT, 
    присваиваем колонке псевдоним seller */
    COUNT(s.sales_id) AS operations, /*считаем 
    количество продаж, связанных с продавцом, 
    присваиваем колонке псевдоним operations */
    FLOOR(SUM(p.price * s.quantity)) AS income /*считаем 
    суммарную выручку (цена товара * количество), 
    округляем до целых чисел (в меньшую сторону), 
    присваиваем колонке псевдоним income*/
FROM sales AS s
INNER JOIN
    employees AS e
    --присоединяем таблицу employees, чтобы узнать, кто сделал продажу
    ON s.sales_person_id = e.employee_id
INNER JOIN
    products AS p
    --присоединяем таблицу products, чтобы узнать цену товара
    ON s.product_id = p.product_id
GROUP BY 1 --группируем по продавцу
ORDER BY 3 DESC --сортируем по суммарной выручке (от большей к меньшей)
LIMIT 10; --выводим первые 10 записей


SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, --берем имя и фамилию из таблицы employees, объединяем в одну строку с пробелом с помощью CONCAT, присваиваем колонке псевдоним seller
    ROUND(AVG(p.price * s.quantity)) AS average_income --считаем среднюю выручку с одной сделки продавца, округляем до целых чисел, присваиваем колонке псевдоним average_income
FROM sales s
JOIN employees e 
   ON s.sales_person_id = e.employee_id --присоединяем таблицу employees, чтобы получить продавца
JOIN products p 
   ON s.product_id = p.product_id --присоединяем таблицу products, чтобы узнать цену товара
GROUP BY 1 --группируем по имени и фамилии продавца
HAVING AVG(p.price * s.quantity) < (
    SELECT AVG(p.price * s.quantity)
    FROM sales s
    JOIN products p ON s.product_id = p.product_id) -- считаем с помощью подзапроса среднюю выручку по всем продажам
ORDER BY 2; --сортируем по выручке (по возрастанию)


SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller, --берем имя и фамилию из таблицы employees, объединяем в одну строку с пробелом с помощью CONCAT, присваиваем колонке псевдоним seller
    TO_CHAR(s.sale_date, 'Day') AS day_of_week, --из таблицы sales берем колонку с датой продажи, преобразуем дату в название дня недели, присваиваем колонке псевдоним day_of_week
    FLOOR(SUM(p.price * s.quantity)) AS income --считаем доход по одной продаже (цена товара * количество), складываем все доходы для продавца по дню недели с помощью SUM, округялем до целых чисел (в меньшую сторону), присваиваем колнке псевдоним income
FROM sales s
JOIN employees e 
   ON s.sales_person_id = e.employee_id --присоединяем таблицу employees, чтобы узнать, кто сделал продажу
JOIN products p 
   ON s.product_id = p.product_id --присоединяем таблицу products, чтобы узнать цену товара
GROUP BY 1, 2, EXTRACT(DOW FROM s.sale_date) --группируем по продавцу и дню недели 
ORDER BY 
   CASE 
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7   
        ELSE EXTRACT(DOW FROM s.sale_date)            
   END, 
    1; --сортируем по порядковому номеру дня недели и продавцу

SELECT
  CASE
    WHEN age BETWEEN 16 AND 25 THEN '16-25'
    WHEN age BETWEEN 26 AND 40 THEN '26-40'
    ELSE '40+'
  END AS age_category, --определяем возрастные группы по возрасту age, присваиваем псевдоним age_category
  COUNT(DISTINCT customer_id) AS age_count --считаем количество покупателей в каждой возрастной группе, присваиваем колонке псевдоним age_count
FROM customers
GROUP BY 1 --группируем по возрастным группам 
ORDER BY 1; --сортируем по возрастным группам 


SELECT
  TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month, --преобразуем дату продажи в формат "год-месяц", чтобы сгруппировать продажи по месяцам, присваиваем колонке псевдоним selling_month
  COUNT(DISTINCT s.customer_id) AS total_customers, --считаем уникальных клиентов, присваиваем колонке псевдоним total_customers
  FLOOR(SUM(s.quantity * p.price)) AS income --считаем суммарную выручку, округлем до целых чисел (в меньшую сторону), присваивем колонке псевдоним income
FROM sales s
JOIN products p 
    ON s.product_id = p.product_id --присоединяем таблицу products, чтобы узнать цену товара
GROUP BY 1 --группируем по дате (по возрастанию)
ORDER BY 1; --сортируем по дате (по возрастанию)


SELECT DISTINCT ON (c.customer_id) --выводим одну строку для каждого уникального покупателя (задаем в ORDER BY какую именно) 
  c.first_name || ' ' || c.last_name AS customer, --объединяем имя и фамилию покупателя через пробел, присваиваем колонке псевдоним customer
  s.sale_date, --выводим дату продажи 
  e.first_name || ' ' || e.last_name AS seller --объединяем имя и фамилию продавца через пробел, присваиваем колонке псевдоним seller
FROM sales s
JOIN customers c 
    ON s.customer_id = c.customer_id --присоединяем таблицу customers, чтобы узнать имя клиента
JOIN products p 
    ON s.product_id = p.product_id --присоединяем таблицу products, чтобы узнать цену товара 
JOIN employees e 
    ON s.sales_person_id = e.employee_id --присоединяем таблицу employees, чтобы узнать имя продавца 
WHERE p.price = 0 --оставляем только те строки, где цена товара была равна нулю
ORDER BY c.customer_id, 2; --сортируем по id покупателя и дате, чтобы получить самую раннюю покупку по акции 
