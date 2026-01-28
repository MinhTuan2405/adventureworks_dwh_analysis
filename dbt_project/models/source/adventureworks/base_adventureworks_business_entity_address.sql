{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags=['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_business_entity_address.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','business_entity_address') }}
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
