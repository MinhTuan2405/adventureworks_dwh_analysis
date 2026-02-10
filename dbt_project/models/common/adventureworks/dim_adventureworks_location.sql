{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_location.parquet'
  ) 
}}

with staged as (
    select * from {{ ref('stg_adventureworks_location') }}
),

final as (
    select

        {{ dbt_utils.generate_surrogate_key(['location_id']) }} as dim_adventureworks_location_sk,
        
        location_id,
        
        location_name,
        cost_rate,
        availability,
        is_finished_goods_storage
        
    from staged
)

select * from final
