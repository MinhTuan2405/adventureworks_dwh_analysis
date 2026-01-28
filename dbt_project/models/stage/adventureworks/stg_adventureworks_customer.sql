{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_customer_person.parquet'
  ) 
}}

with base_customer as (
    select * 
    from {{ ref('base_adventureworks_customer') }}
)

, base_person as (
    select *
    from {{ ref('base_adventureworks_person') }}
)

, base_store as (
    select *
    from {{ ref('base_adventureworks_store') }}
)

, cleaned_customer as (
    select
        customer_id,
        person_id,
        store_id,
        territory_id,
        
        -- Clean string fields
        nullif(trim(account_number), '')        as account_number
        
    from base_customer
)

, cleaned_person as (
    select
        business_entity_id,
        person_type,
        is_eastern_name_order,
        
        -- Name components
        nullif(trim(title), '')                 as title,
        trim(first_name)                        as first_name,
        nullif(trim(middle_name), '')           as middle_name,
        trim(last_name)                         as last_name,
        nullif(trim(suffix), '')                as suffix,
        
        -- Full name construction
        concat_ws(' ',
            nullif(trim(title), ''),
            trim(first_name),
            nullif(trim(middle_name), ''),
            trim(last_name),
            nullif(trim(suffix), '')
        )                                       as full_name,
        
        -- Marketing and contact
        email_promotion,
        additional_contact_info_xml,
        demographics_xml,
        total_purchase_ytd
        
    from base_person
)

, cleaned_store as (
    select
        store_id,
        
        -- Store info
        trim(store_name)                        as store_name,
        sales_person_id,
        
        -- Financial metrics
        annual_sales,
        annual_revenue,
        
        -- Business details
        nullif(trim(bank_name), '')             as bank_name,
        nullif(trim(business_type), '')         as business_type,
        year_opened,
        
        -- Store characteristics
        nullif(trim(specialty), '')             as specialty,
        square_feet,
        brands_count,
        nullif(trim(internet_type), '')         as internet_type,
        number_employees
        
    from base_store
)

, joined as (
    select
        -- Surrogate keys (for both internet and reseller)
        {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as dim_adventureworks_internet_customer_sk,
        {{ dbt_utils.generate_surrogate_key(['c.customer_id', 's.store_id']) }} as dim_adventureworks_reseller_customer_sk,
        
        -- Customer identifiers
        c.customer_id,
        c.territory_id,
        
        -- Person identifiers
        p.business_entity_id as person_id,
        p.person_type,
        
        -- Name information
        p.is_eastern_name_order,
        p.title,
        p.first_name,
        p.middle_name,
        p.last_name,
        p.suffix,
        p.full_name,
        
        -- Marketing and analytics
        p.email_promotion,
        p.total_purchase_ytd,
        
        -- Store information
        s.store_id,
        s.store_name,
        s.sales_person_id as store_sales_person_id,
        s.annual_sales as store_annual_sales,
        s.annual_revenue as store_annual_revenue,
        s.bank_name as store_bank_name,
        s.business_type as store_business_type,
        s.year_opened as store_year_opened,
        s.specialty as store_specialty,
        s.square_feet as store_square_feet,
        s.brands_count as store_brands_count,
        s.internet_type as store_internet_type,
        s.number_employees as store_number_employees,
        
        -- Customer type classification
        case 
            when s.store_id is null then true
            else false
        end as is_online_customer
        
    from cleaned_customer c
    left join cleaned_person p
        on c.person_id = p.business_entity_id
    left join cleaned_store s
        on c.store_id = s.store_id
)

select * from joined