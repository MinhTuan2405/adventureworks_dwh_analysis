{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_sale_reason_header.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_salesorderheadersalesreason.parquet')
)


-- casting + rename
, final as (
    select
        cast(SalesOrderID as integer)           as sales_order_id,
        cast(SalesReasonID as integer)          as sales_reason_id,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
