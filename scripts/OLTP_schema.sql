DROP TABLE IF EXISTS staging.feedback;
DROP TABLE IF EXISTS staging.payment;
DROP TABLE IF EXISTS staging.order_item;
DROP TABLE IF EXISTS staging.order;
DROP TABLE IF EXISTS staging.seller;
DROP TABLE IF EXISTS staging.product;
DROP TABLE IF EXISTS staging.user;


CREATE TABLE staging.user (
  "user_name" varchar,
  "customer_zip_code" varchar,
  "customer_city" varchar,
  "customer_state" varchar
);

CREATE TABLE staging.product (
  "product_id" varchar PRIMARY KEY,
  "product_category" varchar,
  "product_name_length" int,
  "product_description_length" int,
  "product_photos_qty" int,
  "product_weight_g" decimal,
  "product_length_cm" decimal,
  "product_height_cm" decimal,
  "product_width_cm" decimal
);

CREATE TABLE staging.seller (
  "seller_id" varchar PRIMARY KEY,
  "seller_zip_code" int,
  "seller_city" varchar,
  "seller_state" varchar
);

CREATE TABLE staging.order (
  "order_id" varchar PRIMARY KEY,
  "user_name" varchar,
  "order_status" varchar,
  "order_date" timestamp,
  "order_approved_date" timestamp,
  "pickup_date" timestamp,
  "delivered_date" timestamp,
  "estimated_time_delivery" timestamp
);

CREATE TABLE staging.order_item (
  "order_id" varchar,
  "order_item_id" int,
  "product_id" varchar,
  "seller_id" varchar,
  "pickup_limit_date" timestamp,
  "price" decimal,
  "shipping_cost" decimal,
  PRIMARY KEY ("order_id", "order_item_id")
);

CREATE TABLE staging.payment (
  "order_id" varchar,
  "payment_sequential" int,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" decimal,
  PRIMARY KEY ("order_id", "payment_sequential")
);

CREATE TABLE staging.feedback (
  "feedback_id" varchar,
  "order_id" varchar,
  "feedback_score" decimal,
  "feedback_form_sent_date" timestamp,
  "feedback_answer_date" timestamp,
  PRIMARY KEY ("feedback_id", "order_id")
);

ALTER TABLE staging.order_item ADD FOREIGN KEY ("product_id") REFERENCES staging.product ("product_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE staging.order_item ADD FOREIGN KEY ("seller_id") REFERENCES staging.seller ("seller_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE staging.order_item ADD FOREIGN KEY ("order_id") REFERENCES staging.order ("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE staging.payment ADD FOREIGN KEY ("order_id") REFERENCES staging.order ("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE staging.feedback ADD FOREIGN KEY ("order_id") REFERENCES staging.order ("order_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

