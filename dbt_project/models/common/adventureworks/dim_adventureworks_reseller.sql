{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_reseller.parquet'
  ) 
}}

with store as (
    select 
        store_id,
        store_name,
        sales_person_id,
        annual_sales,
        annual_revenue,
        bank_name,
        business_type,
        year_opened,
        specialty,
        square_feet,
        brands_count,
        internet_type,
        number_employees
    from {{ ref('stg_adventureworks_store') }}
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['store_id']) }} as dim_adventureworks_reseller_sk,
        
        -- Natural Key
        store_id,
        
        -- Attributes
        store_name,
        sales_person_id,
        business_type,
        specialty,
        year_opened,
        
        -- Financial metrics
        annual_sales,
        annual_revenue,
        
        -- Store characteristics
        square_feet,
        number_employees,
        brands_count,
        internet_type,
        bank_name
    from store
)

-- final
select *
from add_key