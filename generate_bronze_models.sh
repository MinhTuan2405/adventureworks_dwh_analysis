#!/bin/bash

# ==============================================================================
# SCRIPT TẠO DBT MODELS CHO BRONZE LAYER
# Source: landing (Postgres -> S3 Landing)
# Target: bronze (S3 Landing -> S3 Bronze)
# ==============================================================================

# 1. Cấu hình đường dẫn
# Đảm bảo đường dẫn này trỏ đúng vào folder models của dbt project
TARGET_DIR="dbt_project/models/bronze"

# # Tạo thư mục nếu chưa tồn tại
# if [ ! -d "$TARGET_DIR" ]; then
#     echo "📁 Creating directory: $TARGET_DIR"
#     mkdir -p "$TARGET_DIR"
# fi

# 2. Danh sách các bảng (Trích xuất từ sources.yml của bạn)
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
echo "🚀 Bắt đầu tạo ${#TABLES[@]} models..."

for table_name in "${TABLES[@]}"; do
    # Format tên file: bronze_<tên_gốc>.sql
    filename="bronze_${table_name}.sql"
    filepath="$TARGET_DIR/$filename"

    # Ghi nội dung vào file
    # Lưu ý: 
    # - source('landing', ...) đọc từ nguồn Landing
    # - config(location=...) dùng macro để lưu file output vào folder /bronze/
    cat <<EOF > "$filepath"
{{ config(
    location=generate_lakehouse_path()
) }}

SELECT *
FROM {{ source('landing', '${table_name}') }}
EOF

    echo "   ✅ Created: $filename"
done

echo "🎉 Hoàn tất! Đã tạo xong file tại $TARGET_DIR"