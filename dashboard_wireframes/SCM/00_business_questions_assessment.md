# SCM Dashboard — Business Questions Assessment Report

## DATA MODEL INVENTORY

| Fact Table | Grain | Key Measures |
|---|---|---|
| `fct_sale` | Order line item | order_qty, unit_price, unit_price_discount, line_total, freight, tax |
| `fct_purchase` | PO line item | order_qty, received_qty, rejected_qty, stocked_qty, unit_price, line_total, freight |
| `fct_workorder` | Work order | order_qty, stocked_qty, scrapped_qty, yield_rate_pct, scrap_rate_pct, planned/actual cost, resource_hrs |
| `fct_workorder_routing` | WO operation step | planned/actual cost, resource_hrs, cost_per_resource_hr, schedule_status |
| `fct_inventory` | Product × Location | quantity, safety_stock_level, reorder_point, stock_health_status, stock_level_status |
| `fct_inventory_daily_snapshot` | Product × Date | daily_change, quantity_on_hand |
| `fct_transaction` | Transaction | net_quantity, actual_cost, movement_type (Inflow/Outflow) |

| Dimension | Key Attributes |
|---|---|
| `dim_product` | product_name, standard_cost, list_price, product_category_name, product_subcategory_name, is_finished_good, days_to_manufacture, safety_stock_level, reorder_point |
| `dim_vendor` | vendor_name, credit_rating (1–5), is_preferred_vendor, is_active |
| `dim_sales_territory` | territory_name, country_name, territory_group, sales_ytd, sales_last_year |
| `dim_customer` | customer_type (Internet/Reseller), total_purchase_ytd |
| `dim_workcenter` | location_name, cost_rate, availability, is_finished_goods_storage |
| `dim_scrap_reason` | scrap_reason_name, scrap_category (Paint/Finish, Machining, Welding, Forming, Other) |
| `dim_ship_method` | ship_method_name, ship_base, ship_rate |
| `dim_geography` | city, state_province, country |
| `dim_employee` | employee_name, job_title |
| `dim_currency` | currency_code, rate |
| `dim_date` | full_date, date_key, calendar hierarchy |

---

## SCM FUNNEL MAP

```
Procurement ──► Manufacturing ──► Inventory ──► [Distribution] ──► Sales
    ✅ #3          ✅ #4            ⚠️ #5         ❌ No data         ✅ #6

Cross-cutting lenses:
    ⚠️ #1 Overall SCM    ⚠️ #2 Cost Deep Dive    ✅ #7 Product & Category
```

> **Note**: Dataset không có Distribution/Logistics stage riêng biệt (không có carrier performance, shipping SLA, delivery tracking). Chỉ có `ship_method` + `freight` amount — nên merge logistics metrics vào Sales hoặc Overall SCM.

---

## ASSESSMENT BY DASHBOARD

### 1️⃣ Overall SCM — ⚠️ MOSTLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | How is the overall supply chain performing against current efficiency targets, cost budgets, and historical benchmarks? | ⚠️ Adjust | **"targets" và "budgets" KHÔNG CÓ trong dataset.** Dataset không có bảng budget/target. Chỉ có thể dùng prior period (YoY, MoM) làm benchmark. |
| Q2 | How are the key drivers across the SCM funnel from procurement to fulfillment impacting overall operational efficiency and sales outcomes? | ✅ OK | Funnel traceable qua `product_id`: Purchase → WorkOrder → Inventory → Sale. Đủ data aggregate qua product/date. |
| Q3 | How do supply chain costs vary by key categories such as cost type, geographic region, facility, or product line? | ⚠️ Adjust | **"Geographic region"** chỉ có cho Sales (`dim_sales_territory`). Purchase/Manufacturing không có region — Purchase chỉ có vendor, Manufacturing chỉ có workcenter. |

**Gaps identified:**
- Không có budget/target tables → dùng prior-period comparison
- Region chỉ applicable cho sales side → clarify scope per domain

**Recommended revisions:**

| # | Original | Revised |
|---|---|---|
| Q1 | "...against current efficiency targets, cost budgets, and historical benchmarks?" | **"...compared to prior-period benchmarks across cost, efficiency, and throughput?"** |
| Q3 | "...cost type, geographic region, facility, or product line?" | **"...cost type, territory (sales), vendor (procurement), facility (manufacturing), or product line?"** |

---

