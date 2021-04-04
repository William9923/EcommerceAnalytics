{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="seller_id||'-'||version"
    ) 
}}
-- don't count cancelled orders
WITH stg_snapshot_revenue AS (

    SELECT DISTINCT
        {{ ref('order_item_snapshot') }}.seller_id,
        COUNT(DISTINCT {{ ref('order_snapshot') }}.order_id) AS num_order,
        SUM({{ ref('order_item_snapshot') }}.price) AS total_revenue
    FROM {{ ref('order_snapshot') }} LEFT JOIN {{ ref('order_item_snapshot') }} 
        ON {{ ref('order_snapshot') }}.order_id = {{ ref('order_item_snapshot') }}.order_id 
    WHERE {{ ref('order_snapshot')}}.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY {{ ref('order_item_snapshot') }}.seller_id

) 
-- Aggr it just in case it duplicate
SELECT
    {{ ref('seller_snapshot')}}.seller_id,
    {{ ref('seller_snapshot')}}.seller_zip_code,
    CASE
        WHEN stg_snapshot_revenue.num_order = NULL THEN 0
        ELSE stg_snapshot_revenue.num_order 
    END                                 AS num_order,
    CASE
        WHEN stg_snapshot_revenue.total_revenue = NULL THEN 0
        ELSE stg_snapshot_revenue.total_revenue
    END                                 AS total_revenue,
    ROW_NUMBER() OVER (
        PARTITION BY {{ ref('seller_snapshot')}}.seller_id 
        ORDER BY {{ ref('seller_snapshot')}}.dbt_valid_from
    ) AS version,
    {{ ref('seller_snapshot')}}.dbt_valid_to is null as is_current_version
FROM {{ ref('seller_snapshot')}} LEFT JOIN stg_snapshot_revenue 
    ON {{ ref('seller_snapshot')}}.seller_id = stg_snapshot_revenue.seller_id 
