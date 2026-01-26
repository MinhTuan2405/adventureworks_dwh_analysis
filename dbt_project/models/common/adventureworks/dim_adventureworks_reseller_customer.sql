{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_reseller_customer.parquet'
  ) 
}}

with customer as (
    select *
    from {{ ref('stg_adventureworks_customer') }}
    where is_online_customer = false
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as dim_adventureworks_reseller_customer_sk,
        
        -- Natural keys
        customer_id,
        store_id,
        
        -- Foreign keys
        person_id,
        territory_id,
        
        -- Person attributes
        person_type,
        is_eastern_name_order,
        title,
        first_name,
        middle_name,
        last_name,
        suffix,
        full_name,
        
        -- Store attributes
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
        store_number_employees
        
    from customer
)

select * from final
