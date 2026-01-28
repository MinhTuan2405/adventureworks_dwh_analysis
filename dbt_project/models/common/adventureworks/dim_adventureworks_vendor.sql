{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_vendor.parquet'
  ) 
}}


with base as (
    select *
    from {{ ref ('stg_adventureworks_vendor')}}
)

, add_key as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['vendor_id', 'account_number']) }} as dim_adventureworks_vendor_sk,


        -- Natural key
        vendor_id,
        account_number,

        -- Attributes
        vendor_name,
        credit_rating,
        is_preferred_vendor,
        is_active

    from base
)

select *
from add_key