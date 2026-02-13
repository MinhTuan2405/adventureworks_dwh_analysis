{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_person.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/person/person_person.parquet')
)

, rename as (
    select
        cast(BusinessEntityID as integer)           as business_entity_id,
        cast(PersonType as varchar)                 as person_type,
        cast(NameStyle as boolean)                  as is_eastern_name_order,
        cast(Title as varchar)                      as title,
        cast(FirstName as varchar)                  as first_name,
        cast(MiddleName as varchar)                 as middle_name,
        cast(LastName as varchar)                   as last_name,
        cast(Suffix as varchar)                     as suffix,
        cast(EmailPromotion as integer)             as email_promotion,
        cast(AdditionalContactInfo as varchar)      as additional_contact_info_xml,
        cast(Demographics as varchar)               as demographics_xml,
        cast(RowGuid as varchar)                    as rowguid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)
, parsing as (
    select 
        *
        -- extract between  <TotalPurchaseYTD>...</TotalPurchaseYTD>
        , cast(
            regexp_extract(demographics_xml, '<TotalPurchaseYTD>([^<]+)</TotalPurchaseYTD>', 1) 
          as decimal(18,2)) as total_purchase_ytd
    from rename
)

-- final
select * from parsing



