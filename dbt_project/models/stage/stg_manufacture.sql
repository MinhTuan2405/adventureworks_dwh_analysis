{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_manufacture.parquet'
  ) 
}}

with work_order as (
    select * from {{ ref('base_workorder') }}
)

, scrap_reason as (
    select * from {{ ref('base_scrap_reason') }}
)

, work_order_routing as (
    select * from {{ ref('base_workorder_routing') }}
)

-- Aggregate routing metrics per work order
, routing_agg as (
    select
        work_order_id,
        
        count(*)                                        as total_routing_steps,
        count(actual_start_date)                        as completed_routing_steps,
        
        min(scheduled_start_date)                       as first_scheduled_start,
        max(scheduled_end_date)                         as last_scheduled_end,
        min(actual_start_date)                          as first_actual_start,
        max(actual_end_date)                            as last_actual_end,
        
        sum(planned_cost)                               as total_planned_cost,
        sum(actual_cost)                                as total_actual_cost,
        sum(actual_resource_hrs)                        as total_actual_resource_hrs
        
    from work_order_routing
    group by work_order_id
)

, enriched as (
    select
        -- Keys
        wo.work_order_id,
        wo.product_id,
        wo.scrap_reason_id,
        
        -- Work order quantities
        wo.order_qty,
        wo.stocked_qty,
        wo.scrapped_qty,
        
        -- Scrap info
        sr.scrap_reason_name,
        case 
            when wo.scrapped_qty > 0 then true 
            else false 
        end                                             as has_scrap,
        
        -- Scrap rate (percentage)
        case 
            when wo.order_qty > 0 
            then round(wo.scrapped_qty * 100.0 / wo.order_qty, 2)
            else 0 
        end                                             as scrap_rate_pct,
        
        -- Yield rate
        case 
            when wo.order_qty > 0 
            then round(coalesce(wo.stocked_qty, 0) * 100.0 / wo.order_qty, 2)
            else 0 
        end                                             as yield_rate_pct,
        
        -- Work order dates
        wo.start_date,
        wo.end_date,
        wo.due_date,
        
        -- Manufacturing lead time (days)
        date_diff('day', wo.start_date, wo.end_date)   as actual_lead_time_days,
        date_diff('day', wo.start_date, wo.due_date)   as planned_lead_time_days,
        
        -- On-time delivery analysis
        case
            when wo.end_date is null then 'In Progress'
            when wo.end_date <= wo.due_date then 'On Time'
            else 'Late'
        end                                             as delivery_status,
        
        case 
            when wo.end_date is not null 
            then date_diff('day', wo.end_date, wo.due_date) 
        end                                             as days_ahead_or_behind,
        
        -- Routing aggregates
        coalesce(ra.total_routing_steps, 0)             as total_routing_steps,
        coalesce(ra.completed_routing_steps, 0)         as completed_routing_steps,
        ra.first_scheduled_start,
        ra.last_scheduled_end,
        ra.first_actual_start,
        ra.last_actual_end,
        
        -- Cost analysis
        coalesce(ra.total_planned_cost, 0)              as total_planned_cost,
        coalesce(ra.total_actual_cost, 0)               as total_actual_cost,
        coalesce(ra.total_actual_cost, 0) 
            - coalesce(ra.total_planned_cost, 0)        as cost_variance,
        case 
            when coalesce(ra.total_planned_cost, 0) > 0 
            then round(
                (coalesce(ra.total_actual_cost, 0) - ra.total_planned_cost) 
                * 100.0 / ra.total_planned_cost, 2
            )
            else 0 
        end                                             as cost_variance_pct,
        
        -- Resource hours
        coalesce(ra.total_actual_resource_hrs, 0)       as total_actual_resource_hrs,
        
        -- Metadata
        wo.modified_date
        
    from work_order wo
    left join scrap_reason sr 
        on wo.scrap_reason_id = sr.scrap_reason_id
    left join routing_agg ra 
        on wo.work_order_id = ra.work_order_id
)

select * from enriched
