# Finance Dashboard — Business Questions Assessment Report

> **Date**: 2026-03-01  
> **Dataset**: Enterprise DWH (DuckDB + dbt + S3/Parquet)  
> **Purpose**: Thiết kế Finance Dashboard funnel — xác định scope, đánh giá tính khả thi của business questions so với data model hiện tại

---

## 1. WHY WE NEED A FINANCE DASHBOARD

### Bối cảnh

Doanh nghiệp là một công ty sản xuất & bán hàng (bicycle + accessories) với chuỗi giá trị đầy đủ: Procurement → Manufacturing → Inventory → Sales. Mỗi khâu trong chuỗi này tạo ra **dòng tiền vào (Revenue)** và **dòng tiền ra (Cost/Expense)**. Tuy nhiên, hiện tại hệ thống DWH đã có SCM dashboards tập trung vào **operational efficiency** — chúng trả lời câu hỏi *"chúng ta vận hành có tốt không?"* nhưng **không trả lời được câu hỏi cốt lõi của CFO/Finance team**:

### Câu hỏi mà Finance Dashboard giải quyết

| Câu hỏi chiến lược | SCM Dashboard có trả lời? | Finance Dashboard trả lời? |
|---|---|---|
| Tổng doanh thu, lợi nhuận gộp, lợi nhuận ròng là bao nhiêu? | ❌ Không | ✅ Có |
| Margin đang tăng hay giảm? Nguyên nhân từ đâu? | ❌ Không | ✅ Có |
| Chi phí nào chiếm tỷ trọng lớn nhất và đang tăng nhanh nhất? | ⚠️ Một phần (cost deep dive) | ✅ Toàn diện hơn |
| Revenue mix giữa Internet vs Reseller thay đổi thế nào? | ⚠️ Chỉ sales volume | ✅ Revenue & Profit view |
| Sản phẩm/Category nào tạo ra nhiều lợi nhuận nhất? | ⚠️ Margin cơ bản | ✅ Full P&L by product |
| Territory nào generate nhiều profit nhất? | ❌ Không | ✅ Có |
| Xu hướng P&L theo thời gian? | ❌ Không | ✅ Có |
| ROI của procurement spend? | ❌ Không | ✅ Có |

### Giá trị mang lại

1. **Financial Visibility**: Cung cấp cái nhìn toàn diện về sức khỏe tài chính (Revenue → COGS → Gross Profit → Operating Expenses → Net Income)
2. **Decision Support**: Hỗ trợ quyết định pricing, product portfolio, territory expansion/contraction
3. **Cost Control**: Phát hiện sớm các xu hướng chi phí bất thường (cost creep, margin erosion)
4. **Performance Benchmarking**: So sánh hiệu quả tài chính qua thời gian (MoM, QoQ, YoY) — thay thế cho budget/target vì dataset hiện tại không có budget tables
5. **Stakeholder Communication**: Tạo ngôn ngữ chung giữa Finance, Sales, Operations cho các cuộc họp business review

---

## 2. DATA MODEL INVENTORY (Finance-Relevant)

### Fact Tables

| Fact Table | Grain | Key Financial Measures |
|---|---|---|
| `fct_sale` | Sales order line item | `order_qty`, `unit_price`, `unit_price_discount`, `line_total`, `order_sub_total`, `order_tax_amount`, `order_freight_amount`, `order_total_due`, `sales_channel` |
| `fct_purchase` | Purchase order line item | `order_qty`, `unit_price`, `line_total`, `received_qty`, `rejected_qty`, `stocked_qty`, `rejected_amount`, `order_sub_total`, `order_tax_amount`, `order_freight_amount`, `order_total_due` |
| `fct_workorder` | Work order | `order_qty`, `stocked_qty`, `scrapped_qty`, `total_planned_cost`, `total_actual_cost`, `cost_variance`, `cost_variance_pct` |
| `fct_workorder_routing` | WO operation step | `planned_cost`, `actual_cost`, `cost_variance`, `actual_resource_hrs`, `cost_per_resource_hr` |
| `fct_inventory` | Product × Location | `quantity`, `standard_cost`, `list_price`, `total_manufacture_value`, `total_actual_value` |
| `fct_inventory_daily_snapshot` | Product × Date | `daily_change`, `quantity_on_hand` |
| `fct_transaction` | Transaction | `net_quantity`, `actual_cost`, `total_amount`, `transaction_type` (P/W/S), `movement_type` |

