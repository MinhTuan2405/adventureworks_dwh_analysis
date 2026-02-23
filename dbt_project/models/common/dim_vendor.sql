{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_vendor.parquet'
  ) 
}}


with vendor as (
    select *
    from {{ ref('stg_vendor')}}
)

, mapping_vendor_address as (
    select *
    from {{ ref('map_entity_address')}}
)

, address as (
    select *
    from {{ ref('stg_address')}}
)

, joined as (
    select
      v.*,
      a.* exclude (dim_geography_sk, address_id, state_province_id, is_only_state_province)
    from vendor as v
    left join mapping_vendor_address as mp
      on v.vendor_id = mp.business_entity_id
    left join address as a
      on a.address_id = mp.address_id
)

select *
from joined