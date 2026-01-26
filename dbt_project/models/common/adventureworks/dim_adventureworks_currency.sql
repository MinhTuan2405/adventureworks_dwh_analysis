{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh', 'dimension'],
    location = 's3://lakehouse/gold/adventureworks/dim_adventureworks_currency.parquet'
  ) 
}}

with source as (
    select * 
    from {{ ref('stg_adventureworks_currency') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['currency_rate_id']) }} as dim_adventureworks_currency_sk,
        
        -- Natural key
        currency_rate_id,
        
        -- Date
        currency_rate_date,
        
        -- From currency attributes
        from_currency_code,
        from_currency_name,
        
        -- To currency attributes
        to_currency_code,
        to_currency_name,
        
        -- Rate attributes
        average_rate,
        end_of_day_rate

    from source
)

-- Add unknown member
, with_unknown as (
    select * from final
    union all
    select
        '-1' as dim_adventureworks_currency_sk,
        -1 as currency_rate_id,
        cast('1900-01-01' as date) as currency_rate_date,
        'N/A' as from_currency_code,
        'Unknown' as from_currency_name,
        'N/A' as to_currency_code,
        'Unknown' as to_currency_name,
        0.0 as average_rate,
        0.0 as end_of_day_rate
)

select * from with_unknown
