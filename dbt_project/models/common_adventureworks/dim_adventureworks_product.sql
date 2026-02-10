{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_product.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_adventureworks_product') }}
)

select * from final
