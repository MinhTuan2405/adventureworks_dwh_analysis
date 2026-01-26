{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_geography.parquet'
  ) 
}}

with address as (
    select *
    from {{ ref('stg_adventureworks_address') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['address_id']) }} as dim_adventureworks_geography_sk,
        
        -- Natural key
        address_id,
        
        -- Foreign keys
        state_province_id,
        territory_id,
        
        -- Address
        address_line_1,
        address_line_2,
        city,
        postal_code,
        
        -- Geographic hierarchy
        state_province_code,
        state_province_name,
        country_region_code,
        country_name,
        
        -- Location
        geo_longitude,
        geo_latitude
        
    from address
)

select * from final
