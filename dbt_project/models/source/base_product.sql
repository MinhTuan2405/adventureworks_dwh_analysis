{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags =['bronze'],
    location = 's3://lakehouse/bronze/base_product.parquet'
  ) 
}}

with source as (
    select *
    from read_parquet('s3://lakehouse/landing/production/production_product.parquet')
)

, renaming as (
    select
        cast(ProductID as integer)                  as product_id,
        cast(Name as varchar)                       as product_name,
        cast(ProductNumber as varchar)              as product_number,
        cast(MakeFlag as boolean)                   as is_manufactured_in_house,
        cast(FinishedGoodsFlag as boolean)          as is_finished_good,
        cast(Color as varchar)                      as color,
        cast(SafetyStockLevel as integer)           as safety_stock_level,
        cast(ReorderPoint as integer)               as reorder_point,
        cast(StandardCost as decimal(19,4))         as standard_cost,
        cast(ListPrice as decimal(19,4))            as list_price,
        cast(Size as varchar)                       as size,
        cast(SizeUnitMeasureCode as varchar)        as size_unit_measure_code,
        cast(WeightUnitMeasureCode as varchar)      as weight_unit_measure_code,
        cast(Weight as decimal(8,2))                as weight,
        cast(DaysToManufacture as integer)          as days_to_manufacture,
        cast(ProductLine as varchar)                as product_line_code,
        cast(Class as varchar)                      as class_code,
        cast(Style as varchar)                      as style_code,
        cast(ProductSubcategoryID as integer)       as product_subcategory_id,
        cast(ProductModelID as integer)             as product_model_id,
        cast(SellStartDate as timestamp)            as sell_start_date,
        cast(SellEndDate as timestamp)              as sell_end_date,
        cast(nullif(DiscontinuedDate, $$None$$) as timestamp) as discontinued_date,
        cast(rowguid as varchar)                    as row_guid,
        cast(ModifiedDate as timestamp)             as modified_date
    from source
)

select * from renaming