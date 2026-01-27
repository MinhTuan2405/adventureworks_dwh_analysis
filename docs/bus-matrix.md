# Enterprise Data Warehouse Bus Matrix

## Fact Tables (Bảng Fact)

* **fct_adventureworks_internet_sales**: Bảng fact ghi nhận doanh số bán hàng trực tuyến (internet) ở mức chi tiết dòng đơn hàng (line item grain)
* **fct_adventureworks_reseller_sales**: Bảng fact ghi nhận doanh số bán hàng qua đại lý (reseller) ở mức chi tiết dòng đơn hàng (line item grain)
* **fct_product_inventory**: _(Chưa implement - để bổ sung)_ Bảng fact quản lý tồn kho sản phẩm
* **fct_purchase_order**: _(Chưa implement - để bổ sung)_ Bảng fact đơn đặt hàng mua từ nhà cung cấp

## Dimensional Tables (Bảng Chiều)

* **dim_date**: Bảng chiều ngày tháng với các thuộc tính lịch
* **dim_adventureworks_product**: Bảng chiều thông tin sản phẩm với phân cấp danh mục
* **dim_adventureworks_internet_customer**: Bảng chiều thông tin khách hàng mua hàng trực tuyến
* **dim_adventureworks_reseller_customer**: Bảng chiều thông tin khách hàng đại lý/cửa hàng
* **dim_adventureworks_employee**: Bảng chiều thông tin nhân viên/nhân viên bán hàng
* **dim_adventureworks_sales_territory**: Bảng chiều khu vực bán hàng với các chỉ số
* **dim_adventureworks_currency**: Bảng chiều tỷ giá ngoại tệ
* **dim_adventureworks_geography**: Bảng chiều địa chỉ/vị trí địa lý với phân cấp (quốc gia, tỉnh/thành, thành phố)
* **dim_adventureworks_ship_method**: Bảng chiều phương thức vận chuyển
* **dim_promotion**: _(Chưa implement - để bổ sung)_ Bảng chiều thông tin khuyến mãi/chương trình ưu đãi
* **dim_vendor**: _(Chưa implement - để bổ sung)_ Bảng chiều thông tin nhà cung cấp

---

## Bus Matrix (Schema: PROD.COMMON)

| **Business Processes (Fact Tables)** | **DIM_DATE** | **DIM_PRODUCT** | **DIM_INTERNET_CUSTOMER** | **DIM_RESELLER_CUSTOMER** | **DIM_EMPLOYEE** | **DIM_PROMOTION** | **DIM_CURRENCY** | **DIM_GEOGRAPHY** | **DIM_VENDOR** | **DIM_SALES_TERRITORY** | **DIM_SHIP_METHOD** |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **FCT_INTERNET_SALES** | ✓ | ✓ | ✓ | | ✓ | | ✓ | ✓ | | ✓ | ✓ |
| **FCT_RESELLER_SALES** | ✓ | ✓ | | ✓ | ✓ | | ✓ | ✓ | | ✓ | ✓ |
| **FCT_PRODUCT_INVENTORY** | ✓ | ✓ | | | | | | | | | |
| **FCT_PURCHASE_ORDER** | ✓ | ✓ | | | ✓ | | | | ✓ | | |

---

## Ghi chú (Notes)

### Fact Tables đã implement:
- **FCT_INTERNET_SALES** và **FCT_RESELLER_SALES** đã được triển khai đầy đủ
- Cả hai bảng đều có grain ở mức line item (sales_order_detail_id)
- Mỗi fact table có 3 date dimensions: order_date, due_date, ship_date
- DIM_GEOGRAPHY được sử dụng 2 lần: bill_to_address và ship_to_address

### Conformed Dimensions (Chiều dùng chung):
- **DIM_DATE**: Dùng chung cho tất cả fact tables
- **DIM_PRODUCT**: Dùng chung cho tất cả fact tables
- **DIM_EMPLOYEE**: Dùng chung giữa sales và purchase orders
- **DIM_SALES_TERRITORY**: Dùng chung giữa internet và reseller sales
- **DIM_CURRENCY**: Dùng chung giữa internet và reseller sales
- **DIM_GEOGRAPHY**: Dùng chung giữa internet và reseller sales
- **DIM_SHIP_METHOD**: Dùng chung giữa internet và reseller sales

### Chiều riêng biệt theo kênh:
- **DIM_INTERNET_CUSTOMER**: Chỉ dùng cho internet sales
- **DIM_RESELLER_CUSTOMER**: Chỉ dùng cho reseller sales (bao gồm thông tin store)

### Cần bổ sung:
- [ ] **FCT_PRODUCT_INVENTORY**: Fact table quản lý tồn kho theo thời gian
- [ ] **FCT_PURCHASE_ORDER**: Fact table đơn hàng mua từ vendor
- [ ] **DIM_PROMOTION**: Dimension cho special offers và promotions
- [ ] **DIM_VENDOR**: Dimension cho nhà cung cấp

---

## Mô hình dữ liệu hiện tại

```
FCT_INTERNET_SALES
├── DIM_DATE (order_date, due_date, ship_date)
├── DIM_PRODUCT
├── DIM_INTERNET_CUSTOMER
├── DIM_EMPLOYEE (salesperson)
├── DIM_SALES_TERRITORY
├── DIM_CURRENCY
├── DIM_GEOGRAPHY (bill_to, ship_to)
└── DIM_SHIP_METHOD

FCT_RESELLER_SALES
├── DIM_DATE (order_date, due_date, ship_date)
├── DIM_PRODUCT
├── DIM_RESELLER_CUSTOMER
├── DIM_EMPLOYEE (salesperson)
├── DIM_SALES_TERRITORY
├── DIM_CURRENCY
├── DIM_GEOGRAPHY (bill_to, ship_to)
└── DIM_SHIP_METHOD
```

---

**Ngày cập nhật**: 2026-01-27  
**Trạng thái**: Đã triển khai 2/4 fact tables
