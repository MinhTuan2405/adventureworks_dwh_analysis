{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['mapping'],
    location = 's3://lakehouse/warehouse/map_entity_address.parquet'
  ) 
}}

with mapping as (
    select distinct
        business_entity_id,
        address_id
    from {{ ref('base_business_entity_address') }}
)

select *
from mapping
