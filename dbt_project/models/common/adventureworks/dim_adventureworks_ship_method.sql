{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_ship_method.parquet'
  ) 
}}

with ship_method as (
    select *
    from {{ ref('stg_adventureworks_ship_method') }}
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
        
    from ship_method
)

select * from final
