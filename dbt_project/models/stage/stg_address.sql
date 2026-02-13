{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_address.parquet'
  ) 
}}

with address as (
    select * 
    from {{ ref('base_address') }}
)

, state_province as (
    select *
    from {{ ref('base_state_province') }}
)

, country as (
    select *
    from {{ ref('base_country') }}
)

, joined as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['a.address_id']) }} as dim_geography_sk,
        
        -- Natural key
        a.address_id,
        a.state_province_id,
        
        -- Address fields
        trim(a.address_line_1)                      as address_line_1,
        nullif(trim(a.address_line_2), '')          as address_line_2,
        trim(a.city)                                as city,
        trim(a.postal_code)                         as postal_code,
        
        -- Geographic data from address
        a.geo_longitude,
        a.geo_latitude,
        
        -- State/Province info
        sp.state_province_code,
        sp.state_province_name,
        sp.is_only_state_province,
        
        -- Country info
        sp.country_region_code,
        c.name as country_name,

        
    from address a
    left join state_province sp
        on a.state_province_id = sp.state_province_id
    left join country c
        on sp.country_region_code = c.country_region_code
)

select * from joined