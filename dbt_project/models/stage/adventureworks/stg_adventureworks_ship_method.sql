{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_ship_method.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_ship_method') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['ship_method_id']) }} as dim_adventureworks_ship_method_sk,
        
        -- Natural key
        ship_method_id,
        
        -- Attributes
        ship_method_name,
        ship_base,
        ship_rate
    from base
)

select * from final

