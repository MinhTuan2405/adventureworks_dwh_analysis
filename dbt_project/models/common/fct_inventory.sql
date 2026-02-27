{{ 
  config(
    materialized = 'external',
    file_format = 'parquet',
    tags = [ 'dwh'],
    location = 's3://lakehouse/warehouse/fct_inventory.parquet'
  ) 
}}

-- Sử dụng lại logic Staging thông minh của bạn (đã tính KPI days_since...)
with stg_inventory as (
    select * from {{ ref('stg_inventory') }}
),

-- Lấy SK từ Dimension
dim_product as (
    select product_id, dim_product_sk
    from {{ ref('dim_product') }}
),

dim_location as (
    select location_id, dim_location_sk
    from {{ ref('dim_location') }}
),

final as (
    select
        -- Surrogate Key
        {{ dbt_utils.generate_surrogate_key(['i.product_id', 'i.location_id']) }} as inventory_sk,
        
        -- Foreign Keys
        coalesce(p.dim_product_sk, '-1') as dim_product_sk,
        coalesce(l.dim_location_sk, '-1') as dim_location_sk,

        -- Business Keys
        i.product_id,
        i.location_id,

        -- Attributes
        i.shelf,
        i.bin,
        i.is_manufactured_in_house,
        i.is_finished_good,
        
        -- Measures (Số dư hiện tại)
        i.quantity,
        i.standard_cost,
        i.list_price,
        i.total_manufacture_value,
        i.total_actual_value,

        -- KPI Quan trọng (Dead Stock Analysis)
        i.last_receipt_date,
        i.last_sale_date,
        i.days_since_last_receipt,
        i.days_since_last_sale,
        
        -- Phân loại sức khỏe kho (Tính sẵn ở đây để Power BI nhẹ gánh)
        case 
            when i.days_since_last_sale > 365 then 'Dead Stock' -- Hàng chết > 1 năm
            when i.days_since_last_sale > 180 then 'Slow Moving' -- Bán chậm > 6 tháng
            else 'Active'
        end as stock_health_status,

        -- Phân loại mức tồn kho (Dựa trên Safety Stock)
        case 
            when i.quantity <= i.safety_stock_level then 'Low'
            when i.quantity >= i.safety_stock_level * 3 then 'High'
            else 'Mid'
        end as stock_level_status

    from stg_inventory i
    left join dim_product p on i.product_id = p.product_id
    left join dim_location l on i.location_id = l.location_id
)

select * from final
where is_finished_good = true