{{ config(unique_key='event_id') }}

with ranked as (
    select
        trim(event_id) as event_id,
        trim(customer_id) as customer_id,
        trim(session_id) as session_id,
        event_ts,
        lower(trim(event_type)) as event_type,
        trim(page_url) as page_url,
        lower(trim(device_type)) as device_type,
        source_updated_at,
        _ingested_at,
        _batch_id,
        _source_file,
        row_number() over (
            partition by trim(event_id)
            order by source_updated_at desc, _ingested_at desc
        ) as rn
    from {{ source('bronze', 'WEB_EVENTS_RAW') }}
    {% if is_incremental() %}
      where _ingested_at >= (select coalesce(max(_ingested_at), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
select
    event_id,
    customer_id,
    session_id,
    event_ts,
    event_type,
    page_url,
    device_type,
    source_updated_at,
    _ingested_at,
    _batch_id,
    _source_file
from ranked
where rn = 1
  and event_ts is not null
