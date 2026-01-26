{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_currency_rate.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','currency_rate') }}
)


-- casting + rename
, final as (
    select
        cast(CurrencyRateID as integer)         as currency_rate_id,
        cast(CurrencyRateDate as timestamp)     as currency_rate_date,
        cast(FromCurrencyCode as varchar(3))    as from_currency_code,
        cast(ToCurrencyCode as varchar(3))      as to_currency_code,
        cast(AverageRate as decimal(19,4))      as average_rate,
        cast(EndOfDayRate as decimal(19,4))     as end_of_day_rate,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
