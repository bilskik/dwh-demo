with orders as (
    select * from {{ source('olist_raw', 'orders') }}
),
items as (
    select * from {{ source('olist_raw', 'order_items') }}
),
customers as (
    select customer_id, customer_unique_id from {{ source('olist_raw', 'customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['items.order_id', 'items.order_item_id']) }} as order_item_key,
    items.order_id,
    c.customer_unique_id,
    items.product_id,
    items.seller_id,
    -- Daty
    orders.order_purchase_timestamp,
    orders.order_delivered_customer_date,
    orders.order_estimated_delivery_date,
    -- Miary
    items.price,
    items.freight_value,
    -- Status
    orders.order_status,
    -- Wyliczenia logistyczne
    extract(day from (orders.order_delivered_customer_date - orders.order_purchase_timestamp)) as actual_delivery_days,
    extract(day from (orders.order_estimated_delivery_date - orders.order_delivered_customer_date)) as delivery_delta_days
from items
join {{ ref('dim_orders') }} orders  on items.order_id = orders.order_id
join customers c on orders.customer_id = c.customer_id