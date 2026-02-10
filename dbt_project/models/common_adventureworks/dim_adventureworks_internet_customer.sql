{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_internet_customer.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_adventureworks_customer') }}
    where is_online_customer = true
)

select * from final
