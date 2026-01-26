{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_customer.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_customer') }}
)

, cleaned as (
    select
        customer_id,
        person_id,
        store_id,
        territory_id,
        
        -- Clean string fields
        nullif(trim(account_number), '')        as account_number,
        
    from base
)

select * from cleaned