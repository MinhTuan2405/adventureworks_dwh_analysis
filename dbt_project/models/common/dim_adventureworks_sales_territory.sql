{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_sales_territory.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_sales_territory') }}
)

select * from final
