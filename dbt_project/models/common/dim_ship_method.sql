{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_ship_method.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_ship_method') }}
)

select * from final