### Dimensions

| Dimension | Key Financial Attributes |
|---|---|
| `dim_product` | `standard_cost`, `list_price`, `product_category_name`, `product_subcategory_name`, `product_line_code`, `class_code` |
| `dim_customer` | `customer_type` (Internet/Reseller), `total_purchase_ytd`, `store_annual_sales`, `store_annual_revenue` |
| `dim_sales_territory` | `territory_name`, `country_name`, `territory_group`, `sales_ytd`, `sales_last_year`, `cost_ytd`, `cost_last_year`, `sales_growth`, `cost_growth` |
| `dim_vendor` | `vendor_name`, `credit_rating`, `is_preferred_vendor` |
| `dim_currency` | `from_currency_code`, `to_currency_code`, `average_rate`, `end_of_day_rate` |
| `dim_ship_method` | `ship_method_name`, `ship_base`, `ship_rate` |
| `dim_employee` | `employee_name`, `job_title` (for salesperson analysis) |
| `dim_date` | `date_key`, `full_date`, calendar hierarchy (Year/Quarter/Month/Week) |

### Derivable Financial Metrics

| Metric | Formula | Source |
|---|---|---|
| **Gross Revenue** | `SUM(fct_sale.line_total)` | fct_sale |
| **Net Revenue** | `SUM(fct_sale.order_sub_total)` — trước tax & freight nhưng sau discount | fct_sale |
| **Total Revenue (TotalDue)** | `SUM(fct_sale.order_total_due)` — bao gồm tax + freight | fct_sale |
| **COGS (Cost of Goods Sold)** | `SUM(dim_product.standard_cost × fct_sale.order_qty)` | fct_sale + dim_product |
| **Gross Profit** | Net Revenue − COGS | Derived |
| **Gross Margin %** | Gross Profit / Net Revenue × 100 | Derived |
| **Discount Amount** | `SUM(unit_price × unit_price_discount × order_qty)` | fct_sale |
| **Tax Amount** | `SUM(fct_sale.order_tax_amount)` | fct_sale (order-level, cần dedup) |
| **Freight / Shipping Cost** | `SUM(fct_sale.order_freight_amount)` | fct_sale (order-level, cần dedup) |
| **Procurement Spend** | `SUM(fct_purchase.line_total)` | fct_purchase |
| **Manufacturing Cost** | `SUM(fct_workorder.total_actual_cost)` | fct_workorder |
| **Manufacturing Cost Variance** | `SUM(fct_workorder.cost_variance)` | fct_workorder |
| **Inventory Carrying Value** | `SUM(fct_inventory.total_manufacture_value)` | fct_inventory |
| **Average Order Value (AOV)** | `SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` | fct_sale |
| **Revenue per Unit** | `SUM(line_total) / SUM(order_qty)` | fct_sale |
| **Scrap Loss** | `SUM(scrapped_qty × standard_cost)` | fct_workorder + dim_product |

---

## 3. FINANCE FUNNEL MAP

