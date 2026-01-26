{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tag=['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_address.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','address') }}
)

-- RENAME + CASTING
, renamed as (
    select
        cast(AddressID as integer)                  as address_id,
        cast(StateProvinceID as integer)            as state_province_id,
        cast(AddressLine1 as varchar)               as address_line_1,
        cast(AddressLine2 as varchar)               as address_line_2,
        cast(City as varchar)                       as city,
        cast(PostalCode as varchar)                 as postal_code,
        cast(SpatialLocation as varchar)            as spatial_location,
        cast(RowGuid as varchar)                    as rowguid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- PARSE SPATIAL LOCATION
, parsed_spatial as (
    select
        *,
        cast(
            split_part(
                replace(replace(spatial_location, 'POINT (', ''), ')', ''),
                ' ',
                1
            ) as {{ dbt.type_float() }}
        )                                           as geo_longitude,

        cast(
            split_part(
                replace(replace(spatial_location, 'POINT (', ''), ')', ''),
                ' ',
                2
            ) as {{ dbt.type_float() }}
        )                                           as geo_latitude
    from renamed
)

-- final
select *
from parsed_spatial
