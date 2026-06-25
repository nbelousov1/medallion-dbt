with orders as (
    select * from {{ ref('stg_erp_orders') }}
),
customers as (
    select customer_id, customer_sk from {{ ref('dim_customer') }}
),
products as (
    select product_id, product_sk from {{ ref('dim_product') }}
)
select
    {{ generate_surrogate_key(['orders.order_line_id']) }} as order_line_sk,
    customers.customer_sk,
    products.product_sk,
    orders.order_id,
    orders.order_line_id,
    orders.customer_id,
    orders.product_id,
    to_date(orders.order_ts) as order_date,
    orders.order_ts,
    orders.quantity,
    orders.unit_price,
    orders.line_amount,
    orders.currency,
    orders.order_status,
    current_timestamp() as dw_loaded_at
from orders
left join customers on orders.customer_id = customers.customer_id
left join products on orders.product_id = products.product_id
