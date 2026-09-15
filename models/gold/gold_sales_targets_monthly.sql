with sales_data as (
    select
        trunc(t.transaction_date, 'MM') as month_start_date,
        p.product_category,
        cast(null as string) as region, -- Le vendite non hanno regione nativa
        sum(t.quantity * t.unit_price * (1 - coalesce(t.discount_pct, 0))) as actual_revenue,
        0 as target_revenue,
        sum(t.quantity * t.unit_price * (1 - coalesce(t.discount_pct, 0)) * 0.30) as total_profit,
        count(distinct t.order_id) as total_orders
    from {{ ref('FACT_transactions') }} t
    join {{ ref('DIM_products') }} p on t.product_id = p.product_id
    group by 1, 2
),

target_data as (
    select
        target_month as month_start_date,
        product_category,
        region, -- Mantiene la regione specifica impostata da Finance
        0 as actual_revenue,
        sum(target_amount) as target_revenue,
        0 as total_profit,
        0 as total_orders
    from {{ ref('FACT_targets') }}
    group by 1, 2, 3
)

select * from sales_data
union all
select * from target_data