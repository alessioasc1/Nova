select
    order_id,
    coalesce(transaction_date, cast('2022-01-01' as date)) as transaction_date,
    product_id,
    customer_email,
    quantity,
    unit_price,
    discount_pct
from {{ ref('stg_sales_transactions') }}