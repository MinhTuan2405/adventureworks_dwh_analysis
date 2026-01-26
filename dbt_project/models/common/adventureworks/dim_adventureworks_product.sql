{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_product.parquet'
  ) 
}}

with product as (
    select 
        product_id,
        product_name,
        product_number,
        is_manufactured_in_house,
        is_finished_good,
        color,
        safety_stock_level,
        reorder_point,
        standard_cost,
        list_price,
        size,
        size_unit_measure_code,
        weight_unit_measure_code,
        weight,
        days_to_manufacture,
        product_line_code,
        class_code,
        style_code,
        product_subcategory_id,
        product_model_id,
        sell_start_date,
        sell_end_date,
        discontinued_date
    from {{ ref('stg_adventureworks_product') }}
)

, subcategory as (
    select 
        product_subcategory_id,
        product_category_id,
        product_subcategory_name
    from {{ ref('stg_adventureworks_product_subcategory') }}
)

, category as (
    select 
        product_category_id,
        product_category_name
    from {{ ref('stg_adventureworks_product_category') }}
)

, joined as (
    select
        p.product_id,
        p.product_name,
        p.product_number,
        
        -- Product characteristics
        p.is_manufactured_in_house,
        p.is_finished_good,
        p.color,
        p.size,
        p.size_unit_measure_code,
        p.weight,
        p.weight_unit_measure_code,
        
        -- Inventory
        p.safety_stock_level,
        p.reorder_point,
        
        -- Pricing
        p.standard_cost,
        p.list_price,
        
        -- Manufacturing
        p.days_to_manufacture,
        
        -- Classification
        p.product_line_code,
        p.class_code,
        p.style_code,
        
        -- Category hierarchy
        sc.product_subcategory_id,
        sc.product_subcategory_name,
        c.product_category_id,
        c.product_category_name,
        
        -- Foreign keys
        p.product_model_id,
        
        -- Dates
        p.sell_start_date,
        p.sell_end_date,
        p.discontinued_date,
        
        -- Derived flags
        case 
            when p.discontinued_date is not null then true 
            else false 
        end as is_discontinued,
        case 
            when p.sell_end_date is null then true 
            else false 
        end as is_currently_selling
    
    from product p
    left join subcategory sc 
        on p.product_subcategory_id = sc.product_subcategory_id
    left join category c 
        on sc.product_category_id = c.product_category_id
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} as dim_adventureworks_product_sk,
        
        -- Natural Key
        product_id,
        
        -- Product Attributes
        product_name,
        product_number,
        is_manufactured_in_house,
        is_finished_good,
        color,
        size,
        size_unit_measure_code,
        weight,
        weight_unit_measure_code,
        
        -- Inventory
        safety_stock_level,
        reorder_point,
        
        -- Pricing
        standard_cost,
        list_price,
        
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
        
        -- Foreign keys
        product_model_id,
        
        -- Dates
        sell_start_date,
        sell_end_date,
        discontinued_date,
        
        -- Derived flags
        is_discontinued,
        is_currently_selling
    from joined
)

-- final
select *
from add_key