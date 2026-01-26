{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_customer.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','customer') }}
)

, final as (
    select
        cast(CustomerID as integer)             as customer_id,
        cast(PersonID as integer)               as person_id,
        cast(StoreID as integer)                as store_id,
        cast(TerritoryID as integer)            as territory_id,
        cast(AccountNumber as varchar)          as account_number,
        cast(RowGuid as varchar)                as rowguid,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

-- final
select *
from final