{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_employee.parquet'
  ) 
}}

with base as (
    select * 
    from {{ ref('base_adventureworks_employee') }}
)

, cleaned as (
    select
        employee_id,
        
        -- Clean string fields
        trim(national_id_number)                as national_id_number,
        trim(organization_node)                 as organization_node_raw,
        organization_level,
        trim(job_title)                         as job_title,
        
        -- Dates
        birthday,
        hire_date,
        
        -- String attributes
        upper(trim(marital_status))             as marital_status,
        upper(trim(gender))                     as gender,

        
        -- Flags
        is_salaried,
        is_active,
        
        -- Hours
        vacation_hours_remaining,
        sick_leave_hours_remaining,
        
    from base
)

, re_constructor_organization_node as (
    select
        employee_id,
        national_id_number,
        organization_level,
        job_title,
        birthday,
        hire_date,
        marital_status,
        gender,
        is_salaried,
        is_active,
        vacation_hours_remaining,
        sick_leave_hours_remaining,
        
        -- Reconstruct organization node
        case 
            when organization_node_raw is null then '/0/'
            else concat('/0', cast(organization_node_raw as varchar))
        end as organization_node

    from cleaned

)

select * from re_constructor_organization_node