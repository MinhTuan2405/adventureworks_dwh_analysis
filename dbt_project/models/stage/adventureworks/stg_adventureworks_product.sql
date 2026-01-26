{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_product.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_product') }}
)

, cleaned as (
    select
        product_id,
        
        -- Clean string fields
        trim(product_name)                      as product_name,
        trim(product_number)                    as product_number,
        
        -- Flags
        is_manufactured_in_house,
        is_finished_good,
        
        -- Product attributes
        nullif(trim(color), '')                 as color,
        safety_stock_level,
        reorder_point,
        
        -- Pricing
        standard_cost,
        list_price,
        
        -- Physical attributes
        nullif(trim(size), '')                  as size,
        nullif(trim(size_unit_measure_code), '') as size_unit_measure_code,
        nullif(trim(weight_unit_measure_code), '') as weight_unit_measure_code,
        weight,
        
        -- Manufacturing
        days_to_manufacture,
        
        -- Classification codes
        nullif(trim(product_line_code), '')     as product_line_code,
        nullif(trim(class_code), '')            as class_code,
        nullif(trim(style_code), '')            as style_code,
        
        -- Foreign keys
        product_subcategory_id,
        product_model_id,
        
        -- Dates
        sell_start_date,
        sell_end_date,
        discontinued_date,
        
    from base
)

select * from cleaned