```
                              ╔══════════════════════════════╗
                              ║    FINANCE DASHBOARD FUNNEL  ║
                              ╚══════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────┐
│  LEVEL 1: EXECUTIVE OVERVIEW (Tổng quan tài chính)                             │
│  ┌──────────────────────────┐                                                  │
│  │  #1 Financial Overview   │  ← P&L Summary, KPI Cards, Trend                │
│  └──────────────────────────┘                                                  │
└──────────────────────────────────────────────────┬──────────────────────────────┘
                                                   │
                    ┌──────────────────────────────┼──────────────────────────────┐
                    ▼                              ▼                              ▼
┌──────────────────────────────┐ ┌──────────────────────────────┐ ┌──────────────────────────────┐
│ LEVEL 2A: REVENUE ANALYSIS  │ │ LEVEL 2B: COST ANALYSIS      │ │ LEVEL 2C: PROFITABILITY      │
│ ┌──────────────────────────┐│ │ ┌──────────────────────────┐ │ │ ┌──────────────────────────┐ │
│ │ #2 Revenue Deep Dive     ││ │ │ #3 Cost Structure        │ │ │ │ #4 Profitability Analysis││ │
│ │    & Growth              ││ │ │    & Control             │ │ │ │    & Margin              ││ │
│ └──────────────────────────┘│ │ └──────────────────────────┘ │ │ └──────────────────────────┘ │
└──────────────────────────────┘ └──────────────────────────────┘ └──────────────────────────────┘
                    │                              │                              │
                    ▼                              ▼                              ▼
┌──────────────────────────────┐ ┌──────────────────────────────┐ ┌──────────────────────────────┐
│ LEVEL 3A: DIMENSIONAL CUTS  │ │ LEVEL 3B: DIMENSIONAL CUTS   │ │ LEVEL 3C: DIMENSIONAL CUTS   │
│ ┌──────────────────────────┐│ │ ┌──────────────────────────┐ │ │ ┌──────────────────────────┐ │
│ │ #5 Territory & Channel   ││ │ │ #6 Procurement           │ │ │ │ #7 Product Portfolio     ││ │
│ │    Financial Performance ││ │ │    Financial Analysis    │ │ │ │    Financial Analysis    ││ │
│ └──────────────────────────┘│ │ └──────────────────────────┘ │ │ └──────────────────────────┘ │
└──────────────────────────────┘ └──────────────────────────────┘ └──────────────────────────────┘
```

### Giải thích cấu trúc funnel

| Level | Mục đích | Audience chính |
|---|---|---|
| **Level 1** — Executive Overview | Nhìn nhanh sức khỏe tài chính tổng thể trong < 30 giây | CEO, CFO, Board |
| **Level 2** — Deep Dive (3 trụ cột) | Phân tích chi tiết 3 trụ cột: Revenue, Cost, Profitability | CFO, Finance Manager |
| **Level 3** — Dimensional Cuts | Drill-down theo các góc nhìn: Territory, Vendor/Procurement, Product | Finance Analyst, Department Heads |

---

## 4. DASHBOARD DESCRIPTIONS

### 1️⃣ Financial Overview Dashboard
> **Mô tả**: Dashboard tổng quan tài chính — cung cấp bức tranh P&L (Profit & Loss) nhanh nhất cho leadership. Hiển thị các KPI tài chính cốt lõi (Revenue, COGS, Gross Profit, Freight, Tax, Net Income proxy), xu hướng theo thời gian, và so sánh with prior period.  
> **Audience**: CEO, CFO, Board  
> **Tần suất xem**: Daily/Weekly  
> **Lenses**: Time (YTD, QoQ, MoM), Sales Channel (Internet vs Reseller)

### 2️⃣ Revenue Deep Dive & Growth Dashboard
> **Mô tả**: Phân tích chi tiết nguồn doanh thu — xu hướng tăng trưởng, revenue mix, discount impact, seasonal patterns. Trả lời câu hỏi "doanh thu đến từ đâu, đang tăng hay giảm, và tại sao?"  
> **Audience**: CFO, Sales Director, Revenue Team  
> **Tần suất xem**: Weekly/Monthly  
> **Lenses**: Channel, Territory, Time, Customer Type

### 3️⃣ Cost Structure & Control Dashboard
> **Mô tả**: Phân tích chi tiết cấu trúc chi phí toàn enterprise — từ COGS, manufacturing cost, procurement spend, freight, đến tax. Phát hiện cost creep và xu hướng chi phí bất thường.  
> **Audience**: CFO, Finance Manager, Operations VP  
> **Tần suất xem**: Monthly/Quarterly  
> **Lenses**: Cost Type, Time, Product Category

