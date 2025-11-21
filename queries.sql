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
order by
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

-- количество покупателей в разных возрастных группах
select
	age_category
,
	count (*) as age_count
from
	(
	select 
		case
			when age between 16 and 25 then '16-25'
			when age between 26 and 40 then '26-40'
			else '40+'
		end as age_category
	from
		customers cust)
as t
group by
	age_category
order by
age_category asc 

-- количество уникальных покупателей и выручка по месяцам
select 
	  TO_CHAR(sale.sale_date, 'YYYY-MM') as selling_month
	,
	COUNT(distinct sale.customer_id) as total_customers
	,
	floor (SUM(sale.quantity * prod.price))
from
	sales sale
inner join products prod on
	prod.product_id = sale.product_id
group by
	selling_month
order by
	selling_month

-- о покупателях, первая покупка которых была в ходе проведения акций
with first_purchase as (
select
	sale.customer_id,
	sale.sales_person_id,
	sale.sale_date,
	prod.price,
	row_number() over (
        partition by sale.customer_id
order by
	sale.sale_date,
	sale.sales_id
    ) as rn
from
	sales sale
inner join products prod
        on
	prod.product_id = sale.product_id)
select
	trim(concat(cust.first_name, ' ', cust.last_name)) as customer,
	first.sale_date,
	trim(concat(emp.first_name, ' ', emp.last_name)) as seller
from
	first_purchase first
join customers cust
    on
	cust.customer_id = first.customer_id
join employees emp
    on
	emp.employee_id = first.sales_person_id
where
	first.rn = 1
	and first.price = 0
order by
	cust.customer_id;
