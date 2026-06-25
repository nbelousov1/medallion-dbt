{{ config(unique_key='ticket_id') }}

with ranked as (
    select
        trim(ticket_id) as ticket_id,
        trim(customer_id) as customer_id,
        created_ts,
        resolved_ts,
        lower(trim(status)) as status,
        lower(trim(priority)) as priority,
        lower(trim(category)) as category,
        source_updated_at,
        _ingested_at,
        _batch_id,
        _source_file,
        row_number() over (
            partition by trim(ticket_id)
            order by source_updated_at desc, _ingested_at desc
        ) as rn
    from {{ source('bronze', 'SUPPORT_TICKETS_RAW') }}
    {% if is_incremental() %}
      where _ingested_at >= (select coalesce(max(_ingested_at), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
select
    ticket_id,
    customer_id,
    created_ts,
    resolved_ts,
    status,
    priority,
    category,
    datediff('hour', created_ts, coalesce(resolved_ts, current_timestamp())) as hours_to_resolution,
    source_updated_at,
    _ingested_at,
    _batch_id,
    _source_file
from ranked
where rn = 1
