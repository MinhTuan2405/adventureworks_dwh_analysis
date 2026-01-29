{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_purchase.parquet'
  ) 
}}

with base_purchase_header as (
    select *
    from {{ ref('base_adventureworks_purchase_order_header')}}
)

, base_purchase_details as (
    select *
    from {{ ref('base_adventureworks_purchase_order_details')}}
)

, cleaned_header as (
    select 
        purchase_order_id,
        revision_number,
        case 
            when status = 1 then 'Pending'
            when status = 2 then 'Approved'
            when status = 3 then 'Rejected'
            when status = 4 then 'Complete'
            else 'Unknown'
        end as order_status,
        employee_id,
        vendor_id,
        ship_method_id,
        order_date,
        ship_date,
        sub_total,
        tax_amt,
        freight,
        -- re-calculte the total due 
        -- all of the details
        -- total due = sum (sub line total + tax + freight)
        coalesce(
            nullif(total_due, 0),
            sub_total + tax_amt + freight
        )      as total_due         
        
    from base_purchase_header
)

, cleaned_details as (
    select
        purchase_order_id,
        purchase_order_detail_id,
        due_date,
        order_qty,
        product_id,
        unit_price,
        -- re-calculate the line total for each details
        coalesce(
            nullif(line_total, 0),
            order_qty * unit_price
        )           as line_total,
        received_qty,
        rejected_qty,

        -- re-calculate the stoked quantity
        coalesce(
            nullif(stocked_qty, 0),
            received_qty - rejected_qty
        )           as stocked_qty,
        
    from base_purchase_details
)

, joined as (
    select
        -- header
        h.purchase_order_id,
        h.revision_number,
        h.order_status,
        h.employee_id,
        h.vendor_id,
        h.ship_method_id,
        h.order_date,
        h.ship_date,
        h.sub_total,
        h.tax_amt,
        h.freight,
        h.total_due,

        -- detail
        c.purchase_order_detail_id,
        c.due_date,
        c.order_qty,
        c.product_id,
        c.unit_price,
        c.line_total,
        c.received_qty,
        c.rejected_qty,
        c.stocked_qty,

    from cleaned_header h
    left join cleaned_details c
        on h.purchase_order_id = c.purchase_order_id

)

select *
from joined