### 4️⃣ Profitability Analysis & Margin Dashboard
> **Mô tả**: Phân tích lợi nhuận gộp (Gross Profit) và margin theo nhiều chiều. Xác định sản phẩm, kênh bán, thời kỳ nào có margin tốt/xấu nhất. Phát hiện margin erosion.  
> **Audience**: CFO, Product Manager, Pricing Team  
> **Tần suất xem**: Monthly/Quarterly  
> **Lenses**: Product Category, Channel, Territory, Time

### 5️⃣ Territory & Channel Financial Performance Dashboard
> **Mô tả**: So sánh hiệu quả tài chính giữa các territory và sales channel. Revenue, cost, profit contribution theo vùng địa lý và Internet vs Reseller.  
> **Audience**: CFO, Sales VP, Regional Managers  
> **Tần suất xem**: Monthly/Quarterly  
> **Lenses**: Territory Group, Country, Channel

### 6️⃣ Procurement Financial Analysis Dashboard
> **Mô tả**: Phân tích chi tiêu mua hàng dưới góc nhìn tài chính — total spend, spend concentration, vendor cost efficiency, tax & freight procurement. Đánh giá ROI của procurement decisions.  
> **Audience**: CFO, Procurement Director, Finance Analyst  
> **Tần suất xem**: Monthly/Quarterly  
> **Lenses**: Vendor, Product Category, Time

### 7️⃣ Product Portfolio Financial Analysis Dashboard
> **Mô tả**: Phân tích hiệu quả tài chính theo product portfolio — revenue contribution, COGS, gross margin, discount impact per product/category. Hỗ trợ quyết định product mix và pricing strategy.  
> **Audience**: CFO, Product Manager, Category Manager  
> **Tần suất xem**: Monthly/Quarterly  
> **Lenses**: Product Category, Product Subcategory, Product Line, Class

---

## 5. ASSESSMENT BY DASHBOARD — BUSINESS QUESTIONS

### 1️⃣ Financial Overview — ⚠️ MOSTLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the overall P&L performance (Revenue, COGS, Gross Profit, Operating Costs) and how does it compare to prior-period benchmarks? | ⚠️ Adjust | **Revenue, COGS, Gross Profit** tính được. **Operating Costs** không đầy đủ — không có SGA (Selling, General & Administrative), salary/payroll. Dataset chỉ có: manufacturing cost, freight, tax, discount, scrap loss. **"Budget/Target"** không có → dùng prior-period. |
| Q2 | What are the key financial KPIs (Gross Margin %, AOV, Revenue per Unit, Cost Ratio) trending over time, and are there any concerning inflection points? | ✅ OK | Tất cả KPIs đều derivable: Gross Margin % = (Revenue − COGS)/Revenue. AOV = total_due / distinct orders. Revenue per unit = line_total / qty. Cost ratio = COGS / Revenue. |
| Q3 | How does the financial performance split between Internet and Reseller channels at a high level? | ✅ OK | `sales_channel` field trong `fct_sale`. Revenue, COGS, Margin tính được cho cả hai channels. |

**Gaps identified:**
- Không có đầy đủ Operating Expenses (SGA, payroll, rent, marketing...)
- Không có budget/target → dùng prior-period comparison
- "Net Income" chỉ là proxy (Gross Profit − Freight − Tax − Scrap Loss), không phải true net income

**Recommended revisions:**

| # | Original | Revised |
|---|---|---|
| Q1 | "...Revenue, COGS, Gross Profit, Operating Costs..." | **"...Revenue, COGS, Gross Profit, and key operational costs (manufacturing, freight, tax) compared to prior-period benchmarks?"** |

---

### 2️⃣ Revenue Deep Dive & Growth — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the revenue trend over time (MoM, QoQ, YoY), and which periods show the strongest/weakest growth? | ✅ OK | `fct_sale.line_total` + `dim_date` calendar hierarchy. Growth rate = (current − prior) / prior × 100. |
| Q2 | How is the revenue mix shifting between Internet and Reseller channels, and what is the discount impact on each channel's net revenue? | ✅ OK | `sales_channel` split. Discount amount = `unit_price × unit_price_discount × order_qty`. Net revenue after discount = `line_total`. |
| Q3 | What are the revenue seasonality patterns, and which months/quarters consistently over- or under-perform? | ✅ OK | Multi-year data (2011–2014) cho phép phát hiện seasonal patterns qua `dim_date` month/quarter. |

