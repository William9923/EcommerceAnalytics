-- Upsert Date dimension
INSERT INTO warehouse.dim_date
SELECT TO_CHAR(datum, 'yyyymmdd')::INT AS date_id,
       datum AS date,
       TO_CHAR(datum, 'Day') AS day_name,
       EXTRACT(ISODOW FROM datum) AS day_of_week,
       EXTRACT(DAY FROM datum) AS day_of_month,
       datum - DATE_TRUNC('quarter', datum)::DATE + 1 AS day_of_quarter,
       EXTRACT(DOY FROM datum) AS day_of_year,
       TO_CHAR(datum, 'W')::INT AS week_of_month,
       EXTRACT(WEEK FROM datum) AS week_of_year,
       EXTRACT(MONTH FROM datum) AS month_actual,
       TO_CHAR(datum, 'Month') AS month_name,
       TO_CHAR(datum, 'Mon') AS month_name_abbreviated,
       EXTRACT(QUARTER FROM datum) AS quarter,
       EXTRACT(ISOYEAR FROM datum) AS year,
       CASE
           WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE
           ELSE FALSE
           END AS isWeekend
FROM (SELECT '2015-01-01'::DATE + SEQUENCE.DAY AS datum
      FROM GENERATE_SERIES(0, 3650) AS SEQUENCE (DAY)
      GROUP BY SEQUENCE.DAY) DQ
ORDER BY 1;

-- Product dimension
-- 3 steps :
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version
insert into warehouse.dim_product (
	product_id, 
	product_category,
    product_name_length, 
    product_description_length, 
    product_photos_qty, 
    product_weight_g, 
    product_length_cm, 
    product_height_cm, 
    product_width_cm, 
    is_current_version
) 
(select 
	*,
	true as is_current_version 
	from live.product
	where product_id not in (select product_id from warehouse.dim_product));

insert into warehouse.dim_product (
	product_id, 
	product_category,
    product_name_length, 
    product_description_length, 
    product_photos_qty, 
    product_weight_g, 
    product_length_cm, 
    product_height_cm, 
    product_width_cm, 
    is_current_version
) 
(select 
	live.product.product_id,
	live.product.product_category,
	live.product.product_name_length,
	live.product.product_description_length,
	live.product.product_photos_qty, 
    live.product.product_weight_g, 
    live.product.product_length_cm, 
    live.product.product_height_cm, 
    live.product.product_width_cm, 
    true is_current_version 
  from live.product join (select * from warehouse.dim_product where is_current_version = TRUE) stg on live.product.product_id = stg.product_id
  where (
            stg.product_name_length <> live.product.product_name_length OR 
            stg.product_category <> live.product.product_category OR
            stg.product_description_length <> live.product.product_description_length OR 
            stg.product_photos_qty <> live.product.product_photos_qty OR 
            stg.product_weight_g <> live.product.product_weight_g OR 
            stg.product_length_cm <> live.product.product_length_cm OR 
            stg.product_height_cm <> live.product.product_height_cm OR 
            stg.product_width_cm <> live.product.product_width_cm 
      )
     );

update warehouse.dim_product 
set is_current_version = false 
where warehouse.dim_product.product_id_surr in (
	select warehouse.dim_product.product_id_surr
	from warehouse.dim_product inner join live.product 
	on warehouse.dim_product.product_id = live.product.product_id 
	where (
			warehouse.dim_product.product_category  <> live.product.product_category OR
            warehouse.dim_product.product_name_length <> live.product.product_name_length OR 
            warehouse.dim_product.product_description_length <> live.product.product_description_length OR 
            warehouse.dim_product.product_photos_qty <> live.product.product_photos_qty OR 
            warehouse.dim_product.product_weight_g <> live.product.product_weight_g OR 
            warehouse.dim_product.product_length_cm <> live.product.product_length_cm OR 
            warehouse.dim_product.product_height_cm <> live.product.product_height_cm OR 
            warehouse.dim_product.product_width_cm <> live.product.product_width_cm 
      )
);

