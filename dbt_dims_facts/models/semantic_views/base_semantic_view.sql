{{ config(materialized='semantic_view') }}

tables (
    CUSTOMERS as {{ source('ecommerce_raw', 'customers') }} primary key (customer_id),
    GEOLOCATION as {{ source('ecommerce_raw', 'geolocation') }} primary key (geolocation_zip_code_prefix),
    ORDERS as {{ source('ecommerce_raw', 'orders') }} primary key (order_id),
    ORDER_ITEMS as {{ source('ecommerce_raw', 'order_items') }} primary key (order_id, order_item_id),
    ORDER_PAYMENTS as {{ source('ecommerce_raw', 'order_payments') }} primary key (order_id, payment_sequential),
    ORDER_REVIEWS as {{ source('ecommerce_raw', 'order_reviews') }} primary key (review_id),
    PRODUCTS as {{ source('ecommerce_raw', 'products') }} primary key (product_id),
    SELLERS as {{ source('ecommerce_raw', 'sellers') }} primary key (seller_id),
    CATEGORY_TRANSLATION as {{ source('ecommerce_raw', 'product_category_name_translation') }} primary key (product_category_name)
)

relationships (
    ORDER_TO_CUSTOMER as ORDERS(customer_id) references CUSTOMERS(customer_id),
    ITEM_TO_ORDER as ORDER_ITEMS(order_id) references ORDERS(order_id),
    ITEM_TO_PRODUCT as ORDER_ITEMS(product_id) references PRODUCTS(product_id),
    ITEM_TO_SELLER as ORDER_ITEMS(seller_id) references SELLERS(seller_id),
    PAYMENT_TO_ORDER as ORDER_PAYMENTS(order_id) references ORDERS(order_id),
    REVIEW_TO_ORDER as ORDER_REVIEWS(order_id) references ORDERS(order_id),
    PRODUCT_TO_TRANSLATION as PRODUCTS(product_category_name) references CATEGORY_TRANSLATION(product_category_name),
    CUSTOMER_TO_GEO as CUSTOMERS(customer_zip_code_prefix) references GEOLOCATION(geolocation_zip_code_prefix)
)

facts (
    ORDER_ITEMS.price as price
        WITH SYNONYMS = ('unit price', 'item cost', 'listing price', 'item price'),
    ORDER_ITEMS.freight_value as freight_value
        WITH SYNONYMS = ('shipping fee', 'delivery charge', 'transport cost', 'item freight value'),
    ORDER_PAYMENTS.payment_value as payment_value
        WITH SYNONYMS = ('transaction amount', 'paid value', 'amount charged', 'total payment value'),
    ORDER_REVIEWS.review_score as review_score
        WITH SYNONYMS = ('stars', 'feedback score', 'customer sentiment', 'review rating'),
    PRODUCTS.product_weight_g as product_weight_g
        WITH SYNONYMS = ('mass', 'heaviness', 'product weight')
)

dimensions (
    CUSTOMERS.customer_unique_id as customer_unique_id
        WITH SYNONYMS = ('unique customer id', 'buyer id', 'customer tax id', 'client identity'),
    CUSTOMERS.customer_city as customer_city
        WITH SYNONYMS = ('buyer city', 'customer location', 'residence city'),
    CUSTOMERS.customer_state as customer_state
        WITH SYNONYMS = ('buyer state', 'customer region', 'province'),
    
    ORDERS.order_status as order_status
        WITH SYNONYMS = ('shipment state', 'order progress', 'fulfillment stage'),
    ORDERS.order_purchase_timestamp as order_purchase_timestamp
        WITH SYNONYMS = ('purchase at', 'order date', 'transaction time', 'buying moment'),
    ORDERS.order_delivered_customer_date as order_delivered_customer_date
        WITH SYNONYMS = ('delivered at', 'arrival date', 'received date', 'delivery completion'),
    ORDERS.order_estimated_delivery_date as order_estimated_delivery_date
        WITH SYNONYMS = ('estimated delivery at', 'expected arrival', 'eta', 'promised date'),
    
    PRODUCTS.product_id as product_id
        WITH SYNONYMS = ('sku', 'item code', 'product reference'),
    CATEGORY_TRANSLATION.product_category_name_english as product_category_name_english
        WITH SYNONYMS = ('product category', 'department', 'item type', 'product group'),
    
    SELLERS.seller_city as seller_city
        WITH SYNONYMS = ('vendor city', 'shop location', 'origin city'),
    SELLERS.seller_state as seller_state
        WITH SYNONYMS = ('vendor state', 'merchant region'),
    
    ORDER_PAYMENTS.payment_type as payment_type
        WITH SYNONYMS = ('payment method', 'payment mode', 'how they paid', 'card or cash')
)
