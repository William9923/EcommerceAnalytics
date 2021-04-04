-- Upsert Date dimension
INSERT INTO staging.dim_date
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
insert into staging.dim_product (
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
	where product_id not in (select product_id from staging.dim_product));

insert into staging.dim_product (
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
  from live.product join (select * from staging.dim_product where is_current_version = TRUE) stg on live.product.product_id = stg.product_id
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

update staging.dim_product 
set is_current_version = false 
where staging.dim_product.product_id_surr in (
	select staging.dim_product.product_id_surr
	from staging.dim_product inner join live.product 
	on staging.dim_product.product_id = live.product.product_id 
	where (
			staging.dim_product.product_category  <> live.product.product_category OR
            staging.dim_product.product_name_length <> live.product.product_name_length OR 
            staging.dim_product.product_description_length <> live.product.product_description_length OR 
            staging.dim_product.product_photos_qty <> live.product.product_photos_qty OR 
            staging.dim_product.product_weight_g <> live.product.product_weight_g OR 
            staging.dim_product.product_length_cm <> live.product.product_length_cm OR 
            staging.dim_product.product_height_cm <> live.product.product_height_cm OR 
            staging.dim_product.product_width_cm <> live.product.product_width_cm 
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
insert into staging.dim_user (
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
	where stg_snapshot_user.user_name not in (select distinct user_name from staging.dim_user)
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

insert into staging.dim_user (
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
	 join (select * from staging.dim_user where is_current_version = TRUE) stg on aggr.user_name = stg.user_name
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
	from staging.dim_user stg inner join u 
	on stg.user_name = u.user_name 
	 where (
            stg.total_order <> u.total_order OR 
            stg.total_spending <> u.total_spending             
      ) 
)
update staging.dim_user 
set is_current_version = false 
where staging.dim_user.user_id in (select * from v);

-- Seller dimension
-- 3 steps :
-- 1. insert new data
-- 2. insert new change in live database as change in data warehouse, make it into current version
-- 3. update the second latest version (still in current version flag) into non-current version
insert into staging.dim_seller (
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
	where seller_id not in (select seller_id from staging.dim_seller)
);

-- insert different data (SCD II) in dw
insert into staging.dim_seller (
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
  from live.seller s join (select * from staging.dim_seller where is_current_version = TRUE) stg on s.seller_id = stg.seller_id
  where (
 		stg.seller_state <> s.seller_state OR
 		stg.seller_zip_code <> s.seller_zip_code OR
 		stg.seller_city <> s.seller_city 
  )
);

-- update the changed dimension
update staging.dim_seller 
set is_current_version = false 
where staging.dim_seller.seller_id_surr in (
	select stg.seller_id_surr 
	from staging.dim_seller stg inner join live.seller s
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
insert into staging.dim_feedback (
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
	where f.order_id not in (select feedback_id from staging.dim_feedback)
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
insert into staging.dim_feedback (
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
	from f join (select * from staging.dim_feedback where is_current_version = TRUE) stg
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
update staging.dim_feedback 
set is_current_version = false 
where staging.dim_feedback.feedback_id_surr in (
	select stg.feedback_id_surr 
	from staging.dim_feedback stg inner join f 
	on stg.order_id = f.order_id 
	where (
		stg.feedback_avg_score <> f.feedback_avg_score 
	)
);