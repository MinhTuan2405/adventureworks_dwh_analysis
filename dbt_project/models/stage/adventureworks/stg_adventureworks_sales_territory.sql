{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'staging'],
    location = 's3://lakehouse/silver/adventureworks/stg_adventureworks_sales_territory.parquet'
  ) 
}}

with sales_territory as (
    select * 
    from {{ ref('base_adventureworks_sales_territory') }}
)

, country as (
    select *
    from {{ ref('base_adventureworks_country') }}
)

, joined as (
    select
        -- Surrogate key
        {{ dbt_utils.generate_surrogate_key(['st.territory_id']) }} as dim_adventureworks_sales_territory_sk,
        
        -- Natural key
        st.territory_id,
        
        -- Clean string fields
        trim(st.territory_name)                 as territory_name,
        trim(st.country_region_code)            as country_region_code,
        trim(c.name)                            as country_name,
        trim(st.territory_group)                as territory_group,
        
        -- Financial metrics
        st.sales_ytd,
        st.sales_last_year,
        st.cost_ytd,
        st.cost_last_year,
        
        -- Calculated metrics
        st.sales_ytd - st.sales_last_year       as sales_growth,
        st.cost_ytd - st.cost_last_year         as cost_growth,

    from sales_territory st
    left join country c
        on st.country_region_code = c.country_region_code
)

select * from joined