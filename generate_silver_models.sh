#!/bin/bash

# ==============================================================================
# SCRIPT TẠO DBT MODELS CHO SILVER LAYER
# Source: bronze models (Đọc từ dbt models đã tạo trước đó)
# Target: silver (S3 Bronze -> S3 Silver)
# Logic: SELECT * FROM bronze (Ban đầu sẽ là 1-1, bạn có thể thêm logic clean sau)
# ==============================================================================

# 1. Cấu hình đường dẫn
TARGET_DIR="dbt_project/models/silver"

# # Tạo thư mục nếu chưa tồn tại
# if [ ! -d "$TARGET_DIR" ]; then
#     echo "Creating directory: $TARGET_DIR"
#     mkdir -p "$TARGET_DIR"
# fi

# 2. Danh sách các bảng (Giống hệt Bronze)
TABLES=(
    "person_businessentity"
    "person_person"
    "person_address"
    "person_stateprovince"
    "person_countryregion"
    "humanresources_employee"
    "production_product"
    "purchasing_shipmethod"
    "sales_salesterritory"
    "sales_store"
    "sales_salesperson"
    "sales_salespersonquotahistory"
    "sales_salesterritoryhistory"
    "sales_currency"
    "sales_currencyrate"
    "sales_countryregioncurrency"
    "sales_creditcard"
    "sales_personcreditcard"
    "sales_customer"
    "sales_salesorderheader"
    "sales_specialoffer"
    "sales_specialofferproduct"
    "sales_salesorderdetail"
    "sales_salesreason"
    "sales_salesorderheadersalesreason"
    "sales_salestaxrate"
    "sales_shoppingcartitem"
)

# 3. Vòng lặp tạo file
echo "Bắt đầu tạo ${#TABLES[@]} Silver models..."

for table_name in "${TABLES[@]}"; do
    # Format tên file: silver_<tên_gốc>.sql
    filename="silver_${table_name}.sql"
    filepath="$TARGET_DIR/$filename"

    # Tên của model bronze tương ứng (để ref)
    bronze_model="bronze_${table_name}"

    # Ghi nội dung vào file
    # Lưu ý: Sử dụng {{ ref('...') }} để tạo dependency với Bronze
    cat <<EOF > "$filepath"
{{ config(
    location=generate_lakehouse_path()
) }}

SELECT *
FROM {{ ref('$bronze_model') }}
EOF

    echo "   ✅ Created: $filename"
done

echo "🎉 Hoàn tất! Đã tạo xong file tại $TARGET_DIR"