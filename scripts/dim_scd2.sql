-- Product SCD Snapshot
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
	CASE 
         when live.product.product_category is not null then live.product.product_category
         else 'OTHER'
    END as product_category,
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
where staging.dim_product.product_key in (
	select staging.dim_product.product_key
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

-- User SCD Snapshot
with deduplicate as (
	select user_name , customer_zip_code , customer_city , customer_state 
	from (
		SELECT 
			DISTINCT *,
			RANK() over(
					PARTITION BY user_name 
					ORDER BY customer_zip_code DESC, customer_state DESC , customer_city DESC
			) as rank
		FROM 
			live.user u
		) dedup 
	where rank = 1
), geolocation as (
	select geo_id, city
	from dim_geo
)
insert into staging.dim_user (
  user_name,
  customer_geo_id,
  is_current_version
)
(
	select 
	 s.user_name ,
	 geolocation.geo_id,
     true is_current_version 
  from deduplicate s join (select * from staging.dim_user where is_current_version = TRUE) stg 
  on s.user_name = stg.user_name
  left join geolocation on s.customer_city = geolocation.city
  where (
 		stg.customer_geo_id <> geolocation.geo_id 
  )
);

with deduplicate as (
	select user_name , customer_zip_code , customer_city , customer_state 
	from (
		SELECT 
			DISTINCT *,
			RANK() over(
					PARTITION BY user_name 
					ORDER BY customer_zip_code DESC, customer_state DESC , customer_city DESC
			) as rank
		FROM 
			live.user u
		) dedup 
	where rank = 1
), geolocation as (
	select geo_id, city
	from dim_geo
)
update staging.dim_user 
set is_current_version = false 
where staging.dim_user.user_key in (
	select stg.user_key 
	from staging.dim_user stg inner join deduplicate s
	on s.user_name = stg.user_name
	left join geolocation on s.customer_city = geolocation.city
	where (
			stg.customer_geo_id <> geolocation.geo_id 
	)
);

-- Seller SCD Snapshot
with geolocation as (
	select geo_id, city
	from dim_geo
)
insert into staging.dim_seller (
	seller_id ,
	seller_geo_id ,
	is_current_version 
) 
(select 
	s.seller_id,
	geolocation.geo_id,
    true is_current_version 
  from live.seller s join (select * from staging.dim_seller where is_current_version = TRUE) stg on s.seller_id = stg.seller_id
  left join geolocation on s.seller_city = geolocation.city
  where (
 		stg.seller_geo_id <> geolocation.geo_id 
  )
);

with geolocation as (
	select geo_id, city
	from dim_geo
)
-- update the changed dimension
update staging.dim_seller 
set is_current_version = false 
where staging.dim_seller.seller_key in (
	select stg.seller_key 
	from staging.dim_seller stg inner join live.seller s
	on stg.seller_id = s.seller_id 
	left join geolocation on s.seller_city = geolocation.city
	where (
			stg.seller_geo_id <> geolocation.geo_id 
	)
);

-- Feedback dimension SCD
with deduplicate_order as (
	select feedback_id, feedback_score, feedback_form_sent_date, feedback_answer_date 
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
), deduplicate_feedback as (
	select
		 distinct *,
			rank() over (
				partition by feedback_id 
				ORDER BY feedback_answer_date desc, feedback_form_sent_date DESC
			) as rank
		from 
			deduplicate_order
		order by rank desc
)
insert into staging.dim_feedback (
  feedback_id,
  feedback_score,
  feedback_form_sent_date,
  feedback_form_sent_time,
  feedback_answer_date,
  feedback_answer_time,
  is_current_version
)
(
	select 
		d.feedback_id,
		d.feedback_score,
		TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT as feedback_form_sent_date,
		TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT as feedback_form_sent_time,
		TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT as feedback_answer_date,
		TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT as feedback_answer_time,
		true as is_current_version
	from deduplicate_feedback d join (select * from staging.dim_feedback where is_current_version = TRUE) stg 
  on d.feedback_id = stg.feedback_id
  where ( 
  		 stg.feedback_score <> d.feedback_score OR
		 stg.feedback_form_sent_date <> TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT OR
		 stg.feedback_form_sent_time <> TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT OR
		 stg.feedback_answer_date <> TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT OR
		 stg.feedback_answer_time <> TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT
  )
);

with deduplicate_order as (
	select feedback_id, feedback_score, feedback_form_sent_date, feedback_answer_date 
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
), deduplicate_feedback as (
	select
		 distinct *,
			rank() over (
				partition by feedback_id 
				ORDER BY feedback_answer_date desc, feedback_form_sent_date DESC
			) as rank
		from 
			deduplicate_order
		order by rank desc
)
update staging.dim_feedback 
set is_current_version = false 
where staging.dim_feedback.feedback_key in (
	select stg.feedback_key 
	from staging.dim_feedback stg inner join deduplicate_feedback d
	on d.feedback_id = stg.feedback_id
	where (
 		stg.feedback_score <> d.feedback_score OR
		 stg.feedback_form_sent_date <> TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT OR
		 stg.feedback_form_sent_time <> TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT OR
		 stg.feedback_answer_date <> TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT OR
		 stg.feedback_answer_time <> TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT
  )
);