**No gaps — all questions fully supported by data model.**

---

### 3️⃣ Cost Structure & Control — ⚠️ MOSTLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the total cost breakdown by major cost components (COGS, manufacturing, freight, tax, scrap loss), and how is each component trending over time? | ✅ OK | COGS = standard_cost × qty (fct_sale + dim_product). Manufacturing = total_actual_cost (fct_workorder). Freight = order_freight_amount (fct_sale + fct_purchase). Tax = order_tax_amount. Scrap = scrapped_qty × standard_cost. |
| Q2 | Where are the largest cost variances occurring — which products, work centers, or vendors are driving costs above expected levels? | ✅ OK | `fct_workorder.cost_variance` và `cost_variance_pct` by dim_product. `fct_workorder_routing.cost_variance` by dim_workcenter. Purchase unit_price trends by dim_vendor. |
| Q3 | What is the cost-to-revenue ratio trend, and are operational costs growing faster than revenue (cost creep)? | ⚠️ Adjust | Cost-to-revenue ratio tính được (total costs / revenue). Nhưng "operational costs" chỉ bao gồm manufacturing + freight + scrap, không có full OpEx. |

**Gaps identified:**
- Không có full operational expenses (SGA, salaries, marketing) — chỉ có production-related costs
- dataset không có line-item tax detail (tax rate by product/territory) — chỉ có aggregate tax amount per order

**Recommended revision:**

| # | Original | Revised |
|---|---|---|
| Q3 | "...are operational costs growing faster than revenue?" | **"...are production-related costs (COGS, manufacturing, freight) growing faster than revenue?"** |

---

### 4️⃣ Profitability Analysis & Margin — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the gross margin trend across time periods, and which quarters show margin compression or expansion? | ✅ OK | GM% = (line_total − standard_cost × order_qty) / line_total. Trending qua date hierarchy. |
| Q2 | Which product categories and subcategories are margin leaders vs. margin laggards, and how has this ranking changed over time? | ✅ OK | GM by `product_category_name` + `product_subcategory_name`. Period-over-period ranking shift. |
| Q3 | How do discounts and pricing strategies affect margin by channel, and is there evidence of margin erosion from excessive discounting? | ✅ OK | `unit_price_discount` analysis by `sales_channel`. Correlation: discount % vs margin %. Discount penetration rate = % orders with discount. |

**No gaps — all questions fully supported by data model.**

---

### 5️⃣ Territory & Channel Financial Performance — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | Which territories and territory groups generate the highest revenue, profit, and margin — and how do they rank against each other? | ✅ OK | `dim_sales_territory` (territory_name, territory_group, country_name) joined with fct_sale. Revenue, COGS, GM tính cho mỗi territory. |
| Q2 | How does the Internet vs Reseller channel mix differ across territories, and which channel is more profitable in each region? | ✅ OK | `sales_channel` × `dim_sales_territory` cross-analysis. Margin by channel per territory. |
| Q3 | Which territories show the strongest revenue growth momentum, and which are declining — signaling expansion or consolidation opportunities? | ✅ OK | `sales_ytd` vs `sales_last_year` from dim_sales_territory. Revenue growth trend by territory qua dim_date. |

**No gaps — all questions fully supported by data model.**

---

### 6️⃣ Procurement Financial Analysis — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the total procurement spend trend, and how does it correlate with revenue growth — are we spending proportionally to growth? | ✅ OK | Purchase spend = `SUM(fct_purchase.line_total)`. Revenue = `SUM(fct_sale.line_total)`. Spend-to-revenue ratio over time. |
| Q2 | How concentrated is our procurement spend across vendors, and are we getting better pricing from high-volume vendors? | ✅ OK | Vendor Pareto (top N vendors by spend %). Average unit price trend by vendor. Volume vs price correlation. `dim_vendor.credit_rating` as quality proxy. |
| Q3 | What is the financial impact of rejected materials — how much spend is wasted on defective receipts, and which vendors are responsible? | ✅ OK | `rejected_amount` = rejected_qty × unit_price. Rejection rate by vendor. Cost of quality = total rejected_amount. |

