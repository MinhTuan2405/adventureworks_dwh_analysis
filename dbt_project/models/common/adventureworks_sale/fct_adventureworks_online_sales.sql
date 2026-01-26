{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/fct_adventureworks_online_sales.parquet'
  ) 
}}

with order_header as (
    select 
        sales_order_id,
        revision_number,
        order_date,
        due_date,
        ship_date,
        status_code,
        is_online_order,
        sales_order_number,
        purchase_order_number,
        account_number,
        customer_id,
        sales_person_id,
        territory_id,
        bill_to_address_id,
        ship_to_address_id,
        ship_method_id,
        credit_card_id,
        currency_rate_id,
        credit_card_approval_code,
        sub_total,
        tax_amount,
        freight_amount,
        total_due,
        comment
    from {{ ref('stg_adventureworks_sales_order_header') }}
    where is_online_order = true  -- Filter for online orders only
)

, order_detail as (
    select 
        sales_order_detail_id,
        sales_order_id,
        product_id,
        special_offer_id,
        carrier_tracking_number,
        order_qty,
        unit_price,
        unit_price_discount,
        line_total
    from {{ ref('stg_adventureworks_sales_order_details') }}
)

, joined as (
    select
        -- Fact grain: order line item
        d.sales_order_detail_id,
        h.sales_order_id,
        
        -- Date foreign keys (integer format YYYYMMDD)
        cast(strftime(h.order_date, '%Y%m%d') as integer) as order_date_key,
        cast(strftime(h.due_date, '%Y%m%d') as integer) as due_date_key,
        cast(strftime(h.ship_date, '%Y%m%d') as integer) as ship_date_key,
        
        -- Dimension foreign keys 
        h.customer_id,
        d.product_id,
        d.special_offer_id,
        h.sales_person_id,
        h.territory_id,
        h.bill_to_address_id as billing_address_id,
        h.ship_to_address_id as shipping_address_id,
        h.ship_method_id,
        h.credit_card_id,
        h.currency_rate_id,
        
        -- Degenerate dimensions (d
        h.sales_order_number,
        h.purchase_order_number,
        h.account_number,
        d.carrier_tracking_number,
        h.revision_number,
        h.status_code,
        h.credit_card_approval_code,
        h.comment,
        
        -- Measures
        d.order_qty,
        d.unit_price,
        d.unit_price_discount,
        d.line_total,
        
        -- Header level amounts 
        h.sub_total as order_sub_total,
        h.tax_amount as order_tax_amount,
        h.freight_amount as order_freight_amount,
        h.total_due as order_total_due,
        
        -- Derived measures
        d.unit_price * d.order_qty as gross_amount,
        d.unit_price * d.order_qty * d.unit_price_discount as discount_amount,
        d.line_total as net_amount
    
    from order_detail d
    inner join order_header h 
        on d.sales_order_id = h.sales_order_id
)

-- Dimension tables for surrogate key lookups
, dim_customer as (
    select 
        dim_adventureworks_customer_sk,
        customer_id
    from {{ ref('dim_adventureworks_customer') }}
)

, dim_product as (
    select 
        dim_adventureworks_product_sk,
        product_id
    from {{ ref('dim_adventureworks_product') }}
)

, dim_promotion as (
    select 
        dim_adventureworks_promotion_sk,
        special_offer_id
    from {{ ref('dim_adventureworks_promotion') }}
)

, dim_employee as (
    select 
        dim_adventureworks_employee_sk,
        employee_id
    from {{ ref('dim_adventureworks_employee') }}
)

, dim_sales_territory as (
    select 
        dim_adventureworks_sales_territory_sk,
        territory_id
    from {{ ref('dim_adventureworks_sales_territory') }}
)

, dim_geo_location_billing as (
    select 
        dim_adventureworks_geo_location_sk,
        address_id
    from {{ ref('dim_adventureworks_geo_location') }}
)

, dim_geo_location_shipping as (
    select 
        dim_adventureworks_geo_location_sk,
        address_id
    from {{ ref('dim_adventureworks_geo_location') }}
)

, final as (
    select
        -- Primary Key
        {{ dbt_utils.generate_surrogate_key(['j.sales_order_detail_id']) }} as fct_adventureworks_online_sales_pk,
        
        -- Foreign Keys 
        coalesce(dc.dim_adventureworks_customer_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_customer_sk,
        coalesce(dp.dim_adventureworks_product_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_product_sk,
        coalesce(dpr.dim_adventureworks_promotion_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_promotion_sk,
        coalesce(de.dim_adventureworks_employee_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_employee_sk,
        coalesce(dst.dim_adventureworks_sales_territory_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_sales_territory_sk,
        coalesce(dgb.dim_adventureworks_geo_location_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_geo_location_billing_sk,
        coalesce(dgs.dim_adventureworks_geo_location_sk, {{ dbt_utils.generate_surrogate_key(["'-1'"]) }}) as dim_adventureworks_geo_location_shipping_sk,
        
        -- Date Keys
        j.order_date_key,
        j.due_date_key,
        j.ship_date_key,
        
        -- Degenerate Dimensions
        j.sales_order_id,
        j.sales_order_number,
        j.purchase_order_number,
        j.account_number,
        j.carrier_tracking_number,
        j.revision_number,
        j.status_code,
        j.credit_card_approval_code,
        j.comment,
        j.ship_method_id,
        j.credit_card_id,
        j.currency_rate_id,
        
        -- Measures
        j.order_qty,
        j.unit_price,
        j.unit_price_discount,
        j.line_total,
        j.order_sub_total,
        j.order_tax_amount,
        j.order_freight_amount,
        j.order_total_due,
        j.gross_amount,
        j.discount_amount,
        j.net_amount
    
    from joined j
    left join dim_customer dc on j.customer_id = dc.customer_id
    left join dim_product dp on j.product_id = dp.product_id
    left join dim_promotion dpr on j.special_offer_id = dpr.special_offer_id
    left join dim_employee de on j.sales_person_id = de.employee_id
    left join dim_sales_territory dst on j.territory_id = dst.territory_id
    left join dim_geo_location_billing dgb on j.billing_address_id = dgb.address_id
    left join dim_geo_location_shipping dgs on j.shipping_address_id = dgs.address_id
)

-- final
select *
from final
