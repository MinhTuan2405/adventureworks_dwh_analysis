{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_inventory.parquet'
  ) 
}}

with inventory as (
    select * from {{ ref('base_adventureworks_inventory') }}
),

product_info as (
    select product_id, standard_cost 
    from {{ ref('base_adventureworks_product') }}
)

select
    -- Keys & Location
    i.product_id,
    i.location_id,
    
    i.shelf,
    i.bin,
    
    -- Measures 
    i.quantity,
    
    -- Enrichment 
    coalesce(p.standard_cost, 0) as standard_cost,
    
    -- Calculated Metrics 
    (i.quantity * coalesce(p.standard_cost, 0)) as total_inventory_value,

    -- Meta
    i.modified_date

from inventory i
left join product_info p on i.product_id = p.product_id
