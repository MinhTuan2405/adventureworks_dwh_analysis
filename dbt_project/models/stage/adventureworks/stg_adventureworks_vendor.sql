{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_vendor.parquet'
  ) 
}}

with base as (
    select *
    from {{ ref('base_adventureworks_vendor')}}
)

, final as (
    select
        vendor_id,
        trim(account_number) as account_number,
        trim(vendor_name) as vendor_name,
        credit_rating,
        is_preferred_vendor,
        is_active,
    from base
)


select *
from final