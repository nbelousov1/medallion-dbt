{{ config(unique_key='product_id') }}

with ranked as (
    select
        trim(product_id) as product_id,
        trim(product_name) as product_name,
        trim(category) as category,
        trim(subcategory) as subcategory,
        list_price,
        iff(upper(trim(active_flag)) = 'Y', true, false) as is_active,
        source_updated_at,
        _ingested_at,
        _batch_id,
        _source_file,
        row_number() over (
            partition by trim(product_id)
            order by source_updated_at desc, _ingested_at desc
        ) as rn
    from {{ source('bronze', 'MDM_PRODUCTS_RAW') }}
    {% if is_incremental() %}
      where _ingested_at >= (select coalesce(max(_ingested_at), '1900-01-01'::timestamp_ntz) from {{ this }})
    {% endif %}
)
select
    product_id,
    product_name,
    category,
    subcategory,
    list_price,
    is_active,
    source_updated_at,
    _ingested_at,
    _batch_id,
    _source_file
from ranked
where rn = 1
