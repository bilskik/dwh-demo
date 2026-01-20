with date_series as (
    select 
        dateadd(day, seq4(), '2016-01-01'::date) as date_day
    from table(generator(rowcount => 1461))
)

select
    date_day as date_key,
    year(date_day) as year,
    month(date_day) as month,
    to_char(date_day, 'MMMM') as month_name,
    day(date_day) as day,
    dayofweek(date_day) as day_of_week,
    to_char(date_day, 'Day') as day_name,
    quarter(date_day) as quarter,
    case 
        when dayofweek(date_day) in (0, 6) then true 
        else false 
    end as is_weekend
from date_series
where date_day <= '2019-12-31'::date