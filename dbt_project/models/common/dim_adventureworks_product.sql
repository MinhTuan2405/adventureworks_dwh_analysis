{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_product.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_product') }}
)

select * from final
