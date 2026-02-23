{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/fct_purchase.parquet'
  ) 
}}

with stg_purchase as (
    select *
    from {{ ref('stg_purchase')}}
)

, stg_vendor as (
    select dim_vendor_sk, vendor_id
    from {{ ref('stg_vendor')}}
)

, stg_product as (
    select dim_product_sk, product_id
    from {{ ref('stg_product') }}
)

, stg_employee as (
    select dim_employee_sk, employee_id
    from {{ ref('stg_employee') }}
)

, stg_ship_method as (
    select dim_ship_method_sk, ship_method_id
    from {{ ref('stg_ship_method') }}
)

, dim_date as (
    select date_key
    from {{ ref('dim_date') }}
)

, joined as (
    select
        -- Fact grain: purchase order line item
        bp.purchase_order_detail_id,
        bp.purchase_order_id,
        
        -- Date foreign keys (YYYYMMDD)
        coalesce(dd_order.date_key, 19000101) as order_date_key,
        coalesce(dd_ship.date_key, 19000101) as ship_date_key,
        coalesce(dd_due.date_key, 19000101) as due_date_key,
        
        -- Dimension foreign keys (surrogate keys)
        coalesce(dv.dim_vendor_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_vendor_sk,
        coalesce(dp.dim_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_product_sk,
        coalesce(de.dim_employee_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_employee_sk,
        coalesce(dsm.dim_ship_method_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_ship_method_sk,
        
        -- Natural keys (for reference)
        bp.vendor_id,
        bp.product_id,
        bp.employee_id,
        bp.ship_method_id,
        
        -- Degenerate dimensions
        bp.revision_number,
        bp.order_status,
        
        -- Measures - Line level
        bp.order_qty,
        bp.unit_price,
        bp.line_total,
        bp.received_qty,
        bp.rejected_qty,
        bp.stocked_qty,
        bp.rejected_amount,
        bp.line_item_status,

        
        -- Measures - Order level
        bp.sub_total as order_sub_total,
        bp.tax_amt as order_tax_amount,
        bp.freight as order_freight_amount,
        bp.total_due as order_total_due
        
    from stg_purchase bp
    left join stg_vendor dv
        on bp.vendor_id = dv.vendor_id
    left join stg_product dp
        on bp.product_id = dp.product_id
    left join stg_employee de
        on bp.employee_id = de.employee_id
    left join stg_ship_method dsm
        on bp.ship_method_id = dsm.ship_method_id
    left join dim_date dd_order
        on cast(strftime(bp.order_date, '%Y%m%d') as integer) = dd_order.date_key
    left join dim_date dd_ship
        on cast(strftime(bp.ship_date, '%Y%m%d') as integer) = dd_ship.date_key
    left join dim_date dd_due
        on cast(strftime(bp.due_date, '%Y%m%d') as integer) = dd_due.date_key
)

, final as (
    select
        -- Primary key
        {{ dbt_utils.generate_surrogate_key(['purchase_order_id', 'purchase_order_detail_id']) }} as purchase_pk,
        
        *
    from joined
)

select * from final
