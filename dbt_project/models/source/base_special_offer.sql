{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_special_offer.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_specialoffer.parquet')
)

, renaming as (
    select
        cast(SpecialOfferID as integer)             as special_offer_id,
        cast(Description as varchar)                as description,
        cast(DiscountPct as decimal(8,2))           as discount_percentage,
        cast("Type" as varchar)                     as offer_type,
        cast(Category as varchar)                   as offer_category,
        cast(StartDate as timestamp)                as start_date,
        cast(EndDate as timestamp)                  as end_date,
        cast(MinQty as integer)                     as min_quantity,
        cast(MaxQty as integer)                     as max_quantity,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select * from renaming