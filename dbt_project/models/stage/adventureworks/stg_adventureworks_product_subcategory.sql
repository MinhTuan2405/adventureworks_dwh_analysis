{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_product_subcategory.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_product_subcategory') }}
)

, cleaned as (
    select
        product_subcategory_id,
        product_category_id,
        trim(product_subcategory_name)          as product_subcategory_name,
        
    from base
)

select * from cleaned