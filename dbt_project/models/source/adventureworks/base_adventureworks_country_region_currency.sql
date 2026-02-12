{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_country_region_currency.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_countryregioncurrency.parquet')
)


-- casting + rename
, final as (
    select
        cast(CountryRegionCode as varchar(3))   as country_region_code,
        cast(CurrencyCode as varchar(3))        as currency_code,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
