{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_currency.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_currency.parquet')
)


-- casting + rename
, final as (
    select
        cast(CurrencyCode as varchar)           as currency_code,
        cast(Name as varchar)                   as name,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
