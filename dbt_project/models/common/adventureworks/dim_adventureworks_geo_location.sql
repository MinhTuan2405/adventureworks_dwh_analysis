{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_geo_location.parquet'
  ) 
}}

with address as (
    select 
        address_id,
        state_province_id,
        address_line_1,
        address_line_2,
        city,
        postal_code,
        geo_longitude,
        geo_latitude
    from {{ ref('stg_adventureworks_address') }}
)

, state_province as (
    select 
        state_province_id,
        state_province_code,
        country_region_code,
        state_province_name,
        is_only_state_province,
        territory_id
    from {{ ref('stg_adventureworks_state_province') }}
)

, country as (
    select 
        country_region_code,
        country_name
    from {{ ref('stg_adventureworks_country') }}
)

, joined as (
    select distinct
        a.address_id,
        a.address_line_1,
        a.address_line_2,
        a.city,
        a.postal_code,
        a.geo_longitude,
        a.geo_latitude,
        
        sp.state_province_id,
        sp.state_province_code,
        sp.state_province_name,
        sp.is_only_state_province,
        sp.territory_id,
        
        c.country_region_code,
        c.country_name
    
    from address a
    left join state_province sp 
        on a.state_province_id = sp.state_province_id
    left join country c 
        on sp.country_region_code = c.country_region_code
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['address_id']) }} as dim_adventureworks_geo_location_sk,
        
        -- Natural Key
        address_id,
        
        -- Address Attributes
        address_line_1,
        address_line_2,
        city,
        postal_code,
        geo_longitude,
        geo_latitude,
        
        -- State/Province Attributes
        state_province_id,
        state_province_code,
        state_province_name,
        is_only_state_province,
        territory_id,
        
        -- Country Attributes
        country_region_code,
        country_name
    from joined
)

-- final
select *
from add_key
