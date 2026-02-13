{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_sales_territory.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_salesterritory.parquet')
)

, renaming as (
    select
        cast(TerritoryID as integer)                as territory_id,
        cast(Name as varchar)                       as territory_name,
        cast(CountryRegionCode as varchar)          as country_region_code,
        cast("Group" as varchar)                    as territory_group,
        cast(SalesYTD as decimal(19,4))             as sales_ytd,
        cast(SalesLastYear as decimal(19,4))        as sales_last_year,
        cast(CostYTD as decimal(19,4))              as cost_ytd,
        cast(CostLastYear as decimal(19,4))         as cost_last_year,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select * from renaming