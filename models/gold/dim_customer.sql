with customers as (
    select * from {{ ref('stg_crm_customers') }}
),
web as (
    select customer_id, max(event_ts) as last_web_event_ts, count(*) as total_web_events
    from {{ ref('stg_web_events') }}
    group by customer_id
),
tickets as (
    select customer_id,
           count_if(status = 'open') as open_ticket_count,
           count(*) as total_ticket_count
    from {{ ref('stg_support_tickets') }}
    group by customer_id
)
select
    {{ generate_surrogate_key(['customers.customer_id']) }} as customer_sk,
    customers.customer_id,
    customers.first_name,
    customers.last_name,
    customers.email,
    customers.is_valid_email,
    customers.country_code,
    customers.loyalty_status,
    coalesce(web.total_web_events, 0) as total_web_events,
    web.last_web_event_ts,
    coalesce(tickets.open_ticket_count, 0) as open_ticket_count,
    coalesce(tickets.total_ticket_count, 0) as total_ticket_count,
    current_timestamp() as dw_loaded_at
from customers
left join web on customers.customer_id = web.customer_id
left join tickets on customers.customer_id = tickets.customer_id
