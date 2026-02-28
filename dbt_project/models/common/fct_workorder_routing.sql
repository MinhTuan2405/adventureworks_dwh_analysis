{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/fct_workorder_routing.parquet'
  ) 
}}

with routing as (
    select * from {{ ref('base_workorder_routing') }}
)

, dim_product as (
    select dim_product_sk, product_id
    from {{ ref('dim_product') }}
)

, dim_workcenter as (
    select dim_workcenter_sk, location_id
    from {{ ref('dim_workcenter') }}
)

, dim_date as (
    select date_key
    from {{ ref('dim_date') }}
)

, enriched as (
    select
        -- Keys
        r.work_order_id,
        r.product_id,
        r.operation_sequence,
        r.location_id,
        
        -- Date foreign keys (YYYYMMDD)
        coalesce(dd_sched_start.date_key, 19000101)     as scheduled_start_date_key,
        coalesce(dd_sched_end.date_key, 19000101)       as scheduled_end_date_key,
        coalesce(dd_actual_start.date_key, 19000101)    as actual_start_date_key,
        coalesce(dd_actual_end.date_key, 19000101)      as actual_end_date_key,
        
        -- Dimension foreign keys (surrogate keys)
        coalesce(dp.dim_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }})     as dim_product_sk,
        coalesce(dl.dim_workcenter_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }})    as dim_workcenter_sk,
        
        -- Dates (raw for BI time intelligence)
        r.scheduled_start_date,
        r.scheduled_end_date,
        r.actual_start_date,
        r.actual_end_date,
        
        -- Measures - Cost
        r.planned_cost,
        coalesce(r.actual_cost, 0)                          as actual_cost,
        coalesce(r.actual_cost, 0) - r.planned_cost         as cost_variance,
        case 
            when r.planned_cost > 0 
            then round(
                (coalesce(r.actual_cost, 0) - r.planned_cost) 
                * 100.0 / r.planned_cost, 2
            )
            else 0 
        end                                                 as cost_variance_pct,
        
        -- Measures - Time (duration in days)
        date_diff('day', r.scheduled_start_date, r.scheduled_end_date) as planned_duration_days,
        date_diff('day', r.actual_start_date, r.actual_end_date)       as actual_duration_days,
        
        -- Measures - Resource hours
        coalesce(r.actual_resource_hrs, 0)                  as actual_resource_hrs,
        
        -- Cost per hour
        case 
            when coalesce(r.actual_resource_hrs, 0) > 0 
            then round(coalesce(r.actual_cost, 0) / r.actual_resource_hrs, 2)
            else 0 
        end                                                 as cost_per_resource_hr,
        
        -- Schedule adherence
        case
            when r.actual_start_date is null then 'Not Started'
            when r.actual_end_date is null then 'In Progress'
            when r.actual_end_date <= r.scheduled_end_date then 'On Schedule'
            else 'Behind Schedule'
        end                                                 as schedule_status,
        
        -- Days behind/ahead of schedule
        case 
            when r.actual_end_date is not null 
            then date_diff('day', r.actual_end_date, r.scheduled_end_date)
        end                                                 as days_ahead_or_behind,
        
        -- Is operation completed?
        case 
            when r.actual_end_date is not null then true 
            else false 
        end                                                 as is_completed
        
    from routing r
    left join dim_product dp
        on r.product_id = dp.product_id
    left join dim_workcenter dl
        on r.location_id = dl.location_id
    left join dim_date dd_sched_start
        on cast(strftime(r.scheduled_start_date, '%Y%m%d') as integer) = dd_sched_start.date_key
    left join dim_date dd_sched_end
        on cast(strftime(r.scheduled_end_date, '%Y%m%d') as integer) = dd_sched_end.date_key
    left join dim_date dd_actual_start
        on cast(strftime(r.actual_start_date, '%Y%m%d') as integer) = dd_actual_start.date_key
    left join dim_date dd_actual_end
        on cast(strftime(r.actual_end_date, '%Y%m%d') as integer) = dd_actual_end.date_key
)

, final as (
    select
        -- Primary key (composite)
        {{ dbt_utils.generate_surrogate_key(['work_order_id', 'product_id', 'operation_sequence']) }} as workorder_routing_pk,
        
        *
    from enriched
)

select * from final
