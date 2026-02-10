{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_employee.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_adventureworks_employee') }}
)

select * from final
