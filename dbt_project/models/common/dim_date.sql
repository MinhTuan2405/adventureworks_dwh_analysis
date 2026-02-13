{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh', 'dimension'],
    location = 's3://lakehouse/warehouse/dim_date.parquet'
  ) 
}}

{%- set start_date = '2000-01-01' -%}
{%- set end_date = '2030-12-31' -%}

with date_spine as (
    {{ dbt_date.get_date_dimension(start_date, end_date) }}
)

, date_details as (
    select
        -- Primary key (integer format YYYYMMDD)
        cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
        
        -- Full date attributes
        date_day as full_date,
        
        -- Year attributes
        year_number as year,
        year_start_date,
        year_end_date,
        
        -- Quarter attributes
        quarter_of_year as quarter,
        quarter_start_date,
        quarter_end_date,
        
        -- Month attributes
        month_of_year as month,
        month_start_date,
        month_end_date,
        month_name,
        month_name_short,
        
        -- Week attributes
        week_of_year,
        week_start_date,
        week_end_date,
        
        -- Day attributes
        day_of_month,
        day_of_year,
        day_of_week,
        day_of_week_name,
        day_of_week_name_short,
        
        -- Additional useful flags
        case 
            when day_of_week in (6, 7) then true 
            else false 
        end as is_weekend,
        
        case 
            when day_of_week between 1 and 5 then true 
            else false 
        end as is_weekday,
        
        case 
            when day_of_month = 1 then true 
            else false 
        end as is_month_start,
        
        case 
            when date_day = month_end_date then true 
            else false 
        end as is_month_end,
        
        case 
            when date_day = quarter_start_date then true 
            else false 
        end as is_quarter_start,
        
        case 
            when date_day = quarter_end_date then true 
            else false 
        end as is_quarter_end,
        
        case 
            when date_day = year_start_date then true 
            else false 
        end as is_year_start,
        
        case 
            when date_day = year_end_date then true 
            else false 
        end as is_year_end,
        
        -- Fiscal period (assuming fiscal year starts in July)
        case 
            when month_of_year >= 7 then year_number + 1
            else year_number
        end as fiscal_year,
        
        case 
            when month_of_year >= 7 then month_of_year - 6
            else month_of_year + 6
        end as fiscal_month,
        
        case 
            when month_of_year between 7 and 9 then 1
            when month_of_year between 10 and 12 then 2
            when month_of_year between 1 and 3 then 3
            else 4
        end as fiscal_quarter,
        
        -- ISO week date
        {{ dbt_date.iso_week_start('date_day') }} as iso_week_start_date,
        {{ dbt_date.iso_week_of_year('date_day') }} as iso_week_of_year,
        
        -- Relative date calculations
        case when date_day = current_date then true else false end as is_today,
        case when date_day = current_date - 1 then true else false end as is_yesterday,
        case when date_day = current_date + 1 then true else false end as is_tomorrow,
        
        case 
            when date_day >= {{ dbt_date.week_start('current_date', 1) }}
            and date_day <= {{ dbt_date.week_end('current_date', 1) }}
            then true 
            else false 
        end as is_current_week,
        
        case 
            when year_number = extract(year from current_date) 
            and month_of_year = extract(month from current_date)
            then true 
            else false 
        end as is_current_month,
        
        case 
            when year_number = extract(year from current_date)
            then true 
            else false 
        end as is_current_year,
        
        -- Days from today
        datediff('day', date_day, current_date) as days_from_today,
        
        -- Period labels for reporting
        year_number || '-Q' || quarter_of_year as year_quarter_label,
        year_number || '-' || lpad(cast(month_of_year as varchar), 2, '0') as year_month_label,
        year_number || '-W' || lpad(cast(week_of_year as varchar), 2, '0') as year_week_label
        
    from date_spine
)


select * from date_details