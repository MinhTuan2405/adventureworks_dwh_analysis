{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging', 'transaction'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_transaction.parquet'
  ) 
}}

with 
-- 1. Load Transaction Mới
current_tx as (
    select 
        transaction_id,
        product_id, 
        transaction_date, 
        transaction_type, 
        quantity, 
        actual_cost, 
        reference_order_id
    from {{ ref('base_adventureworks_transactionhistory') }}
),

archive_tx as (
    select 
        transaction_id,
        product_id, 
        transaction_date, 
        transaction_type, 
        quantity, 
        actual_cost, 
        reference_order_id
    from {{ ref('base_adventureworks_transactionhistoryarchive') }}
),

all_transactions as (
    select * from current_tx
    union all
    select * from archive_tx
),

final as (
    select
        transaction_id,
        product_id,
        reference_order_id,

        transaction_date,
        transaction_type, 
        quantity as abs_quantity,
        actual_cost,
        
        (quantity * actual_cost) as total_amount,

        case 
            when transaction_type in ('P', 'W') then 'Inflow'
            when transaction_type = 'S' then 'Outflow'
            else 'Adjustment'
        end as movement_type,

        case 
            when transaction_type in ('P', 'W') then quantity 
            when transaction_type = 'S' then -quantity 
            else 0 
        end as net_quantity

    from all_transactions
)

select * from final

