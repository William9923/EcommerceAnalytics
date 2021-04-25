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
)
insert into staging.dim_user (
  user_name,
  customer_zip_code,
  customer_city,
  customer_state,
  is_current_version
)
(
	select 
	 s.user_name ,
	 s.customer_zip_code ,
	 s.customer_state ,
	 s.customer_city ,
    true is_current_version 
  from deduplicate s join (select * from staging.dim_user where is_current_version = TRUE) stg 
  on s.user_name = stg.user_name
  where (
 		stg.customer_zip_code <> s.customer_zip_code 
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
)
update staging.dim_user 
set is_current_version = false 
where staging.dim_user.user_key in (
	select stg.user_key 
	from staging.dim_user stg inner join deduplicate s
	on s.user_name = stg.user_name
	where (
			stg.customer_zip_code <> s.customer_zip_code 
	)
);

-- Seller SCD Snapshot
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
where staging.dim_seller.seller_key in (
	select stg.seller_key 
	from staging.dim_seller stg inner join live.seller s
	on stg.seller_id = s.seller_id 
	where (
 		stg.seller_state <> s.seller_state OR
 		stg.seller_zip_code <> s.seller_zip_code OR
 		stg.seller_city <> s.seller_city 
  )
);

-- Feedback dimension SCD
with deduplicate as (
	select feedback_id, order_id , feedback_score, feedback_form_sent_date, feedback_answer_date from (
	select 
		distinct *,
		rank() over (
			partition by order_id 
			ORDER BY feedback_answer_date desc, feedback_form_sent_date DESC , feedback_score desc
		) as rank
	from 
		live.feedback f
	order by rank desc
	) dedup
	where dedup.rank = 1
)
insert into staging.dim_feedback (
  feedback_id,
  order_id,
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
		d.order_id,
		d.feedback_score ,
		TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT as feedback_form_sent_date,
		TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT as feedback_form_sent_time,
		TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT as feedback_answer_date,
		TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT as feedback_answer_time,
		true as is_current_version
	from deduplicate d join (select * from staging.dim_feedback where is_current_version = TRUE) stg 
  on d.order_id = stg.order_id
  where (
		 stg.feedback_score <> d.feedback_score OR
		 stg.feedback_form_sent_date <> TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT OR
		 stg.feedback_form_sent_time <> TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT OR
		 stg.feedback_answer_date <> TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT OR
		 stg.feedback_answer_time <> TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT
  )
);

with deduplicate as (
	select feedback_id, order_id , feedback_score, feedback_form_sent_date, feedback_answer_date from (
	select 
		distinct *,
		rank() over (
			partition by order_id 
			ORDER BY feedback_answer_date desc, feedback_form_sent_date DESC , feedback_score desc
		) as rank
	from 
		live.feedback f
	order by rank desc
	) dedup
	where dedup.rank = 1
)
update staging.dim_feedback 
set is_current_version = false 
where staging.dim_feedback.feedback_key in (
	select stg.feedback_key 
	from staging.dim_feedback stg inner join deduplicate d
	on d.order_id = stg.order_id
	where (
 		stg.feedback_score <> d.feedback_score OR
		 stg.feedback_form_sent_date <> TO_CHAR(d.feedback_form_sent_date , 'yyyymmdd')::INT OR
		 stg.feedback_form_sent_time <> TO_CHAR(d.feedback_form_sent_date , 'hh24mi')::INT OR
		 stg.feedback_answer_date <> TO_CHAR(d.feedback_answer_date , 'yyyymmdd')::INT OR
		 stg.feedback_answer_time <> TO_CHAR(d.feedback_answer_date , 'hh24mi')::INT
  )
);
