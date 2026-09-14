select
    order_id,
    transaction_date,
    customer_email,
    product_id,
    unit_price,
    quantity,
    discount_pct,
    is_return
from {{ ref('stg_sales_transactions') }}