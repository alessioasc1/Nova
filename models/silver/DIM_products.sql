with products_from_sales as (
    select distinct 
        product_id,
        product_category
    from {{ ref('stg_sales_transactions') }}
    where product_id is not null
),

products_from_reviews as (
    select distinct 
        product_id
    from {{ ref('stg_web_reviews') }}
    where product_id is not null
)

select
    coalesce(s.product_id, r.product_id) as product_id,
    s.product_category
from products_from_sales s
full outer join products_from_reviews r on s.product_id = r.product_id