### 2️⃣ SCM Cost Deep Dive — ⚠️ PARTIALLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | How are total SCM costs, cost per unit, freight expenses, and warehousing costs changing over time? | ❌ Gap | **Warehousing costs KHÔNG CÓ.** Không có storage cost, holding cost, handling cost. `dim_workcenter.cost_rate` là chi phí sản xuất, không phải warehousing. Có thể thay bằng **"inventory carrying value"** = quantity × standard_cost. |
| Q2 | How do supply chain costs vary across major cost components and operational drivers? | ✅ OK | Components: Material (purchase line_total), Manufacturing (workorder actual_cost), Freight (sale + purchase freight), Tax. Drivers: vendor, product, workcenter, ship_method. |
| Q3 | What trends can be identified in cost allocation across facilities, regions, and product lines? | ⚠️ Adjust | "Regions" chỉ applicable cho sales. "Cost allocation" implies budget allocation (không có) → dùng "cost distribution". |

**Gaps identified:**
- Warehousing/holding/storage costs hoàn toàn không có
- "Allocation" implies intentional budget split — data chỉ có actual spend distribution

**Recommended revisions:**

| # | Original | Revised |
|---|---|---|
| Q1 | "...freight expenses, and warehousing costs changing over time?" | **"...freight expenses, and inventory carrying value changing over time?"** |
| Q3 | "...cost allocation across facilities, regions, and product lines?" | **"...cost distribution across work centers, sales territories, and product lines?"** |

---

### 3️⃣ Purchasing Efficiency & Spend — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | Are we aligning procurement volume with actual demand patterns to avoid waste? | ✅ OK | `fct_purchase.order_qty` vs `fct_sale.order_qty` by product. `fulfillment_rate` = received_qty / order_qty. |
| Q2 | Which suppliers provide the best balance of lead time, cost, and delivery quality? | ✅ OK | `base_product_vendor.average_lead_time`, `fct_purchase.unit_price`, rejection_rate = rejected_qty / received_qty, `dim_vendor.credit_rating`. |
| Q3 | How much spend is allocated to top-performing versus unreliable vendors? | ✅ OK | Vendor scoring + Pareto analysis trên spend by vendor tier. |

**No gaps — all questions fully supported by data model.**

---

### 4️⃣ Manufacturing Operations & Quality — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | Are work orders meeting planned output targets, and how does production yield trend over time? | ✅ OK | `order_qty` vs `stocked_qty`, `yield_rate_pct`, `delivery_status`, trending qua date keys. |
| Q2 | Which scrap categories, work centers, and products are driving the highest scrap rates and material waste? | ✅ OK | `scrapped_qty`, `scrap_rate_pct`, `dim_scrap_reason` (5 categories), `dim_workcenter`, `dim_product`. |
| Q3 | What is the actual manufacturing cost per unit, and where are the largest cost variances versus plan? | ✅ OK | `total_actual_cost / stocked_qty`, `cost_variance`, `cost_variance_pct`, routing-level breakdown by workcenter. |

**No gaps — questions were previously refined to match available data.**

---

### 5️⃣ Inventory Efficiency — ⚠️ MOSTLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | What is the optimal balance between safety stock and inventory carrying costs? | ⚠️ Adjust | **Carrying costs KHÔNG CÓ.** Có `safety_stock_level` ✅, `quantity` vs safety stock ✅, nhưng không có holding cost rate, storage cost. Thay bằng **"capital tied up"** (quantity × standard_cost). |
| Q2 | Which product categories have the lowest turnover and risk becoming dead stock? | ✅ OK | `stock_health_status` (Dead Stock / Slow Moving / Active), `days_since_last_sale`. Turnover tính từ `fct_inventory_daily_snapshot` + `fct_transaction`. |
| Q3 | How ready is our inventory to fulfill incoming orders without stockouts? | ✅ OK | `quantity` vs `reorder_point`, `stock_level_status` (Low/Mid/High), items below safety stock. |

**Gaps identified:**
- Inventory carrying/holding costs không tồn tại trong Dataset
- Không có forward-looking demand forecast, nhưng có thể đánh giá current readiness

**Recommended revision:**

| # | Original | Revised |
|---|---|---|
| Q1 | "...balance between safety stock and inventory carrying costs?" | **"...how does current stock compare to safety-stock thresholds, and how much capital is tied up in excess inventory?"** |

---

### 6️⃣ Sales Performance — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | Which regions and sales channels are driving the highest revenue growth? | ✅ OK | `dim_sales_territory` (territory_group, country), `sales_channel` (Internet/Reseller). |
| Q2 | What is the monthly revenue variance trend, and is the Average Order Value increasing or decreasing over time? | ✅ OK | `line_total` trending, AOV = order_total_due / COUNT(DISTINCT sales_order_id). |
| Q3 | Which high-value customer segments are contributing most to the bottom line? | ✅ OK | `total_purchase_ytd` segmentation, `customer_type`. |

**No gaps — dashboard already built.**

---

### 7️⃣ Product & Category Analysis — ✅ FULLY FEASIBLE

