-- Make sure to fix the path file first, then load the script

COPY "User" (user_name, customer_zip_code, customer_city, customer_state)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\processed\user_no_duplicate.csv' 
DELIMITER ',' 
CSV HEADER;

COPY "Product" (product_id, product_category, product_photos_qty, product_weight_g, product_length_cm,product_height_cm, product_width_cm, product_description_length, product_name_length)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\processed\products_renamed.csv' 
DELIMITER ',' 
CSV HEADER;


COPY "Seller" (seller_id, seller_zip_code, seller_city, seller_state)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\raw\seller_dataset.csv' 
DELIMITER ',' 
CSV HEADER;

COPY "Order" (order_id, user_name, order_status, order_date, order_approved_date, pickup_date, delivered_date, estimated_time_delivery)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\raw\order_dataset.csv' 
DELIMITER ',' 
CSV HEADER;

COPY "Payment" (order_id, payment_sequential, payment_type, payment_installments, payment_value)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\raw\payment_dataset.csv' 
DELIMITER ',' 
CSV HEADER;

COPY "Feedback" (feedback_id, order_id , feedback_score, feedback_form_sent_date, feedback_answer_date)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\raw\feedback_dataset.csv' 
DELIMITER ',' 
CSV HEADER;

COPY "Order_item" (order_id, order_item_id , product_id, seller_id, pickup_limit_date, price, shipping_cost)
FROM 'C:\Users\William\Documents\DataScience\blibli\e-commerce-datsci-proj\data\raw\order_item_dataset.csv' 
DELIMITER ',' 
CSV HEADER;








