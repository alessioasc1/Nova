with source as (
    select * from {{ source('bronze', 'reviews_bronze') }}
),

cleaned as (
    select
        cast(review_id as string) as review_id,
        cast(product_ref as string) as product_id,
        trim(lower(get_json_object(user, '$.email'))) as customer_email,
        trim(get_json_object(user, '$.location.country')) as customer_country,
        trim(get_json_object(user, '$.location.city')) as customer_city,
        case 
            when length(cast(timestamp as string)) > 10 
                then to_timestamp(try_cast(timestamp as bigint) / 1000)
            else to_timestamp(try_cast(timestamp as bigint))
        end as review_datetime,
        cast(
            case 
                when length(cast(timestamp as string)) > 10 
                    then to_timestamp(try_cast(timestamp as bigint) / 1000)
                else to_timestamp(try_cast(timestamp as bigint))
            end as date
        ) as review_date,
        case 
            when try_cast(rating as int) between 1 and 5 then try_cast(rating as int)
            else null 
        end as rating,

        trim(review_text) as review_text

    from source
    where review_id is not null
)

select *
from cleaned
where rating is not null