| # | Business Question | Verdict | Analysis |
|---|---|---|---|
| Q1 | Which Star products drive the highest gross margins and should be prioritized? | ✅ OK | GM$ = line_total − (standard_cost × order_qty). |
| Q2 | How do discounts impact the balance between sales volume and margin erosion? | ✅ OK | `unit_price_discount` tiers analysis. |
| Q3 | Which underperforming categories need a price adjustment or portfolio exit? | ✅ OK | Category-level aggregation, BCG/severity matrix. |

**No gaps — dashboard already built.**

---

## SUMMARY MATRIX

| Dashboard | Status | Questions Need Fix | Key Gap |
|---|---|---|---|
| 1️⃣ Overall SCM | ⚠️ Mostly OK | Q1, Q3 | No budget/target tables; region scope limited |
| 2️⃣ SCM Cost Deep Dive | ⚠️ Gap | Q1, Q3 | No warehousing/carrying costs |
| 3️⃣ Purchasing Efficiency | ✅ Perfect | — | — |
| 4️⃣ Manufacturing | ✅ Perfect | — | — |
| 5️⃣ Inventory Efficiency | ⚠️ Minor gap | Q1 | No carrying cost data |
| 6️⃣ Sales Performance | ✅ Perfect | — | — |
| 7️⃣ Product & Category | ✅ Perfect | — | — |

**Result: 4/7 fully feasible, 3/7 need minor wording adjustments (no structural changes to dashboard design needed).**

---

## KNOWN DATASET LIMITATIONS (Dataset-wide)

| Limitation | Impact | Workaround |
|---|---|---|
| No budget/target/forecast tables | Cannot compare actuals vs planned targets | Use prior-period (YoY, MoM, QoQ) as benchmark |
| No warehousing/carrying/holding costs | Cannot calculate true inventory holding cost | Use `quantity × standard_cost` as capital-at-risk proxy |
| No distribution/logistics stage | Cannot track carrier performance, delivery SLA | Merge freight/ship_method analysis into Sales or Overall |
| No labor vs machine cost split | Manufacturing cost is aggregate, not broken by labor/equipment | Analyze at workcenter level as closest proxy |
| No capacity/utilization data | Cannot measure capacity utilization % | Use `availability` from dim_workcenter as limited proxy |
| Region only on sales side | Purchase and Manufacturing lack geographic dimension | Segment by vendor (purchase) and workcenter (manufacturing) instead |
| Single currency (USD assumed) | No multi-currency conversion needed | dim_currency exists but limited use |

---

## REVISED QUESTIONS (Final Recommended Version)

### 1️⃣ Overall SCM
1. How is the overall supply chain performing **compared to prior-period benchmarks** across cost, efficiency, and throughput?
2. How are the key drivers across the SCM funnel from procurement to fulfillment impacting overall operational efficiency and sales outcomes? *(unchanged)*
3. How do supply chain costs vary by **cost type, territory (sales), vendor (procurement), facility (manufacturing), or product line**?

### 2️⃣ SCM Cost Deep Dive
1. How are total SCM costs, cost per unit, freight expenses, and **inventory carrying value** changing over time?
2. How do supply chain costs vary across major cost components and operational drivers? *(unchanged)*
3. What trends can be identified in **cost distribution across work centers, sales territories, and product lines**?

### 3️⃣ Purchasing Efficiency & Spend *(unchanged)*
1. Are we aligning procurement volume with actual demand patterns to avoid waste?
2. Which suppliers provide the best balance of lead time, cost, and delivery quality?
3. How much spend is allocated to top-performing versus unreliable vendors?

### 4️⃣ Manufacturing Operations & Quality *(unchanged)*
1. Are work orders meeting planned output targets, and how does production yield trend over time?
2. Which scrap categories, work centers, and products are driving the highest scrap rates and material waste?
3. What is the actual manufacturing cost per unit, and where are the largest cost variances versus plan?

### 5️⃣ Inventory Efficiency
1. **How does current stock compare to safety-stock thresholds, and how much capital is tied up in excess inventory?**
2. Which product categories have the lowest turnover and risk becoming dead stock? *(unchanged)*
3. How ready is our inventory to fulfill incoming orders without stockouts? *(unchanged)*

### 6️⃣ Sales Performance *(unchanged)*
1. Which regions and sales channels are driving the highest revenue growth?
2. What is the monthly revenue variance trend, and is the Average Order Value increasing or decreasing over time?
3. Which high-value customer segments are contributing most to the bottom line?

### 7️⃣ Product & Category Analysis *(unchanged)*
1. Which Star products drive the highest gross margins and should be prioritized?
2. How do discounts impact the balance between sales volume and margin erosion?
3. Which underperforming categories need a price adjustment or portfolio exit?
