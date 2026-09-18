    select
        target_month as month_start_date,
        product_category,
        region, 
        sum(target_amount) as target_revenue
    from {{ ref('FACT_targets') }}
    group by 1, 2, 3
