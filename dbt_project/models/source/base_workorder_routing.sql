{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_workorder_routing.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_workorderrouting.parquet')
)

, final as (
    select
        cast(WorkOrderID as integer)                    as work_order_id,
        cast(ProductID as integer)                      as product_id,
        cast(OperationSequence as smallint)             as operation_sequence,
        cast(LocationID as smallint)                    as location_id,
        cast(ScheduledStartDate as timestamp)           as scheduled_start_date,
        cast(ScheduledEndDate as timestamp)             as scheduled_end_date,
        try_cast(ActualStartDate as timestamp)          as actual_start_date,
        try_cast(ActualEndDate as timestamp)            as actual_end_date,
        try_cast(ActualResourceHrs as decimal(9,4))     as actual_resource_hrs,
        cast(PlannedCost as decimal(19,4))              as planned_cost,
        try_cast(ActualCost as decimal(19,4))           as actual_cost,
        cast(ModifiedDate as timestamp)                 as modified_date
    from source
)

select * from final