{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = ['bronze', 'inventory'],
    location = 's3://lakehouse/bronze/base_product_inventory.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_productinventory.parquet')
),

renamed_and_casted as (
    select

        cast(ProductID as integer)      as product_id,
        cast(LocationID as integer)     as location_id,
        
        cast(Shelf as varchar)          as shelf,
        cast(Bin as integer)            as bin,
        
        cast(Quantity as integer)       as quantity,
        
        cast(ModifiedDate as timestamp) as modified_date,
        cast(rowguid as varchar)        as row_guid

    from source
),

trimed as (
    select
        product_id,
        location_id,
        
        lower(trim(shelf)) as shelf,
        
        bin,
        quantity,
        modified_date,
        row_guid
    from renamed_and_casted
)

select * from trimed
