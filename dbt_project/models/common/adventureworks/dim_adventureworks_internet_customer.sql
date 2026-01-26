{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_internet_customer.parquet'
  ) 
}}

with customer as (
    select *
    from {{ ref('stg_adventureworks_customer') }}
    where is_online_customer = true
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as dim_adventureworks_internet_customer_sk,
        
        -- Natural key
        customer_id,
        
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
        
        -- Marketing
        email_promotion,
        total_purchase_ytd
        
    from customer
)

select * from final
