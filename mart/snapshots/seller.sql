{% snapshot seller_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key='seller_id',
            check_cols=[
                'seller_zip_code',
                'seller_city',
                'seller_state'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'seller')}}

{% endsnapshot %}