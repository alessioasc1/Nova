with source as (
    select * from {{ source('bronze', 'transactions_bronze') }}
),

cleaned as (
    select
        cast(order_id as string) as order_id,
case 
            when lower(trim(cast(transaction_date as string))) = 'today' then current_date()
            else coalesce(
            try_to_date(transaction_date, 'yyyy-MM-dd'),
            try_to_date(transaction_date, 'yyyy/MM/dd'),
            try_to_date(transaction_date, 'dd-MMM-yyyy'),
            try_to_date(transaction_date, 'MM/dd/yyyy'),
            try_to_date(transaction_date, 'dd/MM/yyyy'),

                -- 8. Fallback per timestamp completi (es. 2023-01-17 14:30:00)
                cast(try_to_timestamp(cast(transaction_date as string)) as date)
            )
        end as transaction_date,
        trim(split(customer_info, '\\|')[0]) as customer_name,
        trim(lower(split(customer_info, '\\|')[1])) as customer_email,
        trim(split(customer_info, '\\|')[2]) as customer_phone,

        cast(product_id as string) as product_id,
        trim(product_category) as product_category,
        cast(
            regexp_replace(replace(cast(price as string), ',', ''), '[^0-9.]', '') 
            as decimal(10,2)
        ) as unit_price,
        try_cast(qty as int) as quantity,
        case 
            when trim(cast(discount_pct as string)) = 'N/A' or discount_pct is null then 0.00
            when cast(discount_pct as string) like '%\%' 
                then try_cast(replace(cast(discount_pct as string), '%', '') as decimal(5,2)) / 100.0
            else try_cast(discount_pct as decimal(5,2))
        end as discount_pct

    from source
    where order_id is not null
)

select
    order_id,
    transaction_date,
    customer_name,
    customer_email,
    customer_phone,
    product_id,
    product_category,
    unit_price,
    quantity,
    discount_pct,
    case when quantity < 0 then true else false end as is_return
from cleaned