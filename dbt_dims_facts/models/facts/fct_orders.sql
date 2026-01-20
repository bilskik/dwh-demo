with orders as (
    select * from {{ source('ecommerce_raw', 'orders') }}
),
items_agg as (
    select 
        order_id,
        count(order_item_id) as total_items,
        sum(price) as total_price_value,
        sum(freight_value) as total_freight_value
    from {{ source('ecommerce_raw', 'order_items') }}
    group by 1
),
payments_agg as (
    select 
        order_id,
        sum(payment_value) as total_payment_value,
        max(payment_installments) as max_installments
    from {{ source('ecommerce_raw', 'order_payments') }}
    group by 1
)

select
    o.order_id,
    o.customer_id,
    o.order_status,
    -- Timestamps
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_customer_date,
    -- Miary finansowe
    coalesce(i.total_items, 0) as items_count,
    coalesce(i.total_price_value, 0) as order_value,
    coalesce(i.total_freight_value, 0) as freight_value,
    coalesce(p.total_payment_value, 0) as total_paid_amount,
    p.max_installments,
    -- Logika biznesowa (KPI)
    case 
        when o.order_status = 'delivered' then 1 
        else 0 
    end as is_completed,
    case 
        when o.order_delivered_customer_date > o.order_estimated_delivery_date then 1 
        else 0 
    end as is_late_delivery,
    -- Czas procesowania w godzinach (Snowflake DATEDIFF)
    -- Dzielimy przez 3600.0 (z kropką), aby wymusić typ float i nie stracić minut/sekund
    datediff(second, o.order_purchase_timestamp, o.order_approved_at) / 3600.0 as hours_to_approval
from {{ ref('dim_orders') }} o
left join items_agg i on o.order_id = i.order_id
left join payments_agg p on o.order_id = p.order_id