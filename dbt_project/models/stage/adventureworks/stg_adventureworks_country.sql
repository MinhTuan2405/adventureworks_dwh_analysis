{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_country.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_country') }}
)

, cleaned as (
    select
        trim(country_region_code)               as country_region_code,
        trim(name)                              as country_name
    from base
)

select * from cleaned