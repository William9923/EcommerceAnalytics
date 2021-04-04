-- payment fact

insert into staging.fct_payment 
(
	feedback_id_surr ,
	user_id ,
	payment_installments ,
	payment_sequential ,
	payment_type ,
	payment_value 
) 
(
	select 
		f.feedback_id_surr,
		u.user_id,
		p.payment_installments ,
		p.payment_sequential ,
		p.payment_type ,
		p.payment_value 
	from live.payment p
		inner join live.order o on p.order_id = o.order_id
		inner join (select * from staging.dim_user dim where dim.is_current_version = true) u on o.user_name = u.user_name 
		inner join (select * from staging.dim_feedback dim where dim.is_current_version = true) f on f.order_id = o.order_id
);

-- each product in transaction fact (Fact tables for order_items)
insert into staging.fct_order_items 
(
	user_id ,
	product_id_surr ,
	seller_id_surr ,
	feedback_id_surr ,
	order_date ,
	order_approved_date ,
	pickup_date ,
	delivered_date ,
	estimated_time_delivery ,
	pickup_limit_date ,
	order_id ,
	item_number ,
	order_item_status ,
	price ,
	shipping_cost 
) 
(
	select 
		u.user_id,
		p.product_id_surr,
		s.seller_id_surr,
		f.feedback_id_surr,
		TO_CHAR(o.order_date , 'yyyymmdd')::INT,
		TO_CHAR(o.order_approved_date , 'yyyymmdd')::INT,
		TO_CHAR(o.pickup_date , 'yyyymmdd')::INT,
		TO_CHAR(o.delivered_date , 'yyyymmdd')::INT,
		TO_CHAR(o.estimated_time_delivery , 'yyyymmdd')::INT,
		TO_CHAR(oi.pickup_limit_date , 'yyyymmdd')::INT,
		oi.order_id ,
		oi.order_item_id ,
		o.order_status ,
		oi.price ,
		oi.shipping_cost 
	from live.order_item oi 
		inner join live.order o on oi.order_id = o.order_id 
		inner join (select dim.user_id, dim.user_name from staging.dim_user dim where dim.is_current_version = true) u on o.user_name = u.user_name 
		inner join (select df.feedback_id_surr , df.order_id from staging.dim_feedback df where df.is_current_version = true) f on o.order_id = f.order_id
		inner join (select dp.product_id_surr , dp.product_id from staging.dim_product dp where dp.is_current_version = true) p on oi.product_id = p.product_id
		inner join (select ds.seller_id_surr , ds.seller_id from staging.dim_seller ds where ds.is_current_version = true) s on oi.seller_id = s.seller_id
);