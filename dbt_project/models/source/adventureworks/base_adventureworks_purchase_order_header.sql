{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['adventureworks'],
    location = 's3://lakehouse/bronze/adventureworks/base_adventureworks_purchase_order_header.parquet'
  ) 
}}

with source as (
    select *
    from {{ source('adventureworks', 'purchase_order_header') }}
)

, final as (
    select
        cast(PurchaseOrderID as integer)            as purchase_order_id,
        cast(RevisionNumber as integer)             as revision_number,
        cast(Status as integer)                     as status,
        cast(EmployeeID as integer)                 as employee_id,
        cast(VendorID as integer)                   as vendor_id,
        cast(ShipMethodID as integer)               as ship_method_id,
        cast(OrderDate as timestamp)                as order_date,
        cast(ShipDate as timestamp)                 as ship_date,
        cast(SubTotal as decimal(19,4))             as sub_total,
        cast(TaxAmt as decimal(19,4))               as tax_amt,
        cast(Freight as decimal(19,4))              as freight,
        cast(TotalDue as decimal(19,4))             as total_due,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select *
from final
