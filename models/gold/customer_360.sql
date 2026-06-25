with customer as (
    select * from {{ ref('dim_customer') }}
),
orders as (
    select
        customer_id,
        count(distinct order_id) as lifetime_orders,
        sum(line_amount) as lifetime_revenue,
        max(order_ts) as last_order_ts
    from {{ ref('fact_order_line') }}
    group by customer_id
)
select
    customer.customer_sk,
    customer.customer_id,
    customer.first_name,
    customer.last_name,
    customer.email,
    customer.country_code,
    customer.loyalty_status,
    customer.is_valid_email,
    customer.total_web_events,
    customer.last_web_event_ts,
    customer.open_ticket_count,
    customer.total_ticket_count,
    coalesce(orders.lifetime_orders, 0) as lifetime_orders,
    coalesce(orders.lifetime_revenue, 0) as lifetime_revenue,
    orders.last_order_ts,
    current_timestamp() as dw_loaded_at
from customer
left join orders on customer.customer_id = orders.customer_id
