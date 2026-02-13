{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_store.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/sales/sales_store.parquet')
)

, renaming as (
    select
        cast(BusinessEntityID as integer)           as store_id,
        cast(Name as varchar)                       as store_name,
        cast(SalesPersonID as integer)              as sales_person_id,
        cast(Demographics as varchar)               as demographics_xml,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

, parsing_xml as (
    select 
        *,
        -- Doanh thu và Lợi nhuận
        cast(regexp_extract(demographics_xml, '<AnnualSales>([^<]+)</AnnualSales>', 1) as decimal(18,2))           as annual_sales,
        cast(regexp_extract(demographics_xml, '<AnnualRevenue>([^<]+)</AnnualRevenue>', 1) as decimal(18,2))       as annual_revenue,
        
        -- Thông tin vận hành
        cast(regexp_extract(demographics_xml, '<BankName>([^<]+)</BankName>', 1) as varchar)                       as bank_name,
        cast(regexp_extract(demographics_xml, '<BusinessType>([^<]+)</BusinessType>', 1) as varchar)               as business_type,
        cast(regexp_extract(demographics_xml, '<YearOpened>([^<]+)</YearOpened>', 1) as integer)                   as year_opened,
        
        -- Đặc thù cửa hàng
        cast(regexp_extract(demographics_xml, '<Specialty>([^<]+)</Specialty>', 1) as varchar)                     as specialty,
        cast(regexp_extract(demographics_xml, '<SquareFeet>([^<]+)</SquareFeet>', 1) as integer)                   as square_feet,
        cast(regexp_extract(demographics_xml, '<Brands>([^<]+)</Brands>', 1) as varchar)                           as brands_count,
        cast(regexp_extract(demographics_xml, '<Internet>([^<]+)</Internet>', 1) as varchar)                       as internet_type,
        cast(regexp_extract(demographics_xml, '<NumberEmployees>([^<]+)</NumberEmployees>', 1) as integer)         as number_employees
    from renaming
)

-- final
select * from parsing_xml