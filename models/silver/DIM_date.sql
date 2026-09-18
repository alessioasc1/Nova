with date_range as (
    select 
        to_date('2022-01-01') as start_date,
        add_months(trunc(current_date(), 'yyyy'), 24) - interval 1 day as end_date
),

date_spine as (
    select 
        explode(sequence(start_date, end_date, interval 1 day)) as date_day
    from date_range
)

select
    date_day,
    year(date_day) as year,
    quarter(date_day) as quarter,
    month(date_day) as month_number,
    date_format(date_day, 'MMMM') as month_name,
    date_format(date_day, 'MMM') as month_short_name,
    day(date_day) as day_of_month,
    dayofweek(date_day) as day_of_week,
    date_format(date_day, 'EEEE') as day_name,
    weekofyear(date_day) as week_of_year,
    
    trunc(date_day, 'MM') as month_start_date,
    last_day(date_day) as month_end_date,
    cast(date_format(date_day, 'yyyyMM') as int) as year_month_key,
    
    case when dayofweek(date_day) in (1, 7) then true else false end as is_weekend

from date_spine