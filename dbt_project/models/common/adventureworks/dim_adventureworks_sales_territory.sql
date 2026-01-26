{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_sales_territory.parquet'
  ) 
}}

with base as (
    select distinct
        territory_id,
        territory_name,
        country_region_code,
        territory_group
    from {{ ref('stg_adventureworks_sales_territory') }}
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['territory_id']) }} as dim_adventureworks_sales_territory_sk,
        
        -- Natural Key
        territory_id,
        
        -- Attributes
        territory_name,
        country_region_code,
        territory_group
        
    from base
)

-- final
select *
from add_key
