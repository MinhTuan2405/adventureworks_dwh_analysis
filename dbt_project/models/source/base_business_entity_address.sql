{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags=['bronze'],
    location = 's3://lakehouse/bronze/base_business_entity_address.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/person/person_businessentityaddress.parquet')
)

, final as (
    select
        cast(BusinessEntityID as integer)       as business_entity_id,
        cast(AddressID as integer)              as address_id,
        cast(AddressTypeID as integer)          as address_type_id,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
