{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_transactionhistory.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'product_transaction') }}
)

, final as (
    select
        cast(TransactionID as integer)               as transaction_id,
        cast(ProductID as integer)                   as product_id,
        cast(ReferenceOrderID as integer)            as reference_order_id,
        cast(ReferenceOrderLineID as integer)        as reference_order_line_id,
        cast(TransactionDate as timestamp)           as transaction_date,
        cast(TransactionType as varchar(1))          as transaction_type,
        cast(Quantity as integer)                    as quantity,
        cast(ActualCost as decimal(19,4))            as actual_cost,
        cast(ModifiedDate as timestamp)              as modified_date
    from source
)

select *
from final
