{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_scrap_reason.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_scrapreason.parquet')
)

, final as (
    select
        cast(ScrapReasonID as integer)      as scrap_reason_id,
        cast(Name as varchar)               as scrap_reason_name,
        cast(ModifiedDate as timestamp)     as modified_date
    from source
)

select * from final