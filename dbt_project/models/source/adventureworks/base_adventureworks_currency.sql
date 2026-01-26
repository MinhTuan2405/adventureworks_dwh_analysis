{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_currency.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','currency') }}
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
