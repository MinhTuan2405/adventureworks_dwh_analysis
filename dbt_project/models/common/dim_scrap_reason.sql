{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/dim_scrap_reason.parquet'
  ) 
}}

with source as (
    select * from {{ ref('base_scrap_reason') }}
)

, final as (
    select
        {{ dbt_utils.generate_surrogate_key(['scrap_reason_id']) }} as dim_scrap_reason_sk,
        
        scrap_reason_id,
        scrap_reason_name,
        
        -- Classify scrap reasons into categories for analysis
        case
            when lower(scrap_reason_name) like '%paint%' 
                or lower(scrap_reason_name) like '%color%' 
                then 'Paint/Finish'
            when lower(scrap_reason_name) like '%drill%' 
                or lower(scrap_reason_name) like '%machine%'
                or lower(scrap_reason_name) like '%trim%'
                then 'Machining'
            when lower(scrap_reason_name) like '%weld%' 
                or lower(scrap_reason_name) like '%gouge%'
                then 'Welding'
            when lower(scrap_reason_name) like '%thermoform%' 
                or lower(scrap_reason_name) like '%stress%'
                then 'Forming'
            else 'Other'
        end as scrap_category
        
    from source
)

select * from final
