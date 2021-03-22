{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="user_name||'-'||version"
    ) 
}}

-- Early Projection
WITH stg_snapshot_user AS (

    SELECT 
        user_name, 
        num_order_on_loc, 
        dbt_valid_to,
        dbt_valid_from 
    FROM {{ ref('user_snapshot') }}

), 
-- don't count cancelled orders
stg_snapshot_spending AS (

    SELECT DISTINCT
        {{ ref('order_snapshot') }}.user_name,
        SUM({{ ref('order_item_snapshot') }}.price) + SUM({{ ref('order_item_snapshot') }}.shipping_cost) AS total_spending
    FROM {{ ref('order_snapshot') }} LEFT JOIN {{ ref('order_item_snapshot') }} 
        ON {{ ref('order_snapshot') }}.order_id = {{ ref('order_item_snapshot') }}.order_id 
    WHERE {{ ref('order_snapshot')}}.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY {{ ref('order_snapshot') }}.user_name

) 
-- Aggr it just in case it duplicate
SELECT
    stg_snapshot_user.user_name,
    stg_snapshot_user.num_order_on_loc  AS num_order,
    CASE
        WHEN stg_snapshot_spending.total_spending = NULL THEN 0
        ELSE stg_snapshot_spending.total_spending
    END                                 AS total_spending,
    ROW_NUMBER() OVER (
        PARTITION BY stg_snapshot_user.user_name 
        ORDER BY stg_snapshot_user.dbt_valid_from
    ) AS version,
    stg_snapshot_user.dbt_valid_to is null as is_current_version

FROM stg_snapshot_user INNER JOIN stg_snapshot_spending ON 
    stg_snapshot_user.user_name = stg_snapshot_spending.user_name