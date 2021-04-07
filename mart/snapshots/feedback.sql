{% snapshot feedback_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key="feedback_id||'-'||order_id",
            check_cols=[
                'feedback_score', 
                'feedback_form_sent_date', 
                'feedback_answer_date'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'feedback')}}

{% endsnapshot %}