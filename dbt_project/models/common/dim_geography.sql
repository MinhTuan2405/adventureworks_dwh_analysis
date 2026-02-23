{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_geography.parquet'
  ) 
}}

with final as (
    select *
    from {{ ref('stg_address') }}
)

select * from final
