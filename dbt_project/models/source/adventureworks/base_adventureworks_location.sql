{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['adventureworks', 'bronze', 'inventory'],
    location = 's3://lakehouse/bronze/adventureworks/base_product_location.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_location.parquet')
),

renamed_and_casted as (
    select

        cast(LocationID as integer)     as location_id,

        cast(Name as varchar)           as location_name,
        cast(CostRate as decimal(18,4)) as cost_rate,   
        cast(Availability as decimal(8,2)) as availability,
        
        cast(ModifiedDate as timestamp) as modified_date

    from source
),

trimed as (
    select
        location_id,
        lower(trim(location_name)) as location_name,
        cost_rate,
        availability,
        modified_date
    from renamed_and_casted
)

select * from trimed
