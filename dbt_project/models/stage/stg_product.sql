{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_product.parquet'
  ) 
}}

with product as (
    select * 
    from {{ ref('base_product') }}
)

, product_subcategory as (
    select *
    from {{ ref('base_product_subcategory') }}
)

, product_category as (
    select *
    from {{ ref('base_product_category') }}
)

, joined as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as dim_product_sk,
        
        -- Natural key
        p.product_id,
        
        -- Product identifiers
        trim(p.product_name)                    as product_name,
        trim(p.product_number)                  as product_number,
        
        -- Flags
        p.is_manufactured_in_house,
        p.is_finished_good,                     -- is it the finished product
        -- mean that if this flag is 0 -> is not for sales, only for manufactoring
        
        -- Product attributes
        nullif(trim(p.color), '')               as color,
        p.safety_stock_level,
        p.reorder_point,
        
        -- Pricing
        p.standard_cost,
        p.list_price,
        
        -- Physical attributes
        nullif(trim(p.size), '')                as size,
        -- nullif(trim(p.size_unit_measure_code), '') as size_unit_measure_code,
        -- nullif(trim(p.weight_unit_measure_code), '') as weight_unit_measure_code,
        p.weight,
        
        -- Manufacturing
        p.days_to_manufacture,
        
        -- Classification codes
        nullif(trim(p.product_line_code), '')   as product_line_code,
        nullif(trim(p.class_code), '')          as class_code,
        nullif(trim(p.style_code), '')          as style_code,
        
        -- Category hierarchy
        p.product_subcategory_id,
        ps.product_subcategory_name,
        ps.product_category_id,
        pc.product_category_name,
        
        -- Dates
        p.sell_start_date,
        p.sell_end_date,
        p.discontinued_date,
        
        
    from product p
    left join product_subcategory ps
        on p.product_subcategory_id = ps.product_subcategory_id
    left join product_category pc
        on ps.product_category_id = pc.product_category_id
)

select * from joined