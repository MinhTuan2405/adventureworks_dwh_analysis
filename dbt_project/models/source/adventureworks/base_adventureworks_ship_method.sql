{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_ship_method.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks','ship_method') }}
)

-- casting + rename
, final as (
    select
        cast(ShipMethodID as integer)           as ship_method_id,
        cast(Name as varchar(256))              as ship_method_name,
        cast(ShipBase as decimal(19,4))         as ship_base,
        cast(ShipRate as decimal(19,4))         as ship_rate,
        cast(rowguid as varchar)                as rowguid,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

select *
from final
