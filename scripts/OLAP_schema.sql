CREATE TABLE "User_dim" (
  "user_id" serial PRIMARY KEY,
  "user_name" varchar,
  "total_order" decimal,
  "total_spending" decimal,
  "flag" int
);

CREATE TABLE "Product_dim" (
  "product_id_surr" serial PRIMARY KEY,
  "product_id" varchar,
  "product_category" int,
  "product_name_length" int,
  "product_description_length" int,
  "product_photos_qty" int,
  "product_weight_g" decimal,
  "product_height_cm" decimal,
  "product_width_cm" decimal,
  "flag" int
);

CREATE TABLE "Seller_dim" (
  "seller_id_surr" serial PRIMARY KEY, 
  "seller_id" varchar,
  "seller_zip_code" int,
  "flag" int
);

CREATE TABLE "Feedback_dim" (
  "feedback_id_surr" integer PRIMARY KEY,
  "feedback_avg_score" decimal,
  "feedback_form_sent_date" timestamp,
  "feedback_answer_date" timestamp,
  "flag" int
);

CREATE TABLE "Payment_dim" (
  "payment_id" integer PRIMARY KEY,
  "num_payment" integer,
  "payment_type" varchar,
  "payment_installments" varchar,
  "payment_total_value" decimal
);

CREATE TABLE "Date_dim" (
  "date_id" integer PRIMARY KEY,
  "day" integer,
  "day_name" varchar,
  "week" int,
  "month" int,
  "quarter" int,
  "year" int,
  "isWeekDay" boolean
);

CREATE TABLE "Geo_dim" (
  "zip_code" varchar PRIMARY KEY,
  "city" varchar,
  "state" varchar
);

CREATE TABLE "Fact_OrderItems" (
  "id" integer PRIMARY KEY,
  "user_id" integer,
  "product_id_surr" integer,
  "seller_id_surr" integer,
  "feedback_id_surr" integer,
  "payment_id" integer,
  "order_date" int,
  "order_approved_date" int,
  "pickup_date" int,
  "delivered_date" int,
  "estimated_time_delivery" int,
  "pickup_limit_date" int,
  "order_id" varchar,
  "order_item_status" varchar,
  "price" decimal,
  "shipping_cost" decimal
);

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("user_id") REFERENCES "User_dim" ("user_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("product_id_surr") REFERENCES "Product_dim" ("product_id_surr");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("seller_id_surr") REFERENCES "Seller_dim" ("seller_id_surr");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("feedback_id_surr") REFERENCES "Feedback_dim" ("feedback_id_surr");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("payment_id") REFERENCES "Payment_dim" ("payment_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("order_date") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("order_approved_date") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("pickup_date") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("delivered_date") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("estimated_time_delivery") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Fact_OrderItems" ADD FOREIGN KEY ("pickup_limit_date") REFERENCES "Date_dim" ("date_id");

ALTER TABLE "Seller_dim" ADD FOREIGN KEY ("seller_zip_code") REFERENCES "Geo_dim" ("zip_code");

