-- Order - order_items fact table
-- each product in transaction fact (Fact tables for order_items)

-- Fact table 
with stg_snapshot_user as (
	select distinct 
		user_name,
		count(user_name) as num_order 
	from live."user"
	group by user_name
), stg_snapshot_spending as (
	select distinct  
		o.user_name ,
		(sum(oi.price) + sum(oi.shipping_cost)) as total_spending
	from live."order" o left outer join live.order_item oi 
	on o.order_id = oi.order_id 
	where o.order_status is not null and o.order_status not in ('canceled', 'unavailable') 
	group by o.user_name 
), deduplicate_order as (
	select feedback_id, order_id, feedback_score, feedback_form_sent_date, feedback_answer_date 
	from (
		select
		distinct *,
			rank() over (
				partition by order_id 
				ORDER BY feedback_answer_date desc, feedback_form_sent_date DESC
			) as rank
		from 
			live.feedback f
		order by rank desc
	) dedup 
	where dedup.rank = 1
)
insert into staging.fct_order_items 
(
	order_id,
	order_item_id,
	user_key ,
	product_key ,
	seller_key ,
	feedback_key,
	order_date ,
	order_time ,
	order_approved_date ,
	order_approved_time ,
	pickup_date ,
	pickup_time ,
	delivered_date ,
	delivered_time ,
	estimated_date_delivery ,
	estimated_time_delivery ,
	pickup_limit_date ,
	pickup_limit_time ,
	order_item_status ,
	price ,
	shipping_cost ,
	num_payment ,
	total_payment_value ,
	total_payment_installment ,
	num_credit_card ,
	total_payment_credit_card ,
	num_blipay ,
	total_payment_blipay ,
	num_voucher,
	total_payment_voucher ,
	num_debit ,
	total_payment_debit ,
	num_unknown ,
	total_payment_unknown ,
	lifetime_order,
	lifetime_spending
)
(
	select 
		oi.order_id ,
		oi.order_item_id,
		u.user_key,
		p.product_key,
		s.seller_key,
		f.feedback_key,
		TO_CHAR(o.order_date , 'yyyymmdd')::INT,
		TO_CHAR(o.order_date , 'hh24mi')::INT,
		TO_CHAR(o.order_approved_date , 'yyyymmdd')::INT,
		TO_CHAR(o.order_approved_date , 'hh24mi')::INT,
		TO_CHAR(o.pickup_date , 'yyyymmdd')::INT,
		TO_CHAR(o.pickup_date , 'hh24mi')::INT,
		TO_CHAR(o.delivered_date , 'yyyymmdd')::INT,
		TO_CHAR(o.delivered_date , 'hh24mi')::INT,
		TO_CHAR(o.estimated_time_delivery , 'yyyymmdd')::INT,
		TO_CHAR(o.estimated_time_delivery , 'hh24mi')::INT,
		TO_CHAR(oi.pickup_limit_date , 'yyyymmdd')::INT,
		TO_CHAR(oi.pickup_limit_date , 'hh24mi')::INT,
		o.order_status,
		oi.price ,
		oi.shipping_cost ,
		MAX(payment_sequential) as num_payment,
		SUM(payment_value) as total_payment_value,
		SUM(payment_installments) as total_payment_installment,
		SUM(case when payment_type='credit_card' then 1 else 0 end) as num_credit_card,
		SUM(case when payment_type='credit_card' then payment_value else 0 end) as total_payment_credit_card,
		SUM(case when payment_type='blipay' then 1 else 0 end) as num_blipay,
		SUM(case when payment_type='blipay' then payment_value else 0 end) as total_payment_blipay,
		SUM(case when payment_type='voucher' then 1 else 0 end) as num_voucher,
		SUM(case when payment_type='voucher' then payment_value else 0 end) as total_payment_voucher,
		SUM(case when payment_type='debit_card' then 1 else 0 end) as num_debit,
		SUM(case when payment_type='debit_card' then payment_value else 0 end) as total_payment_debit,
		SUM(case when payment_type='not_defined' then 1 else 0 end) as num_unknown,
		SUM(case when payment_type='not_defined' then payment_value else 0 end) as total_payment_unknown,
		stg_snapshot_user.num_order,
		case
        	when stg_snapshot_spending.total_spending is null THEN 0
        	else stg_snapshot_spending.total_spending
    	end
	from live.order_item oi
		left outer join live.order o on oi.order_id = o.order_id 
		left outer join (select dim.user_key, dim.user_name from staging.dim_user dim where dim.is_current_version = true) u on o.user_name = u.user_name 
		left outer join (select dp.product_key , dp.product_id from staging.dim_product dp where dp.is_current_version = true) p on oi.product_id = p.product_id
		left outer join (select ds.seller_key , ds.seller_id from staging.dim_seller ds where ds.is_current_version = true) s on oi.seller_id = s.seller_id
		left outer join deduplicate_order on oi.order_id = deduplicate_order.order_id
		left outer join (select df.feedback_key, df.feedback_id from staging.dim_feedback df where df.is_current_version = true) f on deduplicate_order.feedback_id = f.feedback_id
		left outer join stg_snapshot_user on o.user_name = stg_snapshot_user.user_name
		left outer join stg_snapshot_spending on o.user_name = stg_snapshot_spending.user_name
		left outer join live.payment pay on o.order_id = pay.order_id
	group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,35,36
);