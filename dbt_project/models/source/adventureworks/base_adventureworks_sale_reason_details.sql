{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_sale_reason_details.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','sale_resaon_details') }}
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
