{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_sales_order_detail.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_salesorderdetail.parquet')
)

, renaming as (
    select
        cast(SalesOrderID as integer)               as sales_order_id,
        cast(SalesOrderDetailID as integer)         as sales_order_detail_id,
        cast(CarrierTrackingNumber as varchar)      as carrier_tracking_number,
        cast(OrderQty as integer)                   as order_qty,
        cast(ProductID as integer)                  as product_id,
        cast(SpecialOfferID as integer)             as special_offer_id,
        cast(UnitPrice as decimal(19,4))            as unit_price,
        cast(UnitPriceDiscount as decimal(19,4))    as unit_price_discount,
        cast(nullif(LineTotal, $$None$$) as decimal(38,4)) as line_total,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select * from renaming