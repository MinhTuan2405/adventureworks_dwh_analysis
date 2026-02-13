{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/fct_sales.parquet'
  ) 
}}

with sales as (
    select *
    from {{ ref('stg_sales') }}
)

, stg_customer as (
    select 
        dim_customer_sk,
        customer_id
    from {{ ref('stg_customer') }}
)

, stg_product as (
    select dim_product_sk, product_id
    from {{ ref('stg_product') }}
)

, stg_employee as (
    select dim_employee_sk, employee_id
    from {{ ref('stg_employee') }}
)

, stg_territory as (
    select dim_sales_territory_sk, territory_id
    from {{ ref('stg_sales_territory') }}
)

, stg_geo_bill as (
    select dim_geography_sk, address_id
    from {{ ref('stg_address') }}
)

, stg_geo_ship as (
    select dim_geography_sk, address_id
    from {{ ref('stg_address') }}
)

, stg_ship_method as (
    select dim_ship_method_sk, ship_method_id
    from {{ ref('stg_ship_method') }}
)

, stg_currency as (
    select dim_currency_sk, currency_rate_id
    from {{ ref('stg_currency') }}
)

, dim_date as (
    select date_key
    from {{ ref('dim_date') }}
)

, joined as (
    select
        -- Fact grain: order line item
        s.sales_order_detail_id,
        s.sales_order_id,
        
        -- Date foreign keys (YYYYMMDD)
        coalesce(dd_order.date_key, 19000101) as order_date_key,
        coalesce(dd_due.date_key, 19000101) as due_date_key,
        coalesce(dd_ship.date_key, 19000101) as ship_date_key,
        
        -- Dimension foreign keys (surrogate keys)
        coalesce(dc.dim_customer_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_customer_sk,
        coalesce(dp.dim_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_product_sk,
        coalesce(de.dim_employee_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_employee_sk,
        coalesce(dt.dim_sales_territory_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_sales_territory_sk,
        coalesce(dgb.dim_geography_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_geography_bill_sk,
        coalesce(dgs.dim_geography_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_geography_ship_sk,
        coalesce(dsm.dim_ship_method_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_ship_method_sk,
        coalesce(dcur.dim_currency_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_currency_sk,
        
        -- Sales channel classification
        case 
            when s.is_online_order then 'Internet'
            else 'Reseller'
        end as sales_channel,
        
        -- Natural keys (for reference)
        s.customer_id,
        s.product_id,
        s.sales_person_id,
        s.territory_id,
        s.bill_to_address_id,
        s.ship_to_address_id,
        s.ship_method_id,
        s.special_offer_id,
        s.credit_card_id,
        s.currency_rate_id,
        
        -- Degenerate dimensions
        s.sales_order_number,
        s.purchase_order_number,
        s.account_number,
        s.revision_number,
        s.status_code,
        s.carrier_tracking_number,
        s.credit_card_approval_code,
        s.comment,
        
        -- Measures - Line level
        s.order_qty,
        s.unit_price,
        s.unit_price_discount,
        s.line_total,
        
        -- Measures - Order level
        s.sub_total as order_sub_total,
        s.tax_amount as order_tax_amount,
        s.freight_amount as order_freight_amount,
        s.total_due as order_total_due
        
    from sales s
    left join stg_customer dc
        on s.customer_id = dc.customer_id
    left join stg_product dp
        on s.product_id = dp.product_id
    left join stg_employee de
        on s.sales_person_id = de.employee_id
    left join stg_territory dt
        on s.territory_id = dt.territory_id
    left join stg_geo_bill dgb
        on s.bill_to_address_id = dgb.address_id
    left join stg_geo_ship dgs
        on s.ship_to_address_id = dgs.address_id
    left join stg_ship_method dsm
        on s.ship_method_id = dsm.ship_method_id
    left join stg_currency dcur
        on s.currency_rate_id = dcur.currency_rate_id
    left join dim_date dd_order
        on cast(strftime(s.order_date, '%Y%m%d') as integer) = dd_order.date_key
    left join dim_date dd_due
        on cast(strftime(s.due_date, '%Y%m%d') as integer) = dd_due.date_key
    left join dim_date dd_ship
        on cast(strftime(s.ship_date, '%Y%m%d') as integer) = dd_ship.date_key
)

, final as (
    select
        -- Primary key
        {{ dbt_utils.generate_surrogate_key(['sales_order_detail_id']) }} as sales_pk,
        
        *
    from joined
)

select * from final
