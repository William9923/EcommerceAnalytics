{{ config(
    materialized='incremental',
    transient=true,
    incremental_strategy='insert_overwrite',
    unique_key="feedback_id||'-'||version"
    ) 
}}

-- Use latest feedback form and answer date
SELECT
    order_id AS feedback_id,
    AVG(feedback_score) AS avg_feedback_score,
    TO_CHAR(MAX(feedback_form_sent_date), 'yyyymmdd')::INT AS feedback_form_sent_date,
    TO_CHAR(MAX(feedback_answer_date), 'yyyymmdd')::INT AS feedback_answer_date,
    ROW_NUMBER() OVER (
        PARTITION BY order_id 
        ORDER BY dbt_valid_from
    ) AS version,
    dbt_valid_to is null as is_current_version

FROM {{ ref('feedback_snapshot')}}
GROUP BY order_id, dbt_valid_from, dbt_valid_to