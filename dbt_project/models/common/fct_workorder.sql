{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/fct_workorder.parquet'
  ) 
}}

with stg_manufacture as (
    select * from {{ ref('stg_manufacture') }}
)

, dim_product as (
    select dim_product_sk, product_id
    from {{ ref('dim_product') }}
)

, dim_scrap_reason as (
    select dim_scrap_reason_sk, scrap_reason_id
    from {{ ref('dim_scrap_reason') }}
)

, dim_date as (
    select date_key
    from {{ ref('dim_date') }}
)

, joined as (
    select
        -- Fact grain: work order
        m.work_order_id,
        
        -- Date foreign keys (YYYYMMDD)
        coalesce(dd_start.date_key, 19000101)       as start_date_key,
        coalesce(dd_end.date_key, 19000101)          as end_date_key,
        coalesce(dd_due.date_key, 19000101)          as due_date_key,
        
        -- Dimension foreign keys (surrogate keys)
        coalesce(dp.dim_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }})         as dim_product_sk,
        coalesce(dsr.dim_scrap_reason_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }})   as dim_scrap_reason_sk,
        
        -- Natural keys (for reference)
        m.product_id,
        m.scrap_reason_id,
        
        -- Degenerate dimensions
        m.delivery_status,
        m.has_scrap,
        m.scrap_reason_name,
        
        -- Measures - Quantities
        m.order_qty,
        m.stocked_qty,
        m.scrapped_qty,
        
        -- Measures - Rates
        m.scrap_rate_pct,
        m.yield_rate_pct,
        
        -- Measures - Time  
        m.actual_lead_time_days,
        m.planned_lead_time_days,
        m.days_ahead_or_behind,
        
        -- Measures - Routing
        m.total_routing_steps,
        m.completed_routing_steps,
        
        -- Measures - Cost
        m.total_planned_cost,
        m.total_actual_cost,
        m.cost_variance,
        m.cost_variance_pct,
        
        -- Measures - Resource
        m.total_actual_resource_hrs,
        
        -- Raw dates (for time intelligence in BI)
        m.start_date,
        m.end_date,
        m.due_date
        
    from stg_manufacture m
    left join dim_product dp
        on m.product_id = dp.product_id
    left join dim_scrap_reason dsr
        on m.scrap_reason_id = dsr.scrap_reason_id
    left join dim_date dd_start
        on cast(strftime(m.start_date, '%Y%m%d') as integer) = dd_start.date_key
    left join dim_date dd_end
        on cast(strftime(m.end_date, '%Y%m%d') as integer) = dd_end.date_key
    left join dim_date dd_due
        on cast(strftime(m.due_date, '%Y%m%d') as integer) = dd_due.date_key
)

, final as (
    select
        -- Primary key
        {{ dbt_utils.generate_surrogate_key(['work_order_id']) }} as workorder_pk,
        
        *
    from joined
)

select * from final
