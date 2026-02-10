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
        case 
            when credit_rating = 1 then 'Superior'
            when credit_rating = 2 then 'Excellent'
            when credit_rating = 3 then 'Above Average'
            when credit_rating = 4 then 'Average'
            when credit_rating = 5 then 'Below Average'
          else 'Unknown'
        end as credit_rating_desc,
        is_preferred_vendor,
        is_active
    from base
)


select *
from final