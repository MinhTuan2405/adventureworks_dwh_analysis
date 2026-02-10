{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_vendor.parquet'
  ) 
}}


with vendor as (
    select *
    from {{ ref('stg_adventureworks_vendor')}}
)

, mapping_vendor_address as (
    select *
    from {{ ref('map_adventureworks_entity_address')}}
)

, address as (
    select *
    from {{ ref('stg_adventureworks_address')}}
)

, joined as (
    select
      v.*,
      a.* exclude (dim_adventureworks_geography_sk, address_id, state_province_id, is_only_state_province)
    from vendor as v
    left join mapping_vendor_address as mp
      on v.vendor_id = mp.business_entity_id
    left join address as a
      on a.address_id = mp.address_id
)

select *
from joined