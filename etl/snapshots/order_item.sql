{% snapshot order_item_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key="order_id||'-'||order_item_id",
            check_cols=[
                'product_id', 
                'seller_id', 
                'pickup_limit_date',
                'price',
                'shipping_cost'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'order_item') }}

{% endsnapshot %}