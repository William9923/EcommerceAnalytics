{% snapshot product_snapshot %}

    {{
        config(
            target_database='ecommerce',
            target_schema='staging',
            unique_key='product_id',
            check_cols=[
                'product_category', 
                'product_name_length', 
                'product_description_length', 
                'product_photos_qty', 
                'product_weight_g', 
                'product_length_cm', 
                'product_height_cm',
                'product_width_cm'
            ],
            strategy='check'
        )
    }}

    SELECT * FROM {{ source('staging', 'product')}}

{% endsnapshot %}