-- User dimension
-- 3 steps :
-- 0. create the aggregate for user data
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version

with stg_snapshot_user as (
	select distinct 
		user_name,
		count(user_name) as num_order 
	from live."user"
	group by user_name
	order by user_name 
), stg_snapshot_spending as (
	select distinct  
		o.user_name ,
		(sum(oi.price) + sum(oi.shipping_cost)) as total_spending
	from live."order" o left join live.order_item oi 
	on o.order_id = oi.order_id 
	where o.order_status not in ('canceled', 'unavailable') or o.order_status isnull 
	group by o.user_name 
)
insert into warehouse.dim_user (
	user_name,
	total_order,
	total_spending,
	is_current_version
) 
(
	select 
		stg_snapshot_user.user_name as user_name ,
		stg_snapshot_user.num_order as total_order,
		case
        	when (stg_snapshot_spending.total_spending IS NULL) THEN 0
        	else stg_snapshot_spending.total_spending
    	end,     
		true as is_current_version
	from stg_snapshot_user left outer join stg_snapshot_spending on 
		stg_snapshot_user.user_name = stg_snapshot_spending.user_name
	where stg_snapshot_user.user_name not in (select distinct user_name from warehouse.dim_user)
);

with stg_snapshot_user as (
	select distinct 
		user_name,
		count(user_name) as num_order 
	from live."user"
	group by user_name
	order by user_name 
), stg_snapshot_spending as (
	select distinct  
		o.user_name ,
		(sum(oi.price) + sum(oi.shipping_cost)) as total_spending
	from live."order" o left join live.order_item oi 
	on o.order_id = oi.order_id 
	where o.order_status not in ('canceled', 'unavailable') or o.order_status isnull 
	group by o.user_name 
), aggr as (
	select 
		stg_snapshot_user.user_name as user_name ,
		stg_snapshot_user.num_order as total_order,
		case
        	when stg_snapshot_spending.total_spending = NULL THEN 0
        	else stg_snapshot_spending.total_spending
    	end,     
		true as is_current_version
	from stg_snapshot_user left outer join stg_snapshot_spending on 
		stg_snapshot_user.user_name = stg_snapshot_spending.user_name
)

insert into warehouse.dim_user (
	user_name,
	total_order,
	total_spending,
	is_current_version
) 
(select 
	aggr.user_name,
	aggr.total_order,
	aggr.total_spending,
    true is_current_version
  from aggr
	 join (select * from warehouse.dim_user where is_current_version = TRUE) stg on aggr.user_name = stg.user_name
  where (
            stg.total_order <> aggr.total_order OR 
            stg.total_spending <> aggr.total_spending             
      )
 );

 with stg_snapshot_user as (
	select distinct 
		user_name,
		count(user_name) as num_order 
	from live."user"
	group by user_name
	order by user_name 
), stg_snapshot_spending as (
	select distinct  
		o.user_name ,
		(sum(oi.price) + sum(oi.shipping_cost)) as total_spending
	from live."order" o left join live.order_item oi 
	on o.order_id = oi.order_id 
	where o.order_status not in ('canceled', 'unavailable') or o.order_status isnull 
	group by o.user_name 
), u as (
	select 
		stg_snapshot_user.user_name as user_name ,
		stg_snapshot_user.num_order as total_order,
		case
        	when stg_snapshot_spending.total_spending = NULL THEN 0
        	else stg_snapshot_spending.total_spending
    	end,
    	true as is_current_version
	from stg_snapshot_user left outer join stg_snapshot_spending on 
		stg_snapshot_user.user_name = stg_snapshot_spending.user_name
)
, v as (
	select distinct stg.user_id 
	from warehouse.dim_user stg inner join u 
	on stg.user_name = u.user_name 
	 where (
            stg.total_order <> u.total_order OR 
            stg.total_spending <> u.total_spending             
      ) 
)
update warehouse.dim_user 
set is_current_version = false 
where warehouse.dim_user.user_id in (select * from v);

