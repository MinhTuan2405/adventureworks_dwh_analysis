{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_currency.parquet'
  ) 
}}

with currency_rate as (
    select * 
    from {{ ref('base_currency_rate') }}
)

, currency as (
    select *
    from {{ ref('base_currency') }}
)

, joined as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['cr.currency_rate_id']) }} as dim_currency_sk,
        
        -- Natural key
        cr.currency_rate_id,
        cr.currency_rate_date,
        
        -- From currency info
        cr.from_currency_code,
        trim(fc.name)                           as from_currency_name,
        
        -- To currency info
        cr.to_currency_code,
        trim(tc.name)                           as to_currency_name,
        
        -- Rate info
        cr.average_rate,
        cr.end_of_day_rate,
        
        
    from currency_rate cr
    left join currency fc
        on cr.from_currency_code = fc.currency_code
    left join currency tc
        on cr.to_currency_code = tc.currency_code
)

select * from joined