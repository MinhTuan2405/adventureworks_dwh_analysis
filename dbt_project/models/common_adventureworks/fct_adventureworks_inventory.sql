{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/fct_adventureworks_inventory.parquet'
  ) 
}}

with stg_inventory as (
    select * from {{ ref('stg_adventureworks_inventory') }}
),

-- Join surrogate keys from dimension tables

with stg_product as (
    select
        dim_adventureworks_product_sk,
        product_id
    from {{ ref('stg_adventureworks_product') }}
),

with stg_location as (
    select
        dim_adventureworks_location_sk,
        location_id
    from {{ ref('stg_adventureworks_location') }}
),

final as (
    select
        
        -- Surrogate Keys from Dimensions
        coalesce(p.dim_adventureworks_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_product_sk,
        coalesce(l.dim_adventureworks_location_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_location_sk,

        -- IDs & Attributes
        i.product_id,
        i.location_id,

        i.shelf,
        i.bin,
        
        -- Measures
        i.quantity,
        i.standard_cost,
        i.total_inventory_value,


    from stg_inventory i
    left join stg_product p
        on i.product_id = p.product_id
    left join stg_location l
        on i.location_id = l.location_id
)

select
  -- Create fact surrogate key
  {{ dbt_utils.generate_surrogate_key(['product_id', 'location_id']) }} as fct_adventureworks_inventory_sk,
  *
from final
