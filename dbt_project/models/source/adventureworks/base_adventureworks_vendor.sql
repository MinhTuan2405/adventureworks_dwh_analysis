{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_vendor.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/purchasing/purchasing_vendor.parquet')
)

, final as (
    select
        cast(BusinessEntityID as integer)           as vendor_id,
        cast(AccountNumber as varchar(128))         as account_number,
        cast(Name as varchar(256))                  as vendor_name,
        cast(CreditRating as integer)               as credit_rating,
        cast(PreferredVendorStatus as boolean)      as is_preferred_vendor,
        cast(ActiveFlag as boolean)                 as is_active,
        cast(PurchasingWebServiceURL as varchar(1024)) as purchasing_web_service_url,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select *
from final
