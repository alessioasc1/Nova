select
    md5(concat(region, category, cast(target_month as string))) as target_key,
    region,
    category as product_category,
    target_month,
    target_amount
from {{ ref('stg_finance_targets') }}