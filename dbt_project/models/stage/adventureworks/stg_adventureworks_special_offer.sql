{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_special_offer.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_special_offer') }}
)

, cleaned as (
    select
        special_offer_id,
        
        -- Clean string fields
        trim(description)                       as description,
        trim(offer_type)                        as offer_type,
        trim(offer_category)                    as offer_category,
        
        -- Discount
        discount_percentage,
        
        -- Date range
        start_date,
        end_date,
        
        -- Quantity constraints
        min_quantity,
        max_quantity,
        
    from base
)

select * from cleaned