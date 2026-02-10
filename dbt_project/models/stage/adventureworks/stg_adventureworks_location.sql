{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_location.parquet'
  ) 
}}

with source as (
    select * from {{ ref('base_adventureworks_location') }}
)

select
    -- Create surrogate key
    {{ dbt_utils.generate_surrogate_key(['location_id']) }} as dim_adventureworks_location_sk,
    
    location_id,
    location_name,
    
    -- Finished Goods Storage
    case 
        when location_id = 7 then true 
        else false 
    end as is_finished_goods_storage,
    
    cost_rate,
    availability,
    modified_date

from source