**No gaps — all questions fully supported by data model.**

---

### 7️⃣ Product Portfolio Financial Analysis — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the revenue and profit contribution of each product category — which categories are "cash cows" vs "question marks"? | ✅ OK | Revenue, COGS, GM, GM% by `product_category_name`. BCG matrix proxy: Revenue Share vs Growth Rate. |
| Q2 | How does product pricing (list price vs actual selling price) vary across categories, and where is the largest price gap? | ✅ OK | `dim_product.list_price` vs `fct_sale.unit_price`. Price realization % = actual / list. Gap by category. |
| Q3 | Which individual products have the highest margin and revenue, and which high-revenue products have dangerously low margins that need pricing correction? | ✅ OK | Product-level scatter: Revenue (x) vs Margin% (y). Flag: high-revenue + low-margin quadrant. |

**No gaps — all questions fully supported by data model.**

---

## 6. SUMMARY MATRIX

| Dashboard | Status | Questions Need Fix | Key Gap |
|---|---|---|---|
| 1️⃣ Financial Overview | ⚠️ Mostly OK | Q1 | No full OpEx (SGA, payroll); no budget/target |
| 2️⃣ Revenue Deep Dive & Growth | ✅ Perfect | — | — |
| 3️⃣ Cost Structure & Control | ⚠️ Minor gap | Q3 | Only production-related costs, no full OpEx |
| 4️⃣ Profitability & Margin | ✅ Perfect | — | — |
| 5️⃣ Territory & Channel Finance | ✅ Perfect | — | — |
| 6️⃣ Procurement Finance | ✅ Perfect | — | — |
| 7️⃣ Product Portfolio Finance | ✅ Perfect | — | — |

**Result: 5/7 fully feasible, 2/7 need minor wording adjustments (no structural changes needed).**

---

## 7. KNOWN DATASET LIMITATIONS (Finance-Specific)

| Limitation | Impact | Workaround |
|---|---|---|
| **No budget / target / forecast tables** | Cannot compare actuals vs planned financial targets | Use prior-period comparison (YoY, QoQ, MoM) as benchmark |
| **No SGA / full OpEx** | Cannot calculate true Operating Income or Net Income | Use "Gross Profit" as primary profitability metric; add freight + tax + scrap as "Operational Charges" for proxy |
| **No AR/AP (Accounts Receivable/Payable)** | Cannot track cash flow, DSO, DPO | Focus on accrual-based P&L metrics (revenue at order, cost at standard cost) |
| **No payroll / salary data in financial context** | Cannot allocate labor cost to products or departments | Use `fct_workorder.total_actual_cost` which implicitly includes labor via workcenter cost_rate |
| **COGS = standard cost (not actual)** | COGS sử dụng `standard_cost` thay vì actual cost per unit sold | Standard cost is the industry norm for COGS in manufacturing; variance captured in manufacturing dashboards |
| **Tax is aggregate per order** | Cannot do tax rate analysis by product or jurisdiction | Report tax as total amount; no rate decomposition |
| **Single currency assumption** | `dim_currency` exists nhưng hầu hết transactions là USD | Include currency rate for international sales where applicable |
| **No depreciation / amortization** | Cannot calculate EBITDA properly | Omit from scope; focus on Gross Profit level |
| **Order-level amounts (subtotal, tax, freight) shared across line items** | Need deduplication when aggregating from line-item grain | Use `DISTINCT sales_order_id` for order-level metrics, or allocate proportionally to line items |

---

## 8. REVISED BUSINESS QUESTIONS (Final Recommended Version)

