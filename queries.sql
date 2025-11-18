-- количество покупателей в customers
select count(*) as customers_count 
from customers cust

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
