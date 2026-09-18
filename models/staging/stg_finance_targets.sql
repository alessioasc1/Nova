{% set relation = source('bronze', 'targets_bronze') %}
{% set target_cols = [] %}
{% if execute %}
    {% set all_columns = adapter.get_columns_in_relation(relation) %}
    {% for col in all_columns %}
        {% set col_name = col.name.lower() %}
        {% if col_name not in ['region', 'category'] and not col_name.startswith('_') %}
            {% do target_cols.append(col.name) %}
        {% endif %}
    {% endfor %}
{% endif %}

with source as (
    select * from {{ relation }}
),

unpivoted as (
    select
        trim(Region) as region,
        trim(Category) as category,
        month_col as month_str,
        cast(replace(cast(target_value as string), ',', '') as decimal(12,2)) as target_amount
    from source
    {% if execute and target_cols | length > 0 %}
    unpivot (
        target_value for month_col in (
            {% for col_name in target_cols %}
                `{{ col_name }}`{% if not loop.last %}, {% endif %}
            {% endfor %}
        )
    )
    {% else %}
    unpivot (
        target_value for month_col in (`Jan-23`)
    )
    {% endif %}
)

select
    region,
    category,
    case 
        when month_str like 'target_%' then to_date(replace(month_str, 'target_', ''), 'yyyy_MM')
        else to_date(concat('01-', month_str), 'dd-MMM-yy')
    end as target_month,
    target_amount
from unpivoted