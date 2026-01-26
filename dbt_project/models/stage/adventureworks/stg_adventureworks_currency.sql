{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_currency.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_currency') }}
)

, cleaned as (
    select
        trim(currency_code)                     as currency_code,
        trim(name)                              as currency_name,
        
    from base
)

select * from cleaned