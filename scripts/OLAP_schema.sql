DROP TABLE IF EXISTS staging.fct_order_items;
DROP TABLE IF EXISTS staging.fct_payment;
DROP TABLE IF EXISTS staging.dim_feedback;
DROP TABLE IF EXISTS staging.dim_user;
DROP TABLE IF EXISTS staging.dim_product;
DROP TABLE IF EXISTS staging.dim_seller;
DROP TABLE IF EXISTS staging.dim_date;

CREATE TABLE staging.dim_user (
  "user_id" serial PRIMARY KEY,
  "user_name" varchar,
  "total_order" decimal,
  "total_spending" decimal,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_product (
  "product_id_surr" serial PRIMARY KEY,
  "product_id" varchar,
  "product_category" varchar,
  "product_name_length" decimal,
  "product_description_length" decimal,
  "product_photos_qty" decimal,
  "product_length_cm" decimal,
  "product_weight_g" decimal,
  "product_height_cm" decimal,
  "product_width_cm" decimal,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_seller (
  "seller_id_surr" serial PRIMARY KEY, 
  "seller_id" varchar,
  "seller_zip_code" int,
  "seller_city" varchar,
  "seller_state" varchar,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_feedback (
  "feedback_id_surr" serial PRIMARY KEY,
  "order_id" varchar, 
  "feedback_avg_score" decimal,
  "feedback_form_sent_date" varchar,
  "feedback_answer_date" varchar,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_date (
  "date_id" varchar PRIMARY KEY,
  "date" date,
  "day_name" varchar,
  "day_of_week" integer,
  "day_of_month" integer,
  "day_of_quarter" integer,
  "day_of_year" decimal,
  "week_of_month" integer,
  "week_of_year" decimal,
  "month_actual" decimal,
  "month_name" varchar,
  "month_name_abbreviated" varchar,
  "quarter" decimal,
  "year" decimal,
  "isWeekend" boolean
);

CREATE TABLE staging.fct_order_items (
  "id" serial PRIMARY KEY,
  "user_id" integer,
  "product_id_surr" integer,
  "seller_id_surr" integer,
  "feedback_id_surr" integer,
  "order_date" varchar,
  "order_approved_date" varchar,
  "pickup_date" varchar,
  "delivered_date" varchar,
  "estimated_time_delivery" varchar,
  "pickup_limit_date" varchar,
  "order_id" varchar,
  "item_number" integer,
  "order_item_status" varchar,
  "price" decimal,
  "shipping_cost" decimal
);

CREATE TABLE staging.fct_payment (
  "id" serial PRIMARY KEY,
  "feedback_id_surr" integer,
  "user_id" integer,
  "payment_sequential" integer,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" decimal
);

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("user_id") REFERENCES staging.dim_user ("user_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("product_id_surr") REFERENCES staging.dim_product ("product_id_surr");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("seller_id_surr") REFERENCES staging.dim_seller ("seller_id_surr");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("feedback_id_surr") REFERENCES staging.dim_feedback ("feedback_id_surr");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_approved_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("delivered_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("estimated_time_delivery") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_limit_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_payment ADD FOREIGN KEY ("feedback_id_surr") REFERENCES staging.dim_feedback ("feedback_id_surr");

ALTER TABLE staging.fct_payment ADD FOREIGN KEY ("user_id") REFERENCES staging.dim_user ("user_id");

