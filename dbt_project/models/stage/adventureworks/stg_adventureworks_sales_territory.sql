{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_sales_territory.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_sales_territory') }}
)

, cleaned as (
    select
        territory_id,
        
        -- Clean string fields
        trim(territory_name)                    as territory_name,
        trim(country_region_code)               as country_region_code,
        trim(territory_group)                   as territory_group,
        
        -- Financial metrics
        sales_ytd,
        sales_last_year,
        cost_ytd,
        cost_last_year,
        
    from base
)

select * from cleaned