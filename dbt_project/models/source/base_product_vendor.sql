{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_product_vendor.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/purchasing/purchasing_productvendor.parquet')
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
