{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_employee.parquet'
  ) 
}}

with employee as (
    select 
        employee_id,
        national_id_number,
        organization_node,
        organization_level,
        job_title,
        birthday,
        hire_date,
        marital_status,
        gender,
        is_salaried,
        is_active,
        vacation_hours_remaining,
        sick_leave_hours_remaining
    from {{ ref('stg_adventureworks_employee') }}
)

, person as (
    select 
        business_entity_id,
        person_type,
        is_eastern_name_order,
        title,
        first_name,
        middle_name,
        last_name,
        suffix
    from {{ ref('stg_adventureworks_person') }}
)

, joined as (
    select
        e.employee_id,
        e.national_id_number,
        e.organization_node,
        e.organization_level,
        e.job_title,
        e.birthday,
        e.hire_date,
        e.marital_status,
        e.gender,
        e.is_salaried,
        e.is_active,
        e.vacation_hours_remaining,
        e.sick_leave_hours_remaining,
        
        -- Person attributes
        p.person_type,
        p.is_eastern_name_order,
        p.title,
        p.first_name,
        p.middle_name,
        p.last_name,
        p.suffix,
        
        -- full name
        concat_ws(' ', 
            nullif(trim(p.title), ''),
            p.first_name, 
            nullif(trim(p.middle_name), ''),
            p.last_name,
            nullif(trim(p.suffix), '')
        ) as full_name
    
    from employee e
    left join person p 
        on e.employee_id = p.business_entity_id
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as dim_adventureworks_employee_sk,
        
        -- Natural Key
        employee_id,
        
        -- Person Attributes
        person_type,
        is_eastern_name_order,
        title,
        first_name,
        middle_name,
        last_name,
        suffix,
        full_name,
        
        -- Employee Attributes
        national_id_number,
        organization_node,
        organization_level,
        job_title,
        birthday,
        hire_date,
        marital_status,
        gender,
        is_salaried,
        is_active,
        vacation_hours_remaining,
        sick_leave_hours_remaining
    from joined
)

-- final
select *
from add_key