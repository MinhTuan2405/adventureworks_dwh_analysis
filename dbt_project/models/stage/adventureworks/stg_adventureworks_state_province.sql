{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_state_province.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_state_province') }}
)

, cleaned as (
    select
        state_province_id,
        
        -- Clean string fields
        trim(state_province_code)               as state_province_code,
        trim(country_region_code)               as country_region_code,
        trim(state_province_name)               as state_province_name,
        
        -- Flag
        is_only_state_province,
        
        -- Foreign key
        territory_id,
        
    from base
)

select * from cleaned