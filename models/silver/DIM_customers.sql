{{ config(
    materialized='table',
    catalog='workspace',
    schema='silver'
) }}
select 
    customer_email,
    max(customer_name) as customer_name,
    max(customer_phone) as customer_phone
from {{ ref('stg_sales_transactions') }}
where customer_email is not null
group by customer_email