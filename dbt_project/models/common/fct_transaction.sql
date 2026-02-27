{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'fact', 'transaction'],
    location = 's3://lakehouse/warehouse/fct_transaction.parquet'
  ) 
}}

with staged_data as (
    select * from {{ ref('stg_transaction') }}
),

dim_product as (
    select product_id, dim_product_sk
    from {{ ref('dim_product') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['s.transaction_id']) }} as transaction_sk,

        coalesce(p.dim_product_sk, '-1') as dim_product_sk,
        
        cast(strftime(s.transaction_date, '%Y%m%d') as integer) as transaction_date_key,

        s.transaction_id,
        s.product_id,
        s.reference_order_id,

        s.transaction_date,
        s.transaction_type,
        s.movement_type,
        s.abs_quantity,
        s.net_quantity,
        s.actual_cost,
        s.total_amount,
        
        current_timestamp as loaded_at

    from staged_data s
    left join dim_product p 
        on s.product_id = p.product_id
)

select * from final