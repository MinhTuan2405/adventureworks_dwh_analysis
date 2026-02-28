{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_workorder.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_workorder.parquet')
)

, final as (
    select
        cast(WorkOrderID as integer)                as work_order_id,
        cast(ProductID as integer)                  as product_id,
        cast(OrderQty as integer)                   as order_qty,
        try_cast(StockedQty as integer)             as stocked_qty,
        cast(ScrappedQty as smallint)               as scrapped_qty,
        cast(StartDate as timestamp)                as start_date,
        try_cast(EndDate as timestamp)              as end_date,
        cast(DueDate as timestamp)                  as due_date,
        try_cast(ScrapReasonID as smallint)         as scrap_reason_id,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select * from final