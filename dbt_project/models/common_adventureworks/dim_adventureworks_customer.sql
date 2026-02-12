{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_customer.parquet'
  ) 
}}

with stg_customer as (
    select *
    from {{ ref('stg_adventureworks_customer') }}
)

, final as (
    select
        -- Surrogate key from staging
        dim_adventureworks_customer_sk,
        customer_id,
        territory_id,
        person_id,
        person_type,
        is_eastern_name_order,
        title,
        first_name,
        middle_name,
        last_name,
        suffix,
        full_name,
        email_promotion,
        total_purchase_ytd,
        store_id,
        store_name,
        store_sales_person_id,
        store_annual_sales,
        store_annual_revenue,
        store_bank_name,
        store_business_type,
        store_year_opened,
        store_specialty,
        store_square_feet,
        store_brands_count,
        store_internet_type,
        store_number_employees,
        case 
            when is_online_customer then 'Internet'
            else 'Reseller'
        end as customer_type
    from stg_customer
)

select * from final