### 1️⃣ Financial Overview
1. What is the overall financial performance (**Revenue, COGS, Gross Profit, and key operational charges including manufacturing cost, freight, and tax**) compared to prior-period benchmarks?
2. What are the key financial KPIs (Gross Margin %, AOV, Revenue per Unit, Cost-to-Revenue Ratio) trending over time, and are there any concerning inflection points?
3. How does the financial performance split between Internet and Reseller channels at a high level?

### 2️⃣ Revenue Deep Dive & Growth
1. What is the revenue trend over time (MoM, QoQ, YoY), and which periods show the strongest/weakest growth?
2. How is the revenue mix shifting between Internet and Reseller channels, and what is the discount impact on each channel's net revenue?
3. What are the revenue seasonality patterns, and which months/quarters consistently over- or under-perform?

### 3️⃣ Cost Structure & Control
1. What is the total cost breakdown by major cost components (COGS, manufacturing, freight, tax, scrap loss), and how is each component trending over time?
2. Where are the largest cost variances occurring — which products, work centers, or vendors are driving costs above expected levels?
3. What is the cost-to-revenue ratio trend, and are **production-related costs (COGS, manufacturing, freight)** growing faster than revenue?

### 4️⃣ Profitability Analysis & Margin
1. What is the gross margin trend across time periods, and which quarters show margin compression or expansion?
2. Which product categories and subcategories are margin leaders vs. margin laggards, and how has this ranking changed over time?
3. How do discounts and pricing strategies affect margin by channel, and is there evidence of margin erosion from excessive discounting?

### 5️⃣ Territory & Channel Financial Performance
1. Which territories and territory groups generate the highest revenue, profit, and margin — and how do they rank against each other?
2. How does the Internet vs Reseller channel mix differ across territories, and which channel is more profitable in each region?
3. Which territories show the strongest revenue growth momentum, and which are declining — signaling expansion or consolidation opportunities?

### 6️⃣ Procurement Financial Analysis
1. What is the total procurement spend trend, and how does it correlate with revenue growth — are we spending proportionally to growth?
2. How concentrated is our procurement spend across vendors, and are we getting better pricing from high-volume vendors?
3. What is the financial impact of rejected materials — how much spend is wasted on defective receipts, and which vendors are responsible?

### 7️⃣ Product Portfolio Financial Analysis
1. What is the revenue and profit contribution of each product category — which categories are "cash cows" vs "question marks"?
2. How does product pricing (list price vs actual selling price) vary across categories, and where is the largest price gap?
3. Which individual products have the highest margin and revenue, and which high-revenue products have dangerously low margins that need pricing correction?

---

## 9. CROSS-REFERENCE: FINANCE vs SCM DASHBOARDS

| Finance Dashboard | Related SCM Dashboard | Khác biệt |
|---|---|---|
| #1 Financial Overview | #1 Overall SCM | Finance: P&L focus (Revenue → Profit). SCM: Operational efficiency focus (throughput, lead time, yield) |
| #2 Revenue Deep Dive | #6 Sales Performance | Finance: Revenue growth, mix, discount $. SCM: Volume, fulfillment, channel count |
| #3 Cost Structure | #2 SCM Cost Deep Dive | Finance: Cost as % of revenue, cost ratio trends. SCM: Cost by operational category, cost per unit |
| #4 Profitability | #7 Product & Category | Finance: Margin %, profit contribution matrix. SCM: BCG matrix, volume-based analysis |
| #5 Territory & Channel | (không có tương đương trực tiếp) | Finance-only: Territory-level P&L, channel profitability |
| #6 Procurement Finance | #3 Purchasing Efficiency | Finance: Spend %, vendor cost analysis, rejection cost. SCM: Lead time, fulfillment rate, delivery quality |
| #7 Product Portfolio Finance | #7 Product & Category | Finance: Pricing gap, margin correction. SCM: Discount vs volume trade-off |

> **Key Insight**: Finance dashboards nhìn cùng data nhưng qua lăng kính **monetary value & profitability**, trong khi SCM dashboards nhìn qua lăng kính **operational efficiency & throughput**. Hai funnel bổ sung chứ không thay thế nhau.
