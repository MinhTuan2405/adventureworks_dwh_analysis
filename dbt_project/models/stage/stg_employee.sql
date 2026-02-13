{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'staging'],
    location = 's3://lakehouse/silver/stg_employee.parquet'
  ) 
}}

with employee as (
    select * 
    from {{ ref('base_employee') }}
)

, person as (
    select *
    from {{ ref('base_person') }}
)

, joined as (
    select
        e.employee_id,
        
        -- Person info
        trim(p.first_name)                      as first_name,
        nullif(trim(p.middle_name), '')         as middle_name,
        trim(p.last_name)                       as last_name,
        nullif(trim(p.title), '')               as title,
        nullif(trim(p.suffix), '')              as suffix,
        
        -- Employee specific fields
        trim(e.national_id_number)              as national_id_number,
        trim(e.organization_node)               as organization_node_raw,
        e.organization_level,
        trim(e.job_title)                       as job_title,
        
        -- Dates
        e.birthday,
        e.hire_date,
        
        -- String attributes
        upper(trim(e.marital_status))           as marital_status,
        upper(trim(e.gender))                   as gender,
        
        -- Flags
        e.is_salaried,
        e.is_active,
        
        -- Hours
        e.vacation_hours_remaining,
        e.sick_leave_hours_remaining,
        
        -- Person metadata
        p.person_type,
        p.is_eastern_name_order,
        p.email_promotion,
        
        -- Metadata
        e.rowguid as employee_rowguid,
        p.rowguid as person_rowguid,
        e.modified_date as employee_modified_date,
        p.modified_date as person_modified_date
        
    from employee e
    left join person p
        on e.employee_id = p.business_entity_id
)

, reconstruct_organization_node as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as dim_employee_sk,
        
        employee_id,
        first_name,
        middle_name,
        last_name,
        title,
        suffix,
        national_id_number,
        job_title,
        birthday,
        hire_date,
        marital_status,
        gender,
        is_salaried,
        is_active,
        vacation_hours_remaining,
        sick_leave_hours_remaining,
        person_type,
        is_eastern_name_order,
        email_promotion,
        employee_rowguid,
        person_rowguid,
        employee_modified_date,
        person_modified_date,
        
        -- Reconstruct organization node
        case 
            when organization_node_raw is null then '/0/'
            else concat('/0', cast(organization_node_raw as varchar))
        end as organization_node,
        
        -- Calculate organization level based on node depth
        -- /0/ = level 0 (2 slashes)
        -- /0/1/ = level 1 (3 slashes)
        -- /0/1/1/1/ = level 3 (5 slashes)
        case 
            when organization_node_raw is null then 0
            else length(concat('/0', cast(organization_node_raw as varchar))) - length(replace(concat('/0', cast(organization_node_raw as varchar)), '/', '')) - 2
        end as organization_level

    from joined
)

select * from reconstruct_organization_node