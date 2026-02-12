{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_purchase_order_details.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/purchasing/purchasing_purchaseorderdetail.parquet')
)

, final as (
    select
        cast(PurchaseOrderID as integer)            as purchase_order_id,
        cast(PurchaseOrderDetailID as integer)      as purchase_order_detail_id,
        cast(DueDate as timestamp)                  as due_date,
        cast(OrderQty as integer)                   as order_qty,
        cast(ProductID as integer)                  as product_id,
        cast(UnitPrice as decimal(19,4))            as unit_price,
        try_cast(LineTotal as decimal(19,4))        as line_total,
        cast(ReceivedQty as decimal(8,2))           as received_qty,
        cast(RejectedQty as decimal(8,2))           as rejected_qty,
        try_cast(StockedQty as decimal(8,4))        as stocked_qty,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select *
from final
