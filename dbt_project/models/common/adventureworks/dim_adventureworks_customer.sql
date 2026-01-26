{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'dwh'],
    location = 's3://lakehouse/warehouse/adventureworks/dim_adventureworks_customer.parquet'
  ) 
}}

with customer as (
    select 
        customer_id,
        person_id,
        store_id,
        territory_id,
        account_number
    from {{ ref('stg_adventureworks_customer') }}
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
        suffix,
        email_promotion,
        
    from {{ ref('stg_adventureworks_person') }}
)

, joined as (
    select
        c.customer_id,
        c.account_number,
        c.store_id,
        c.territory_id,
        
        -- Person attributes
        p.person_type,
        p.is_eastern_name_order,
        p.title,
        p.first_name,
        p.middle_name,
        p.last_name,
        p.suffix,
        
        -- Computed full name
        concat_ws(' ', 
            nullif(trim(p.title), ''),
            p.first_name, 
            nullif(trim(p.middle_name), ''),
            p.last_name,
            nullif(trim(p.suffix), '')
        ) as full_name,
        
        p.email_promotion,
        
    
    from customer c
    left join person p 
        on c.person_id = p.business_entity_id
)

, add_key as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as dim_adventureworks_customer_sk,
        
        -- Natural Key
        customer_id,
        
        -- Attributes
        account_number,
        store_id,
        territory_id,
        person_type,
        is_eastern_name_order,
        title,
        first_name,
        middle_name,
        last_name,
        suffix,
        full_name,
        email_promotion,
    from joined
)

-- final
select *
from add_key