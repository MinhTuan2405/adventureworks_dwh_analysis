{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_address.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_address') }}
)

, cleaned as (
    select
        address_id,
        state_province_id,
        
        -- Clean string fields
        trim(address_line_1)                    as address_line_1,
        nullif(trim(address_line_2), '')        as address_line_2,
        trim(city)                              as city,
        trim(postal_code)                       as postal_code,
        
        -- Geographic data
        geo_longitude,
        geo_latitude,
        
    from base
)

select * from cleaned