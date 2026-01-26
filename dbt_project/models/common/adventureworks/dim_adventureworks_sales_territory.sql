{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_sales_territory.parquet'
  ) 
}}

with territory as (
    select *
    from {{ ref('stg_adventureworks_sales_territory') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['territory_id']) }} as dim_adventureworks_sales_territory_sk,
        
        -- Natural key
        territory_id,
        
        -- Attributes
        territory_name,
        country_region_code,
        country_name,
        territory_group,
        
        -- Metrics
        sales_ytd,
        sales_last_year,
        cost_ytd,
        cost_last_year,
        sales_growth,
        cost_growth
        
    from territory
)

select * from final
