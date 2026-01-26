{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_store.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_store') }}
)

, cleaned as (
    select
        store_id,
        
        -- Clean string fields
        trim(store_name)                        as store_name,
        sales_person_id,
        
        -- Financial metrics
        annual_sales,
        annual_revenue,
        
        -- Store details
        nullif(trim(bank_name), '')             as bank_name,
        nullif(trim(business_type), '')         as business_type,
        year_opened,
        
        -- Store characteristics
        nullif(trim(specialty), '')             as specialty,
        square_feet,
        nullif(trim(brands_count), '')          as brands_count,
        nullif(trim(internet_type), '')         as internet_type,
        number_employees,
        
    from base
)

select * from cleaned