-- Seller dimension
-- 3 steps :
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version
insert into warehouse.dim_seller (
	seller_id ,
	seller_zip_code ,
	seller_city ,
	seller_state ,
	is_current_version 
) 
(select 
	*,
	true as is_current_version
	from live.seller
	where seller_id not in (select seller_id from warehouse.dim_seller)
);

-- insert different data (SCD II) in dw
insert into warehouse.dim_seller (
	seller_id ,
	seller_zip_code ,
	seller_city ,
	seller_state ,
	is_current_version 
) 
(select 
	 s.seller_id ,
	 s.seller_zip_code ,
	 s.seller_city ,
	 s.seller_state ,
    true is_current_version 
  from live.seller s join (select * from warehouse.dim_seller where is_current_version = TRUE) stg on s.seller_id = stg.seller_id
  where (
 		stg.seller_state <> s.seller_state OR
 		stg.seller_zip_code <> s.seller_zip_code OR
 		stg.seller_city <> s.seller_city 
  )
);

-- update the changed dimension
update warehouse.dim_seller 
set is_current_version = false 
where warehouse.dim_seller.seller_id_surr in (
	select stg.seller_id_surr 
	from warehouse.dim_seller stg inner join live.seller s
	on stg.seller_id = s.seller_id 
	where (
 		stg.seller_state <> s.seller_state OR
 		stg.seller_zip_code <> s.seller_zip_code OR
 		stg.seller_city <> s.seller_city 
  )
);


-- Feedback dimension
-- 3 steps :
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version
insert into warehouse.dim_feedback (
	order_id ,
	feedback_avg_score ,
	feedback_form_sent_date ,
	feedback_answer_date ,
	is_current_version 
)
(
	select 
		f.order_id ,
		avg(f.feedback_score) as feedback_avg_score ,
		TO_CHAR(MAX(date(f.feedback_form_sent_date)), 'yyyymmdd')::INT AS feedback_form_sent_date,
		TO_CHAR(MAX(date(f.feedback_answer_date)), 'yyyymmdd')::INT AS feedback_answer_date,
		true as is_current_version 
	from live.feedback f 
	where f.order_id not in (select feedback_id from warehouse.dim_feedback)
	group by f.order_id 
);

with f as (
	select 
		f.order_id ,
		avg(f.feedback_score) as feedback_avg_score ,
		TO_CHAR(MAX(date(f.feedback_form_sent_date)), 'yyyymmdd')::INT AS feedback_form_sent_date,
		TO_CHAR(MAX(date(f.feedback_answer_date)), 'yyyymmdd')::INT AS feedback_answer_date,
		true as is_current_version 
	from live.feedback f
	group by f.order_id 
)
insert into warehouse.dim_feedback (
	order_id ,
	feedback_avg_score ,
	feedback_form_sent_date ,
	feedback_answer_date ,
	is_current_version 
)
(
	select 
		f.order_id ,
		f.feedback_avg_score,
		f.feedback_form_sent_date,
		f.feedback_answer_date,
		true is_current_version 
	from f join (select * from warehouse.dim_feedback where is_current_version = TRUE) stg
	on f.order_id = stg.order_id
	where (
		stg.feedback_avg_score <> f.feedback_avg_score 
	)
);

with f as (
	select 
		f.order_id ,
		avg(f.feedback_score) as feedback_avg_score ,
		TO_CHAR(MAX(date(f.feedback_form_sent_date)), 'yyyymmdd')::INT AS feedback_form_sent_date,
		TO_CHAR(MAX(date(f.feedback_answer_date)), 'yyyymmdd')::INT AS feedback_answer_date,
		true as is_current_version 
	from live.feedback f
	group by f.order_id 
)
update warehouse.dim_feedback 
set is_current_version = false 
where warehouse.dim_feedback.feedback_id_surr in (
	select stg.feedback_id_surr 
	from warehouse.dim_feedback stg inner join f 
	on stg.order_id = f.order_id 
	where (
		stg.feedback_avg_score <> f.feedback_avg_score 
	)
);

