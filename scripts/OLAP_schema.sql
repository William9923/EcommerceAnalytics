DROP TABLE IF EXISTS staging.fct_order_items;
DROP TABLE IF EXISTS staging.dim_user;
DROP TABLE IF EXISTS staging.dim_product;
DROP TABLE IF EXISTS staging.dim_seller;
DROP TABLE IF EXISTS staging.dim_date;
DROP TABLE IF EXISTS staging.dim_time;

CREATE TABLE staging.dim_user (
  "user_key" serial PRIMARY KEY,
  "user_name" varchar,
  "customer_zip_code" varchar,
  "customer_city" varchar,
  "customer_state" varchar,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_product (
  "product_key" serial PRIMARY KEY,
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
  "seller_key" serial PRIMARY KEY, 
  "seller_id" varchar,
  "seller_zip_code" int,
  "seller_city" varchar,
  "seller_state" varchar,
  "is_current_version" boolean
);

CREATE TABLE staging.dim_date (
  "date_id" integer PRIMARY KEY,
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

CREATE TABLE staging.dim_time (
  "time_id" smallint PRIMARY KEY,
  "hour" smallint,
  "quarter_hour" varchar,
  "minute" smallint,
  "daytime" varchar,
  "daynight" varchar
);

CREATE TABLE staging.fct_order_items (
  "order_id" varchar,
  "order_item_id" integer,
  "user_key" integer,
  "product_key" integer,
  "seller_key" integer,
  "order_date" integer,
  "order_time" smallint,
  "order_approved_date" integer,
  "order_approved_time" smallint,
  "pickup_date" integer,
  "pickup_time" smallint,
  "delivered_date" integer,
  "delivered_time" smallint,
  "estimated_date_delivery" integer,
  "estimated_time_delivery" smallint,
  "pickup_limit_date" integer,
  "pickup_limit_time" smallint,
  "order_item_status" varchar,
  "price" decimal,
  "shipping_cost" decimal,
  "num_payment" int, 
  "total_payment_value" decimal,
  "total_payment_installment" int,
  "num_credit_card" int,
  "total_payment_credit_card" decimal,
  "num_blipay" int,
  "total_payment_blipay" decimal,
  "num_voucher" int,
  "total_payment_voucher" decimal,
  "num_debit" int,
  "total_payment_debit" decimal,
  "num_unknown" int,
  "total_payment_unknown" decimal,
  "lifetime_order" decimal,
  "lifetime_spending" decimal,
  PRIMARY KEY("order_id", "order_item_id")
);

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("user_key") REFERENCES staging.dim_user ("user_key");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("product_key") REFERENCES staging.dim_product ("product_key");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("seller_key") REFERENCES staging.dim_seller ("seller_key");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_approved_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("delivered_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("estimated_date_delivery") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_limit_date") REFERENCES staging.dim_date ("date_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_time") REFERENCES staging.dim_time ("time_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("order_approved_time") REFERENCES staging.dim_time ("time_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_time") REFERENCES staging.dim_time ("time_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("delivered_time") REFERENCES staging.dim_time ("time_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("estimated_time_delivery") REFERENCES staging.dim_time ("time_id");

ALTER TABLE staging.fct_order_items ADD FOREIGN KEY ("pickup_limit_time") REFERENCES staging.dim_time ("time_id");
