{% snapshot order_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key='order_id',
            check_cols=[
                'user_name', 
                'order_status', 
                'order_date', 
                'order_approved_date', 
                'pickup_date', 
                'delivered_date', 
                'estimated_time_delivery'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'order')}}

{% endsnapshot %}