{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_product.parquet'
  ) 
}}

with product as (
    select *
    from {{ ref('stg_adventureworks_product') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} as dim_adventureworks_product_sk,
        
        -- Natural key
        product_id,
        
        -- Product identifiers
        product_name,
        product_number,
        
        -- Flags
        is_manufactured_in_house,
        is_finished_good,
        
        -- Product attributes
        color,
        safety_stock_level,
        reorder_point,
        
        -- Pricing
        standard_cost,
        list_price,
        
        -- Physical attributes
        size,
        weight,
        
        -- Manufacturing
        days_to_manufacture,
        
        -- Classification
        product_line_code,
        class_code,
        style_code,
        
        -- Category hierarchy
        product_subcategory_id,
        product_subcategory_name,
        product_category_id,
        product_category_name,
        
        -- Dates
        sell_start_date,
        sell_end_date,
        discontinued_date
        
    from product
)

select * from final
