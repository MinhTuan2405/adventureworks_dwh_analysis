{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh', 'inventory', 'snapshot'],
    location = 's3://lakehouse/warehouse/fct_inventory_daily_snapshot.parquet'
  ) 
}}

with 

products as (
    select 
        dim_product_sk, -- Sửa tên cột SK
        product_id 
    from {{ ref('dim_product') }}
    where is_finished_good = true
),

dates as (
    select date_key, full_date
    from {{ ref('dim_date') }}
    where full_date >= '2011-01-01' and full_date <= '2014-12-31'
),

daily_changes as (
    select
        dim_product_sk, 
        transaction_date_key, 
        sum(net_quantity) as daily_net_change
    from {{ ref('fct_transaction') }}
    group by 1, 2
),

spine as (
    select 
        p.dim_product_sk,
        p.product_id,
        d.date_key,
        d.full_date
    from products p
    cross join dates d
),


final as (
    select
        {{ dbt_utils.generate_surrogate_key(['s.date_key', 's.dim_product_sk']) }} as fct_inventory_daily_snapshot_sk,
        
        s.date_key,
        c.transaction_date_key,
        s.dim_product_sk,
        
        s.product_id,
        s.full_date,
        
        coalesce(c.daily_net_change, 0) as daily_change,

        sum(coalesce(c.daily_net_change, 0)) over (
            partition by s.dim_product_sk 
            order by s.full_date 
            rows between unbounded preceding and current row
        ) as quantity_on_hand

    from spine s
    left join daily_changes c 
        on s.dim_product_sk = c.dim_product_sk 
        and s.date_key = c.transaction_date_key
)

select * from final
where quantity_on_hand != 0