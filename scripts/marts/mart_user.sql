-- Data Mart 2
-- Max Date
select MAX(dd."date")
from staging.fct_order_items foi
left outer join staging.dim_date dd on foi.order_date = dd.date_id 
limit 1;

-- RFM Analysis Datamart
select 
	u.user_name,
	EXTRACT(DAY from '2018-09-03'::timestamp - MAX(dd."date")) as recency,
	MAX(foi.lifetime_order) as frequency ,
	MAX(foi.lifetime_spending) as monetary
from staging.fct_order_items foi
left outer join staging.dim_date dd on foi.order_date = dd.date_id 
left outer join (
	select 
		du.user_key ,
		du.user_name 
	from staging.dim_user du 
	where du.is_current_version=true
) u on foi.user_key = u.user_key
group by u.user_name ;

-- Data Mart 2
-- Churn Analysis Datamart
-- CLTV = ((Average Order Value x Purchase Frequency)/Churn Rate) x Profit margin. -> churn rate + purchase frequency hitung manual nanti
select 
	u.user_name,
	MAX(dd."date") - MIN(dd."date") as usage_days,
	MAX(foi.lifetime_order) as  number_of_order ,
	MAX(foi.lifetime_spending) as total_spending,
	MAX(foi.lifetime_spending) / MAX(foi.lifetime_order) as average_order_value,
	MAX(foi.lifetime_order) <= 1 as isChurned
from staging.fct_order_items foi
left outer join staging.dim_date dd on foi.order_date = dd.date_id 
left outer join (
	select 
		du.user_key ,
		du.user_name 
	from staging.dim_user du 
	where du.is_current_version=true
) u on foi.user_key = u.user_key
group by u.user_name
order by MAX(dd."date") - MIN(dd."date") desc;