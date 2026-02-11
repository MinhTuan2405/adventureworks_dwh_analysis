{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'bronze', 'inventory'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_transactionhistoryarchive.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'product_transaction_archive') }}
),

renamed_and_casted as (
    select
        cast(TransactionID as integer)      as transaction_id,
        cast(ProductID as integer)          as product_id,
        cast(ReferenceOrderID as integer)   as reference_order_id,
        cast(TransactionType as varchar)    as transaction_type, 
        cast(TransactionDate as timestamp)  as transaction_date,
        cast(Quantity as integer)           as quantity,
        cast(ActualCost as decimal(18,4))   as actual_cost,
        cast(ModifiedDate as timestamp)     as modified_date

    from source
)

select * from renamed_and_casted