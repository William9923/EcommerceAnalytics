{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="product_id||'-'||version"
    ) 
}}
-- don't count cancelled orders
WITH stg_snapshot_rating AS (

    SELECT DISTINCT 
        {{ ref('order_item_snapshot') }}.product_id,
        AVG({{ ref('feedback_snapshot') }}.feedback_score) AS avg_product_feedback
    FROM ({{ ref('order_item_snapshot') }} LEFT JOIN {{ ref('order_snapshot') }} 
        ON {{ ref('order_snapshot') }}.order_id = {{ ref('order_item_snapshot') }}.order_id)
            LEFT JOIN {{ ref('feedback_snapshot') }} ON  {{ ref('order_snapshot') }}.order_id = {{ ref('feedback_snapshot') }}.order_id
    WHERE {{ ref('order_snapshot')}}.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY {{ ref('order_item_snapshot') }}.product_id
    
) 

SELECT
    {{ ref('product_snapshot')}}.product_id,
    {{ ref('product_snapshot')}}.product_name_length,
    {{ ref('product_snapshot')}}.product_description_length,
    {{ ref('product_snapshot')}}.product_photos_qty,
    {{ ref('product_snapshot')}}.product_weight_g,
    {{ ref('product_snapshot')}}.product_length_cm,
    {{ ref('product_snapshot')}}.product_height_cm,
    {{ ref('product_snapshot')}}.product_width_cm,
    CASE
        WHEN stg_snapshot_rating.avg_product_feedback = NULL THEN -1
        ELSE stg_snapshot_rating.avg_product_feedback
    END                                     AS avg_product_feedback,
    ROW_NUMBER() OVER (
        PARTITION BY {{ ref('product_snapshot')}}.product_id 
        ORDER BY {{ ref('product_snapshot')}}.dbt_valid_from
    ) AS version,
    {{ ref('product_snapshot')}}.dbt_valid_to is null as is_current_version

FROM {{ ref('product_snapshot')}} LEFT JOIN stg_snapshot_rating ON 
    {{ ref('product_snapshot')}}.product_id = stg_snapshot_rating.product_id