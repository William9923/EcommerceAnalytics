{% snapshot user_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key="user_name||'-'||customer_zip_code||'-'||customer_city||'-'||customer_state",
            check_cols=[
                'num_order_on_loc'
            ],
            strategy='check'
        )
    }}

    SELECT 
        user_name, 
        customer_zip_code,  
        customer_city,
        customer_state,
        COUNT(user_name) AS num_order_on_loc
    FROM {{ source('staging', 'user')}}
    GROUP BY (user_name, customer_zip_code,customer_city,customer_state)

{% endsnapshot %}