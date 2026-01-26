{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_sales_order_details.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_sales_order_details') }}
)

, cleaned as (
    select
        sales_order_detail_id,
        sales_order_id,
        product_id,
        special_offer_id,
        
        -- Order details
        nullif(trim(carrier_tracking_number), '') as carrier_tracking_number,
        order_qty,
        
        -- Pricing
        unit_price,
        unit_price_discount,
        
        -- Calculated line total with business logic
        -- Handle cases where line_total might be missing or incorrect
        coalesce(
            nullif(line_total, 0),
            (unit_price * (1.0 - unit_price_discount)) * order_qty
        )                                       as line_total,
        
    from base
)

select * from cleaned