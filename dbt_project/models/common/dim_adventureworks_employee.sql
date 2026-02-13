{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_employee.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_employee') }}
)

select * from final
