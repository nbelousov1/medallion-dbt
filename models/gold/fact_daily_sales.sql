select
    order_date,
    currency,
    count(distinct order_id) as order_count,
    count(*) as order_line_count,
    sum(quantity) as total_quantity,
    sum(line_amount) as total_sales_amount,
    avg(line_amount) as avg_line_amount,
    current_timestamp() as dw_loaded_at
from {{ ref('fact_order_line') }}
group by order_date, currency
