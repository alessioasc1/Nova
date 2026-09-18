select
    review_id,
    product_id,
    customer_email,
    review_datetime,
    review_date,
    customer_country,
    customer_city,
    rating,
    review_text
from {{ ref('stg_web_reviews') }}