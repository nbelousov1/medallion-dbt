{{ config(unique_key='customer_id') }}

with ranked as (
    select
        trim(customer_id) as customer_id,
        initcap(trim(first_name)) as first_name,
        initcap(trim(last_name)) as last_name,
        lower(trim(email)) as email,
        upper(trim(country_code)) as country_code,
        lower(trim(loyalty_status)) as loyalty_status,
        source_updated_at,
        _ingested_at,
        _batch_id,
        _source_file,
        row_number() over (
            partition by trim(customer_id)
            order by source_updated_at desc, _ingested_at desc
        ) as rn
    from {{ source('bronze', 'CRM_CUSTOMERS_RAW') }}
    {% if is_incremental() %}
      where _ingested_at >= (select coalesce(max(_ingested_at), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
select
    customer_id,
    first_name,
    last_name,
    email,
    case when regexp_like(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') then true else false end as is_valid_email,
    case when country_code in ('CZ','SK','RO','PL','DE','AT') then country_code else 'UNK' end as country_code,
    loyalty_status,
    source_updated_at,
    _ingested_at,
    _batch_id,
    _source_file
from ranked
where rn = 1
