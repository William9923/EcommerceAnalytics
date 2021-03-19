{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="order_id"
    ) 
}}

-- Use latest feedback form and answer date
SELECT
    order_id AS payment_id,
    payment_type,
    COUNT(payment_installments) AS num_payment,
    SUM(payment_value) AS total_payment_value,
    dbt_valid_to is null as is_current_version

FROM {{ ref('payment_snapshot')}}
GROUP BY order_id, payment_type, dbt_valid_to