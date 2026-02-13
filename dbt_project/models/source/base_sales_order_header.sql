{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_sales_order_header.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_salesorderheader.parquet')
)

, renaming as (
    select
        cast(SalesOrderID as integer)               as sales_order_id,
        cast(RevisionNumber as integer)             as revision_number,
        cast(OrderDate as timestamp)                as order_date,
        cast(DueDate as timestamp)                  as due_date,
        cast(ShipDate as timestamp)                 as ship_date,
        cast(Status as integer)                     as status_code,
        cast(OnlineOrderFlag as boolean)            as is_online_order,
        cast(SalesOrderNumber as varchar)           as sales_order_number,
        cast(PurchaseOrderNumber as varchar)        as purchase_order_number,
        cast(AccountNumber as varchar)              as account_number,
        cast(CustomerID as integer)                 as customer_id,
        cast(SalesPersonID as integer)              as sales_person_id,
        cast(TerritoryID as integer)                as territory_id,
        cast(BillToAddressID as integer)            as bill_to_address_id,
        cast(ShipToAddressID as integer)            as ship_to_address_id,
        cast(ShipMethodID as integer)               as ship_method_id,
        cast(CreditCardID as integer)               as credit_card_id,
        cast(CreditCardApprovalCode as varchar)     as credit_card_approval_code,
        cast(CurrencyRateID as integer)             as currency_rate_id,
        cast(SubTotal as decimal(19,4))             as sub_total,
        cast(TaxAmt as decimal(19,4))               as tax_amount,
        cast(Freight as decimal(19,4))              as freight_amount,
        cast(nullif(TotalDue, $$None$$) as decimal(19,4)) as total_due,
        cast(Comment as varchar)                    as comment,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

-- final
select * from renaming