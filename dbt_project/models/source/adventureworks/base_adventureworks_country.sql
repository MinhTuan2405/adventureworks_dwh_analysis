{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_country.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','country') }}
)

-- casting + rename
, final as (
    select
        cast(CountryRegionCode as varchar)      as country_region_code,
        cast(Name as varchar)                   as name,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