-- Payment dimension
-- 3 steps :
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version

insert into warehouse.dim_payment (
	order_id,
	num_payment, 
	total_payment_value,
	total_payment_installment,
	num_credit_card,
	total_payment_credit_card,
	num_blipay,
	total_payment_blipay,
	num_voucher,
	total_payment_voucher,
	num_debit,
	total_payment_debit,
	num_unknown,
	total_payment_unknown,
	is_current_version
)
(select 
	order_id,
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
	true as is_current_version
from live.payment p 
group by p.order_id
);

with p as (
	select 
		order_id,
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
		true as is_current_version
	from live.payment p 
	group by p.order_id
)

insert into warehouse.dim_payment (
	order_id,
	num_payment, 
	total_payment_value,
	total_payment_installment,
	num_credit_card,
	total_payment_credit_card,
	num_blipay,
	total_payment_blipay,
	num_voucher,
	total_payment_voucher,
	num_debit,
	total_payment_debit,
	num_unknown,
	total_payment_unknown,
	is_current_version
)
(
	select 
		p.order_id,
		p.num_payment,
		p.total_payment_value,
		p.total_payment_installment,
		p.num_credit_card,
		p.total_payment_credit_card,
		p.num_blipay,
		p.total_payment_blipay,
		p.num_voucher,
		p.total_payment_voucher,
		p.num_debit,
		p.total_payment_debit,
		p.num_unknown,
		p.total_payment_unknown,
		true as is_current_version
	from p join (select * from warehouse.dim_payment where is_current_version = TRUE) stg
	on p.order_id = stg.order_id
	where (
		stg.num_payment <> p.num_payment or
		stg.total_payment_value <> p.total_payment_value or
		stg.total_payment_installment <> p.total_payment_installment or
		stg.num_credit_card <> p.num_credit_card OR
		stg.num_blipay <> p.num_blipay OR
		stg.num_voucher <> p.num_voucher OR
		stg.num_debit <> p.num_debit OR
		stg.num_unknown <> p.num_unknown or 
 		stg.total_payment_credit_card <> p.total_payment_credit_card OR
 		stg.total_payment_blipay <> p.total_payment_blipay OR
 		stg.total_payment_voucher <> p.total_payment_voucher OR
 		stg.total_payment_debit <> p.total_payment_debit OR
 		stg.total_payment_unknown <> p.total_payment_unknown 
	)
);

with p as (
	select 
		order_id,
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
		true as is_current_version
	from live.payment p 
	group by p.order_id
)
update warehouse.dim_payment 
set is_current_version = false 
where warehouse.dim_payment.payment_id_surr in (
	select stg.payment_id_surr 
	from warehouse.dim_payment stg inner join p
	on stg.order_id = p.order_id 
	where (
		stg.num_payment <> p.num_payment or
		stg.total_payment_value <> p.total_payment_value or
		stg.total_payment_installment <> p.total_payment_installment or
		stg.num_credit_card <> p.num_credit_card OR
		stg.num_blipay <> p.num_blipay OR
		stg.num_voucher <> p.num_voucher OR
		stg.num_debit <> p.num_debit OR
		stg.num_unknown <> p.num_unknown or 
 		stg.total_payment_credit_card <> p.total_payment_credit_card OR
 		stg.total_payment_blipay <> p.total_payment_blipay OR
 		stg.total_payment_voucher <> p.total_payment_voucher OR
 		stg.total_payment_debit <> p.total_payment_debit OR
 		stg.total_payment_unknown <> p.total_payment_unknown 
	)
);
	