{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_state_province.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'state_province') }}
)

, renaming as (
    select
        cast(StateProvinceID as integer)            as state_province_id,
        cast(StateProvinceCode as varchar)          as state_province_code,
        cast(CountryRegionCode as varchar)          as country_region_code,
        cast(IsOnlyStateProvinceFlag as boolean)    as is_only_state_province,
        cast(Name as varchar)                       as state_province_name,
        cast(TerritoryID as integer)                as territory_id,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select * from renaming