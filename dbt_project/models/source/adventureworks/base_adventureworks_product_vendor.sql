{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_product_vendor.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'product_vendor') }}
)

, final as (
    select
        cast(ProductID as integer)                  as product_id,
        cast(BusinessEntityID as integer)           as business_entity_id,
        cast(AverageLeadTime as integer)            as average_lead_time,
        cast(StandardPrice as decimal(19,4))        as standard_price,
        cast(LastReceiptCost as decimal(19,4))      as last_receipt_cost,
        cast(LastReceiptDate as timestamp)          as last_receipt_date,
        cast(MinOrderQty as integer)                as min_order_qty,
        cast(MaxOrderQty as integer)                as max_order_qty,
        cast(OnOrderQty as integer)                 as on_order_qty,
        cast(UnitMeasureCode as varchar(3))         as unit_measure_code,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select *
from final
