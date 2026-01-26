{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_sales_order_header.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_sales_order_header') }}
)

, cleaned as (
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
        nullif(trim(comment), '')               as comment,
        
    from base
)

select * from cleaned