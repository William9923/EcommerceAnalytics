{{ config(
    materialized='incremental',
    schema='staging',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key='zip_code'
    ) 
}}

WITH stg_user_geo AS (

    SELECT 
        customer_zip_code AS zip_code, 
        customer_city AS city, 
        customer_state AS state 
    FROM staging.user

),

stg_seller_geo AS (

    SELECT 
        seller_zip_code AS zip_code,
        seller_city AS city,
        seller_state AS state
    FROM staging.seller

), combined AS (

    SELECT *
    FROM stg_user_geo
    UNION 
    SELECT *
    FROM stg_seller_geo

)

-- Only take the last occurence of zipcode data from union geolocation data.
SELECT  zip_code, city, state
FROM    (
        SELECT  *,
                ROW_NUMBER() OVER (PARTITION BY zip_code ORDER BY zip_code DESC) rn
        FROM    combined
        ) q
WHERE   rn = 1

