-- количество покупателей в customers
select
	count(*) as customers_count
from
	customers cust

-- отчет с продавцами у которых наибольшая выручка
select 
	concat(first_name, ' ', last_name) as seller
	,
	count(sale.sales_person_id) as operations
	,
	floor(SUM(sale.quantity * prod.price)) as income
from
	employees emp
inner join sales sale on
	emp.employee_id = sale.sales_person_id
inner join products prod on
	prod.product_id = sale.product_id
group by
	seller
order by
	income desc
limit 10

-- меньше средней выручки
with sellers_avg as (
select 
	trim (concat(first_name, ' ', last_name)) as seller
	,
	SUM(prod.price * sale.quantity) / COUNT(*) as avg_income
from
	employees emp
inner join sales sale on
	emp.employee_id = sale.sales_person_id
inner join products prod on
	prod.product_id = sale.product_id
group by
	seller 
	)
,
only_avg as (
select
	AVG(avg_income) as sum_avg
from
	sellers_avg
)
select
	seller
	,
	floor(avg_income) as average_income
from
	sellers_avg,
	only_avg
where
	avg_income < sum_avg
order by‹›
	average_income asc

--выручка по дням недели
select 
	TRIM(concat(emp.first_name, ' ', emp.last_name )) as seller
	,
	trim (to_char(sale.sale_date, 'Day')) as day_of_week
	,
	floor (sum (sale.quantity * prod.price)) as income
from
	employees emp
inner join sales sale on
	emp.employee_id = sale.sales_person_id
inner join products prod on
	prod.product_id = sale.product_id
group by
	seller,
	extract (isoDOW
from
	sale.sale_date)
	,
	day_of_week
order by
	extract (isoDOW
from
	sale.sale_date)
	,
	seller;
