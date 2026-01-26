{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_sale_reason_header.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','sale_resaon_header') }}
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
