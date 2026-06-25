{{ config(unique_key='order_line_id') }}

with ranked as (
    select
        trim(order_id) as order_id,
        trim(order_line_id) as order_line_id,
        trim(customer_id) as customer_id,
        trim(product_id) as product_id,
        order_ts,
        quantity,
        unit_price,
        upper(trim(currency)) as currency,
        lower(trim(order_status)) as order_status,
        source_updated_at,
        _ingested_at,
        _batch_id,
        _source_file,
        row_number() over (
            partition by trim(order_line_id)
            order by source_updated_at desc, _ingested_at desc
        ) as rn
    from {{ source('bronze', 'ERP_ORDERS_RAW') }}
    {% if is_incremental() %}
      where _ingested_at >= (select coalesce(max(_ingested_at), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
select
    order_id,
    order_line_id,
    customer_id,
    product_id,
    order_ts,
    quantity,
    unit_price,
    quantity * unit_price as line_amount,
    currency,
    order_status,
    source_updated_at,
    _ingested_at,
    _batch_id,
    _source_file
from ranked
where rn = 1
  and quantity > 0
  and unit_price >= 0
