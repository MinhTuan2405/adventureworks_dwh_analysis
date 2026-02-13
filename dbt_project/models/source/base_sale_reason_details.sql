{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_sale_reason_details.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_salesreason.parquet')
)


-- casting + rename
, final as (
    select
        cast(SalesReasonID as integer)          as sales_reason_id,
        cast(Name as varchar(256))              as name,
        cast(ReasonType as varchar(256))        as reason_type,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
