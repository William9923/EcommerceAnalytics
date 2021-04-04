{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="order_id||'-'||order_item_id"
    ) 
}}

SELECT
    {{ ref('order_item_snapshot') }}.order_id AS order_id,
    {{ ref('order_item_snapshot') }}.order_item_id AS order_item_id,
    {{ ref('order_item_snapshot') }}.product_id,
    {{ ref('order_item_snapshot') }}.seller_id,
    {{ ref('order_snapshot') }}.order_id AS feedback_id,
    {{ ref('order_snapshot') }}.order_id AS payment_id,
    {{ ref('order_snapshot') }}.user_name AS user_name,
    {{ ref('order_snapshot') }}.order_status AS order_item_status,
    TO_CHAR({{ ref('order_item_snapshot') }}.pickup_limit_date, 'yyyymmdd')::INT AS pickup_limit_date,
    TO_CHAR({{ ref('order_snapshot') }}.order_date, 'yyyymmdd')::INT AS order_date,
    TO_CHAR({{ ref('order_snapshot') }}.order_approved_date, 'yyyymmdd')::INT AS order_approved_date,
    TO_CHAR({{ ref('order_snapshot') }}.pickup_date, 'yyyymmdd')::INT AS pickup_date,
    TO_CHAR({{ ref('order_snapshot') }}.delivered_date, 'yyyymmdd')::INT AS delivered_date,
    TO_CHAR({{ ref('order_snapshot') }}.estimated_time_delivery, 'yyyymmdd')::INT AS estimated_time_delivery,
    {{ ref('order_item_snapshot') }}.price,
    {{ ref('order_item_snapshot') }}.shipping_cost
FROM {{ ref('order_item_snapshot') }} 
    LEFT JOIN {{ ref('order_snapshot') }} 
        ON {{ ref('order_item_snapshot') }}.order_id = {{ ref('order_snapshot') }}.order_id
    -- LEFT JOIN {{ ref('dim_product') }} 
    --     ON {{ ref('order_item_snapshot') }}.product_id = {{ ref('dim_product') }}.product_id 
    -- LEFT JOIN {{ ref('dim_user') }}
    --     ON {{ ref('order_snapshot') }}.user_name = {{ ref('dim_user') }}.user_name 
    -- LEFT JOIN {{ ref('dim_seller') }}
    --     ON {{ ref('order_item_snapshot') }}.seller_id = {{ ref('dim_seller') }}.seller_id 
    -- LEFT JOIN {{ ref('dim_feedback') }}
    --     ON {{ ref('order_snapshot') }}.order_id = {{ ref('feedback_snapshot') }}.feedback_id 
    -- LEFT JOIN {{ ref('dim_payment') }}
    --     ON {{ ref('order_snapshot') }}.order_id = {{ ref('dim_payment') }}.payment_id
WHERE {{ ref('order_snapshot') }}.dbt_valid_to IS NULL 
    AND {{ ref('order_item_snapshot') }}.dbt_valid_to IS NULL