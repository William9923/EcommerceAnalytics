{% snapshot payment_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key="order_id||'-'||payment_sequential",
            check_cols=[
                'payment_type', 
                'payment_installments', 
                'payment_value'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'payment')}}

{% endsnapshot %}