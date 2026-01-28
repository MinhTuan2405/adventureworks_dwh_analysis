{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_ship_method.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_adventureworks_ship_method') }}
)

select * from final
