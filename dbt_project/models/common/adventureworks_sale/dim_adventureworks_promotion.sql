{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_promotion.parquet'
  ) 
}}

with base as (
    select distinct
        special_offer_id,
        description,
        offer_type,
        offer_category,
        discount_percentage,
        start_date,
        end_date,
        min_quantity,
        max_quantity
    
    from {{ ref('stg_adventureworks_special_offer') }}
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['special_offer_id']) }} as dim_adventureworks_promotion_sk,
        
        -- Natural Key
        special_offer_id,
        
        -- Attributes
        description,
        offer_type,
        offer_category,
        discount_percentage,
        start_date,
        end_date,
        min_quantity,
        max_quantity,
        case 
            when max_quantity is null then true 
            else false 
        end as is_unlimited_quantity
    from base
)

-- final
select *
from add_key