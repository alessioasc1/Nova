with daily_base as (
    select
        t.transaction_date,
        p.product_id,
        p.product_category,
        sum(t.quantity * t.unit_price * (1 - coalesce(t.discount_pct, 0))) as actual_revenue,
        sum(t.quantity * t.unit_price * (1 - coalesce(t.discount_pct, 0)) * 0.30) as total_profit,
        count(distinct t.order_id) as total_orders
    from {{ ref('FACT_transactions') }} t
    join {{ ref('DIM_products') }} p on t.product_id = p.product_id
    group by 1, 2, 3
)

select
    transaction_date,
    product_id,
    product_category,
    actual_revenue,
    total_profit,
    total_orders
from daily_base