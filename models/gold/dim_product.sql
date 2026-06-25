select
    {{ generate_surrogate_key(['product_id']) }} as product_sk,
    product_id,
    product_name,
    category,
    subcategory,
    list_price,
    is_active,
    current_timestamp() as dw_loaded_at
from {{ ref('stg_mdm_products') }}
