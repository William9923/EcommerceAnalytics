-- Data Mart 1 
-- Sales Trend Analysis Datamart
select 
	foi.order_id ,
	foi.order_item_id ,
	u.user_name,
	p.product_id ,
	p.product_category ,
	foi.price,
	foi.shipping_cost ,
	foi.total_payment_value 
from staging.fct_order_items foi
left outer join staging.dim_date dd on foi.order_date = dd.date_id 
left outer join staging.dim_time dt on foi.order_time = dt.time_id 
left outer join (
	select 
		du.user_key ,
		du.user_name
	from staging.dim_user du 
	where du.is_current_version=true
) u on foi.user_key = u.user_key
left outer join (
	select 
		dp.product_key ,
		dp.product_id , 
		dp.product_category 
	from staging.dim_product dp 
	where dp.is_current_version=true
) p on foi.product_key = p.product_key;
