{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_employee.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/humanresources/humanresources_employee.parquet')
)

, rename as (
    select
        cast(BusinessEntityID as integer)       as employee_id,
        cast(NationalIDNumber as varchar)       as national_id_number,
        cast(OrganizationNode as varchar)       as organization_node,
        cast(nullif(OrganizationLevel, $$None$$) as integer) as organization_level,
        cast(JobTitle as varchar)               as job_title,
        cast(BirthDate as timestamp)            as birthday,
        cast(MaritalStatus as varchar)          as marital_status,
        cast(Gender as varchar)                 as gender,
        cast(HireDate as timestamp)             as hire_date,
        cast(SalariedFlag as boolean)           as is_salaried,
        cast(VacationHours as integer)          as vacation_hours_remaining,
        cast(SickLeaveHours as integer)         as sick_leave_hours_remaining,
        cast(CurrentFlag as boolean)            as is_active,
        cast(RowGuid as varchar)                as rowguid,
        cast(ModifiedDate as timestamp)         as modified_date
    from source
)

-- final
select *
from rename