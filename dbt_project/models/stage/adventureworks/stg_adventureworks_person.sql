{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_person.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_person') }}
)

, cleaned as (
    select
        business_entity_id,
        
        -- Clean string fields
        trim(person_type)                       as person_type,
        is_eastern_name_order,
        nullif(trim(title), '')                 as title,
        trim(first_name)                        as first_name,
        nullif(trim(middle_name), '')           as middle_name,
        trim(last_name)                         as last_name,
        nullif(trim(suffix), '')                as suffix,
        
        -- Email settings
        email_promotion,
        
        -- XML fields (keep as-is for downstream processing)
        additional_contact_info_xml,
        demographics_xml,
        
        -- Parsed demographic data
        total_purchase_ytd,
        
    from base
)

select * from cleaned