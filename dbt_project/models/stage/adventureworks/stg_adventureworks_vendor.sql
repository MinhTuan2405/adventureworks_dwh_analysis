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

-- , vendor_address as (

-- )

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['vendor_id', 'account_number']) }} as dim_adventureworks_vendor_sk,
        
        -- Natural key
        vendor_id,
        account_number,
        
        -- Attributes
        trim(vendor_name) as vendor_name,
        credit_rating,
        is_preferred_vendor,
        is_active
    from base
)


select *
from final