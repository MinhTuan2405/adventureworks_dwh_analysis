{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_currency.parquet'
  ) 
}}

with base as (
    select distinct 
        currency_code,
        currency_name
    from {{ ref('stg_adventureworks_store') }}
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['currency_code']) }} as dim_adventureworks_currency_sk,
        
        -- Natural Key
        currency_code,
        
        -- Attributes
        currency_name
    from base
)

-- final
select *
from add_key