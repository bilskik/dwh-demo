with date_series as (
    -- Generowanie zakresu dat od 2016 do 2019
    select generate_series(
        '2016-01-01'::date, 
        '2019-12-31'::date, 
        '1 day'::interval
    )::date as date_day
)

select
    date_day as date_key,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    to_char(date_day, 'Month') as month_name,
    extract(day from date_day) as day,
    extract(dow from date_day) as day_of_week, -- 0 (Niedziela) do 6 (Sobota)
    to_char(date_day, 'Day') as day_name,
    extract(quarter from date_day) as quarter,
    case 
        when extract(dow from date_day) in (0, 6) then true 
        else false 
    end as is_weekend
from date_series