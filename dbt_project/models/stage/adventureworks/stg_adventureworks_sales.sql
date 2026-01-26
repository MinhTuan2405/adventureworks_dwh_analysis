{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_sales.parquet'
  ) 
}}

with base_header as (
    select * 
    from {{ ref('base_adventureworks_sales_order_header') }}
)

, base_details as (
    select * 
    from {{ ref('base_adventureworks_sales_order_details') }}
)

, cleaned_header as (
    select
        sales_order_id,
        revision_number,
        
        -- Dates
        order_date,
        due_date,
        ship_date,
        
        -- Status and flags
        status_code,
        is_online_order,
        
        -- Order identifiers
        trim(sales_order_number)                as sales_order_number,
        nullif(trim(purchase_order_number), '') as purchase_order_number,
        nullif(trim(account_number), '')        as account_number,
        
        -- Foreign keys
        customer_id,
        sales_person_id,
        territory_id,
        bill_to_address_id,
        ship_to_address_id,
        ship_method_id,
        credit_card_id,
        currency_rate_id,
        
        -- Payment
        nullif(trim(credit_card_approval_code), '') as credit_card_approval_code,
        
        -- Amounts
        sub_total,
        tax_amount,
        freight_amount,
        
        -- Total due calculation: SubTotal + TaxAmt + Freight
        coalesce(
            (sub_total + tax_amount) + freight_amount,
            0
        )                                           as total_due,
        
        -- Comments
        nullif(trim(comment), '')               as comment
        
    from base_header
)

, cleaned_details as (
    select
        sales_order_detail_id,
        sales_order_id,
        product_id,
        special_offer_id,
        
        -- Order details
        nullif(trim(carrier_tracking_number), '') as carrier_tracking_number,
        order_qty,
        
        -- Pricing
        unit_price,
        unit_price_discount,
        
        -- Calculated line total with business logic
        coalesce(
            nullif(line_total, 0),
            (unit_price * (1.0 - unit_price_discount)) * order_qty
        )                                       as line_total
        
    from base_details
)

, joined as (
    select
        -- Detail level ID
        d.sales_order_detail_id,
        
        -- Header fields
        h.sales_order_id,
        h.revision_number,
        h.sales_order_number,
        h.purchase_order_number,
        h.account_number,
        
        -- Dates
        h.order_date,
        h.due_date,
        h.ship_date,
        
        -- Status and flags
        h.status_code,
        h.is_online_order,
        
        -- Foreign keys from header
        h.customer_id,
        h.sales_person_id,
        h.territory_id,
        h.bill_to_address_id,
        h.ship_to_address_id,
        h.ship_method_id,
        h.credit_card_id,
        h.currency_rate_id,
        
        -- Payment info
        h.credit_card_approval_code,
        
        -- Header amounts
        h.sub_total,
        h.tax_amount,
        h.freight_amount,
        h.total_due,
        h.comment,
        
        -- Detail fields
        d.product_id,
        d.special_offer_id,
        d.carrier_tracking_number,
        d.order_qty,
        d.unit_price,
        d.unit_price_discount,
        d.line_total
        
    from cleaned_header h
    left join cleaned_details d
        on h.sales_order_id = d.sales_order_id
)

select * from joined
