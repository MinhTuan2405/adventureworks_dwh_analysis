{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_product_category.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_product_category') }}
)

, cleaned as (
    select
        product_category_id,
        trim(product_category_name)             as product_category_name,
    from base
)

select * from cleaned