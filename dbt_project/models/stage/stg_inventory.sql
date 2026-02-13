{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_inventory.parquet'
  ) 
}}

with inventory as (
    select * from {{ ref('base_inventory') }}
),

product_info as (
    select * from {{ ref('base_product') }}
),

current_history as (
    select product_id, transaction_date, transaction_type 
    from {{ ref('base_transactionhistory') }}
),

archive_history as (
    select product_id, transaction_date, transaction_type 
    from {{ ref('base_transactionhistoryarchive') }}
),


full_history as (
    select * from current_history
    union all
    select * from archive_history
),

simulation_date as (
    select max(transaction_date) as simulated_today
    from current_history 
),


transaction_info as (
    select 
        product_id,
        max(case when transaction_type in ('P', 'W') then transaction_date end) as last_receipt_date,
        max(case when transaction_type = 'S' then transaction_date end) as last_sale_date
    from full_history
    group by product_id
)

select
    i.product_id,
    i.location_id,
    
    i.shelf,
    i.bin,

    p.is_manufactured_in_house,
    p.is_finished_good,
    p.safety_stock_level,
    p.reorder_point,
    
    i.quantity,
    
    coalesce(p.standard_cost, 0)                as standard_cost,
    coalesce(p.list_price, 0)                   as list_price,
    
    (i.quantity * coalesce(p.standard_cost, 0)) as total_manufacture_value,
    (i.quantity * coalesce(p.list_price, 0))    as total_actual_value,

    ti.last_receipt_date,
    ti.last_sale_date,

    date_diff('day', ti.last_receipt_date, sd.simulated_today) as days_since_last_receipt,
    date_diff('day', ti.last_sale_date, sd.simulated_today)    as days_since_last_sale,

    i.modified_date

from inventory i
left join product_info p on i.product_id = p.product_id
left join transaction_info ti on i.product_id = ti.product_id
cross join simulation_date sd
