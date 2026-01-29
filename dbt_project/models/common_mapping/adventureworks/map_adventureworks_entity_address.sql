{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'mapping'],
    location = 's3://lakehouse/warehouse/adventureworks/map_adventureworks_entity_address.parquet'
  ) 
}}

with mapping as (
    select distinct
        business_entity_id,
        address_id
    from {{ ref('base_adventureworks_business_entity_address') }}
)

select *
from mapping
