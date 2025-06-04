-- ОБЩЕЕ КОЛИЧЕСТВО ПОКУПАТЕЛЕЙ

SELECT COUNT(*) AS customers_count -- считаем общее количество покупателей 
FROM public.customers;

-- ТОП-10 ПРОДАВЦОВ ПО ВЫРУЧКЕ

/*Берем имя и фамилию из таблицы employees, объединяем в одну строку с пробелом.
Считаем количество продаж продавцов.
Считаем суммарную выручку, округляем до целых чисел в меньшую сторону.
Присоединяем таблицы employees и products.
Группируем по продавцу, сортируем по суммарной выручке от большей к меньшей.
Выводим первые 10 записей*/

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

-- ПРОДАВЦЫ С ДОХОДОМ НИЖЕ СРЕДНЕГО ПО СДЕЛКЕ

/*Берем имя и фамилию из таблицы employees и
объединяем в одну строку с пробелом.
Считаем среднюю выручку с одной сделки продавца и
округляем до целых чисел. Присоединяем таблицы employees и products.
Группируем по имени и фамилии продавца.
Считаем с помощью подзапроса среднюю выручку по всем продажам.
Сортируем по выручке по возрастанию*/

SELECT
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
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

-- ВЫРУЧКА ПРОДАВЦОВ ПО ДНЯМ НЕДЕЛИ

/*Берем имя и фамилию из таблицы employees, объединяем в одну строку с пробелом.
Из таблицы sales берем колонку с датой продажи,
преобразуем дату в название дня недели.
Считаем доход по одной продаже,
складываем все доходы для продавца по дню недели с помощью SUM,
округялем до целых чисел в меньшую сторону.
Присоединяем таблицы employees и products.
Группируем по продавцу и дню недели.
Сортируем по порядковому номеру дня недели и продавцу*/

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

-- ВОЗРАСТНЫЕ КАТЕГОРИИ ПОКУПАТЕЛЕЙ 

/*Определяем возрастные категории.
Считаем количество уникальных покупателей в каждой возрастной группе.
Группируем по возрастным группам, сортируем по возрастным группам.*/

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

-- ПРОДАЖИ ПО МЕСЯЦАМ

/*преобразуем дату продажи в формат "год-месяц".
Считаем уникальных клиентов.
Считаем суммарную выручку, округлем до целых чисел в меньшую сторону.
Присоединяем таблицу products.
Группируем по дате по возрастанию, сортируем по дате по возрастанию.*/

SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(s.quantity * p.price)) AS income
FROM public.sales AS s
INNER JOIN public.products AS p ON s.product_id = p.product_id
GROUP BY selling_month
ORDER BY selling_month;

-- ПЕРВАЯ АКЦИЯ С БЕСПЛАТНЫМ ТОВАРОМ ДЛЯ КАЖДОГО КЛИЕНТА

/*Выводим одну строку для каждого покупателя в порядке, указанном в ORDER BY.
Выводим дату продажи.
Объединяем имя и фамилию покупателя через пробел.
Объединяем имя и фамилию продавца через пробел.
Присоединяем таблицы customers, products и employees.
Оставляем только строки с акционным товаром (цена товара была равна нулю).
ортируем по id покупателя и дате.*/

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
