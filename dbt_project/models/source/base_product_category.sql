{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_product_category.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_productcategory.parquet')
)

, final as (
    select
        cast(ProductCategoryID as integer)          as product_category_id,
        cast(Name as varchar)                       as product_category_name,
        cast(RowGuid as varchar)                    as rowguid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select *
from final
