with products as (
    select * from {{ source('olist_raw', 'products') }}
),
translations as (
    select * from {{ source('olist_raw', 'product_category_name_translation') }}
)

select
    p.product_id,
    coalesce(t.product_category_name_english, p.product_category_name) as category_name,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
from products p
left join translations t on p.product_category_name = t.product_category_name