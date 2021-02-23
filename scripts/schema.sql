DROP TABLE IF EXISTS "Order_item" ;
DROP TABLE IF EXISTS "Payment" ;
DROP TABLE IF EXISTS "Feedback" ;
DROP TABLE IF EXISTS "Order" ;
DROP TABLE IF EXISTS "Seller" ;
DROP TABLE IF EXISTS "Product" ;
DROP TABLE IF EXISTS "User" ;
CREATE TABLE IF NOT EXISTS "User" (
  "user_name" varchar PRIMARY KEY,
  "customer_zip_code" int,
  "customer_city" varchar,
  "customer_state" varchar
);

CREATE TABLE  "Product" (
  "product_id" varchar PRIMARY KEY,
  "product_category" varchar,
  "product_name_length" decimal,
  "product_description_length" decimal,
  "product_photos_qty" decimal,
  "product_weight_g" decimal,
  "product_length_cm" decimal,
  "product_height_cm" decimal,
  "product_width_cm" decimal
);

CREATE TABLE IF NOT EXISTS "Seller" (
  "seller_id" varchar PRIMARY KEY,
  "seller_zip_code" int,
  "seller_city" varchar,
  "seller_state" varchar
);

CREATE TABLE IF NOT EXISTS "Feedback" (
  "feedback_id" varchar,
  "order_id" varchar,
  "feedback_score" decimal,
  "feedback_form_sent_date" timestamp,
  "feedback_answer_date" timestamp,
  PRIMARY KEY ("feedback_id", "order_id")
);

CREATE TABLE IF NOT EXISTS "Order_item" (
  "order_id" varchar,
  "order_item_id" int,
  "product_id" varchar,
  "seller_id" varchar,
  "pickup_limit_date" timestamp,
  "price" decimal,
  "shipping_cost" decimal,
  PRIMARY KEY ("order_id", "order_item_id")
);

CREATE TABLE IF NOT EXISTS "Payment" (
  "order_id" varchar,
  "payment_sequential" int,
  "payment_type" varchar,
  "payment_installments" int,
  "payment_value" decimal,
  PRIMARY KEY ("order_id", "payment_sequential")
);

CREATE TABLE IF NOT EXISTS "Order" (
  "order_id" varchar PRIMARY KEY,
  "user_name" varchar,
  "order_status" varchar,
  "order_date" timestamp,
  "order_approved_date" timestamp,
  "pickup_date" timestamp,
  "delivered_date" timestamp,
  "estimated_time_delivery" timestamp
);

ALTER TABLE "Order" ADD FOREIGN KEY ("user_name") REFERENCES "User" ("user_name");

ALTER TABLE "Feedback" ADD FOREIGN KEY ("order_id") REFERENCES "Order" ("order_id");

ALTER TABLE "Payment" ADD FOREIGN KEY ("order_id") REFERENCES "Order" ("order_id");

ALTER TABLE "Order_item" ADD FOREIGN KEY ("order_id") REFERENCES "Order" ("order_id");

ALTER TABLE "Order_item" ADD FOREIGN KEY ("product_id") REFERENCES "Product" ("product_id");

ALTER TABLE "Order_item" ADD FOREIGN KEY ("seller_id") REFERENCES "Seller" ("seller_id");