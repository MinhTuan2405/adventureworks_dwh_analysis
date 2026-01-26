{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_employee.parquet'
  ) 
}}

with employee as (
    select *
    from {{ ref('stg_adventureworks_employee') }}
)

, final as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['employee_id']) }} as dim_adventureworks_employee_sk,
        
        -- Natural key
        employee_id,
        
        -- Person attributes
        title,
        first_name,
        middle_name,
        last_name,
        suffix,
        
        -- Job attributes
        national_id_number,
        job_title,
        organization_level,
        organization_node,
        
        -- Demographics
        birthday,
        hire_date,
        marital_status,
        gender,
        
        -- Employment
        is_salaried,
        is_active,
        vacation_hours_remaining,
        sick_leave_hours_remaining
        
    from employee
)

select * from final
