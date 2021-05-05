-- Data Mart 3
-- Product for each order (each basket in transaction)
select 
	foi.order_id ,
	MAX(foi.total_payment_value) as payment_val,
	STRING_AGG(p.product_id::character varying, ',') as list_of_item,
	STRING_AGG(distinct p.product_category::character varying, ',') as list_of_category
from staging.fct_order_items foi 
left outer join (
	select 
		dp.product_key ,
		dp.product_id ,
		dp.product_category 
	from staging.dim_product dp 
	where dp.is_current_version=true
) p on foi.product_key = p.product_key
group by 1;

-- Data mart no aggregation
select 
	foi.order_id ,
	p.product_id,
	p.product_category,
    foi.price,
	foi.total_payment_value 
from staging.fct_order_items foi 
left outer join (
	select 
		dp.product_key ,
		dp.product_id ,
		dp.product_category
	from staging.dim_product dp 
	where dp.is_current_version=true
) p on foi.product_key = p.product_key
order by 1,2;