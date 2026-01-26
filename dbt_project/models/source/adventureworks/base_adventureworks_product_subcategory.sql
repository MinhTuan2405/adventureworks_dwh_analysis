{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_product_subcategory.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'product_subcategory') }}
)

, final as (
    select
        cast(ProductSubcategoryID as integer)       as product_subcategory_id,
        cast(ProductCategoryID as integer)          as product_category_id,
        cast(Name as varchar)                       as product_subcategory_name,
        cast(RowGuid as varchar)                    as rowguid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select *
from final
