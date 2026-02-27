# Purchasing Efficiency & Spend Dashboard

**Overall Objective:** Analyze procurement costs, supplier performance (lead times, quality), and PO cycle metrics — to align procurement with demand, identify best-value vendors, and optimize spend allocation.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              Purchasing Efficiency & Spend Dashboard                                  │
│                                                                                                      │
│  Detailed vendor drill-downs                                                                         │
│  incorporated in separate Vendor Scorecard view                                                      │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ Total PO Spend   │ PO Spend & Volume Trend by Month    │                                  │
│          │ YTD and Freight  │   Breakout by Order Status           │  • High-level summary of total   │
│ Procure- │                  │                                      │    procurement spend vs demand    │
│ ment     ├──────────────────┼──────────────────────────────────────┤  • Use to quickly assess if      │
│ Spend    │ Spend by Product │ Procurement vs Demand Alignment      │    procurement volume aligns     │
│          │ Category         │   Order Qty vs Received Qty vs       │    with actual consumption       │
│          │                  │   Stocked Qty                        │  • Enable visibility into PO     │
│          ├──────────────────┼────────────────────┬─────────────────┤    cycle and waste drivers       │
│          │ PO Cycle         │ Fulfillment Rate   │ Rejection Rate  │                                  │
│          │ Metrics          │ Trend              │ Trend           │                                  │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Avg Lead Time    │                                      │  • Summarizes supplier            │
│ Supplier │ by Vendor        │ Vendor Performance Matrix:           │    performance across cost,       │
│ Perf.    │                  │   Lead Time vs Quality vs Cost       │    lead time and delivery         │
│          ├──────────────────┼──────────────────────────────────────┤    quality dimensions             │
│          │ Top / Bottom     │ Vendor Lead Time & Rejection         │  • Leverage to negotiate,         │
│          │ Vendors by       │ Rate Trend                           │    consolidate, or switch         │
│          │ Quality Score    │                                      │    suppliers                      │
│          │ ( Intermediate ) │                                      │                                  │
├──────────┼──────────────────┼────────────────────┬─────────────────┤                                  │
│          │ Spend by Vendor  │ Spend Concentration│ Spend: Top      │  • Detail on spend allocation    │
│ Spend    │ Tier             │ (Pareto Analysis)  │ Performers vs   │    across vendor tiers            │
│ Alloc.   │                  │                    │ Unreliable      │  • Use to identify over-          │
│          │                  │                    │                 │    reliance on single vendors     │
│          │                  │                    │                 │    and reduce risk                │
└──────────┴──────────────────┴────────────────────┴─────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_purchase + dim_vendor + base_product_vendor)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY          │
                    │ Vendor                       │
                    │ Product Category             │
                    │ PO Status                    │
                    │ Credit Rating                │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total PO Spend & Volume

| Cell | Spec |
|------|------|
| **Total PO Spend YTD and Freight** | Headline Number + Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase |
| | `Total_Spend = SUM(order_total_due)` |
| | `Line_Spend = SUM(line_total)` |
| | `Freight = SUM(order_freight_amount)` |
| | `Tax = SUM(order_tax_amount)` |
| | `Avg_PO_Value = SUM(order_total_due) / COUNT(DISTINCT purchase_order_id)` |

| Cell | Spec |
|------|------|
| **PO Spend & Volume Trend by Month** | Spend (Stackbar) & PO Count (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_purchase + dim_date |
| | `Monthly_Spend = SUM(line_total) GROUP BY month` |
| | `PO_Count = COUNT(DISTINCT purchase_order_id) GROUP BY month` |
| | 🟧 Toggle – PO Status (Pending / Approved / Complete) |
| | 🟥 Filter – Vendor |
| | 🟥 Filter – Product Category |

---

### ROW 2: Spend by Category & Demand Alignment

| Cell | Spec |
|------|------|
| **Spend by Product Category** | Table; Headline # & Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase + dim_product |
| | Columns: Category, Spend, Prior Year, YoY, % of Total |
| | 🟧 Toggle – Category vs Subcategory |
| | 🟥 Filter – Vendor |

| Cell | Spec |
|------|------|
| **Procurement vs Demand Alignment** | Grouped Bar: Order Qty vs Received Qty vs Stocked Qty |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_purchase |
| | `Ordered = SUM(order_qty)` |
| | `Received = SUM(received_qty)` |
| | `Stocked = SUM(stocked_qty)` |
| | `Waste = Ordered - Stocked` |
| | `Alignment_% = Stocked / Ordered * 100` |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Vendor |
| | 🟥 Filter – Line Item Status (Fully/Partially/Not Received) |

---

### ROW 3: PO Cycle & Quality Metrics

| Cell | Spec |
|------|------|
| **PO Cycle Metrics** | KPI Cards |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase |
| | `Avg_PO_Cycle_Days = AVG(DATEDIFF(ship_date, order_date))` |
| | `On_Time_Delivery_% = COUNT(ship_date <= due_date) / COUNT(*) * 100` |
| | `PO_Count = COUNT(DISTINCT purchase_order_id)` |
| | `Lines_Per_PO = COUNT(purchase_order_detail_id) / COUNT(DISTINCT purchase_order_id)` |

| Cell | Spec |
|------|------|
| **Fulfillment Rate Trend** | Line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_purchase |
| | `Fulfillment_% = SUM(received_qty) / SUM(order_qty) * 100` |
| | `line_item_status distribution (Fully / Partially / Not Received)` |
| | 🟧 Drop-Down Filter – PO Status |
| | 🟥 Filter – Vendor |

| Cell | Spec |
|------|------|
| **Rejection Rate Trend** | Line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_purchase |
| | `Rejection_% = SUM(rejected_qty) / SUM(received_qty) * 100` |
| | `Rejected_Amount = SUM(rejected_amount)` |
| | 🟥 Filter – Vendor |
| | 🟥 Filter – Product Category |

---

### ROW 4: Supplier Lead Time & Quality

| Cell | Spec |
|------|------|
| **Avg Lead Time by Vendor** | Table; Top/Bottom 10 |
| | Timeframe: Point-in-Time |
| | Measurement Range: Current |
| | Source: base_product_vendor |
| | `AVG(average_lead_time) GROUP BY vendor` |
| | Columns: Vendor, Avg Lead Time, Min Order, Max Order, Last Receipt Cost |
| | 🟧 Toggle – Top 10 / Bottom 10 |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Vendor Performance Matrix** | Scatter/Bubble Chart |
| | X-axis: Avg Lead Time (days) |
| | Y-axis: Quality Score (1 - Rejection Rate) |
| | Bubble Size: Total Spend |
| | Color: Credit Rating |
| | Timeframe: YTD |
| | Source: fct_purchase + dim_vendor + base_product_vendor |
| | `Quality_Score = 1 - (SUM(rejected_qty) / SUM(received_qty))` |
| | `Avg_Lead_Time = AVG(average_lead_time)` per vendor |
| | `Unit_Cost = SUM(line_total) / SUM(stocked_qty)` |
| | Quadrants: |
| |   Best (Short Lead + High Quality) |
| |   Fast-but-Risky (Short Lead + Low Quality) |
| |   Reliable-but-Slow (Long Lead + High Quality) |
| |   Avoid (Long Lead + Low Quality) |
| | 🟧 Toggle – By Vendor / By Product |
| | 🟥 Filter – Credit Rating |

---

### ROW 5: Vendor Quality Ranking & Trend

| Cell | Spec |
|------|------|
| **Top / Bottom Vendors by Quality Score** | Table with Conditional Formatting |
| | Timeframe: YTD |
| | Source: fct_purchase + dim_vendor |
| | Columns: Vendor, Quality Score, Rejection %, Lead Time, Spend, Credit Rating, Preferred |
| | `Quality_Score = (1 - Rejection_%) * 100` |
| | 🟢 Score ≥ 95% / 🟡 Score 85-95% / 🔴 Score < 85% |

| Cell | Spec |
|------|------|
| **Vendor Lead Time & Rejection Rate Trend** | Dual-axis Line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_purchase + base_product_vendor |
| | `Avg_Lead_Time trend (line)` |
| | `Rejection_% trend (line)` |
| | 🟧 Drop-Down Filter – Vendor |
| | 🟥 Filter – Product Category |

---

### ROW 6: Spend Allocation & Vendor Concentration

| Cell | Spec |
|------|------|
| **Spend by Vendor Tier** | Table with Trend |
| | Timeframe: YTD |
| | Source: fct_purchase + dim_vendor |
| | Tier Logic: |
| | `Preferred (is_preferred_vendor = true)` |
| | `Top-Rated (credit_rating IN (1,2))` |
| | `Average (credit_rating IN (3,4))` |
| | `Unreliable (credit_rating = 5 OR high rejection)` |
| | Columns: Tier, Spend, % of Total, Vendor Count, Avg Quality |

| Cell | Spec |
|------|------|
| **Spend Concentration (Pareto)** | Bar + Cumulative Line |
| | Timeframe: YTD |
| | Source: fct_purchase + dim_vendor |
| | `Revenue_by_Vendor = SUM(line_total) GROUP BY vendor ORDER BY DESC` |
| | `Cumulative_% = Running_Sum / Total_Spend * 100` |
| | Insight: Top X vendors → Y% of spend |
| | 🟧 Toggle – By Vendor / By Category |

| Cell | Spec |
|------|------|
| **Spend: Top Performers vs Unreliable** | Side-by-side Bars |
| | Timeframe: YTD |
| | Source: fct_purchase + dim_vendor |
| | `Top_Performer_Spend = SUM(line_total) WHERE Quality_Score >= 95%` |
| | `Unreliable_Spend = SUM(line_total) WHERE Quality_Score < 85%` |
| | `Shift_Opportunity = Unreliable_Spend that could move to Top Performers` |
| | 🟥 Filter – Credit Rating |
| | 🟥 Filter – Product Category |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Vendor                  │
  (e.g., performance by vendor or product)                │  Product Category        │
                                                          │  PO Status               │
  Align Dashboard permissions with existing               │  Credit Rating           │
  reporting (some users can't see cost detail)            └──────────────────────────┘

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total PO Spend            │  │  PO Spend & Volume Trend by Month               │  Filter       │
│  │ YTD and Freight           │  │                                                  │               │
│  │                           │  │   ██ Spend ($)  ── PO Count   ── Prior Year      │  🟧 Toggle -  │
│  │  $12.8M        +5%   -2% │  │                                                  │  PO Status    │
│  │  Total Spend   Over  YoY │  │  $2M ┌──────────────────────────────────┐  500   │               │
│  │               Target      │  │      │ ████  ████  ████  ████  ████    │        │  🟥 Filter -  │
│  │  $0.9M Freight            │  │      │ ████  ████  ████  ████  ████    │  300   │  Vendor       │
│  │  $0.4M Tax                │  │  $0  │────────────────────────────────│  100   │               │
│  │                           │  │      M1   M3   M5   M7   M9   M11     │        │  🟥 Filter -  │
│  │  Avg PO: $4.2K            │  └──────────────────────────────────────────────────┘  Category    │
│  └───────────────────────────┘                                                                     │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Spend by Category         │  │  Procurement vs Demand Alignment                 │  Filter       │
│  │          Spend    % Tot   │  │                                                  │               │
│  │           Prior          │  │   ██ Ordered  ██ Received  ██ Stocked             │  🟧 Toggle -  │
│  │           Year    YoY    │  │                                                  │  Category     │
│  │ Bikes    $5.2M   41%  ▲  │  │  10K ┌──────────────────────────────────┐        │               │
│  │ Comp.    $4.1M   32%  ▲  │  │      │ ███ ██ █  ███ ██ █  ███ ██ █   │        │  🟥 Filter -  │
│  │ Cloth.   $2.3M   18%  ▼  │  │      │ ███ ██ █  ███ ██ █  ███ ██ █   │        │  Vendor       │
│  │ Access.  $1.2M    9%  ▼  │  │   0  │────────────────────────────────│        │               │
│  │                          │  │      M1   M3   M5   M7   M9   M11     │        │  🟥 Filter -  │
│  │         Drop-Down Filter │  │      Alignment: 87% | Waste: 13%      │        │  Line Status  │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ PO Cycle Metrics          │  │  Fulfillment Rate Trend     │  │ Rejection Rate Trend           │ │
│  │                           │  │                              │  │                                │ │
│  │  Avg Cycle: 12 days      │  │   ── Fulfillment %           │  │  ── Rejection %                │ │
│  │  +2d      -1d       +5%  │  │                              │  │                                │ │
│  │  Over     Prior     YoY  │  │  100%──●──●──●               │  │   5%                           │ │
│  │  Target   Month          │  │   90%       ●──●──●──●      │  │       ●──●                     │ │
│  │                           │  │   80%                        │  │   3%──●     ●──●──●           │ │
│  │  On-Time: 85%             │  │   M1  M3  M5  M7  M9  M11  │  │   M1  M3  M5  M7  M9  M11    │ │
│  │  PO Count: 3,050          │  │                              │  │                                │ │
│  │  Lines/PO: 4.2            │  │  🟧 Drop-Down - PO Status   │  │  🟥 Filter - Vendor            │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Avg Lead Time by Vendor   │  │  Vendor Performance Matrix                       │  Filter       │
│  │                           │  │                                                  │               │
│  │  Vendor     Lead  Last$   │  │  Quality Score (1 - Rej%)                        │  🟧 Toggle -  │
│  │  Vendor A   5d   $12.50  │  │  100│ ● Best         ◯ Reliable-slow             │  Vendor/Prod  │
│  │  Vendor B   8d   $14.20  │  │   95│ ●              ○                            │               │
│  │  Vendor C  12d   $11.80  │  │   90├──────────────────────────                   │  🟥 Filter -  │
│  │  Vendor D  15d   $18.30  │  │   85│ ▲ Fast-risky   △ Avoid                     │  Credit       │
│  │  Vendor E  22d   $9.50   │  │   80│ ▲              △                            │  Rating       │
│  │  ...                     │  │     └───────────────────────────>                 │               │
│  │                          │  │      5    10   15   20   25   Lead Time (days)    │               │
│  │  🟧 Toggle - Top/Bottom  │  │     Bubble size = Total Spend                     │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Vendor Quality Ranking                                                                     │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │   │
│  │  │ Vendor        │ Quality │ Rej %  │ Lead Time │  Spend   │ Rating     │ Preferred   │    │   │
│  │  ├─────────────────────────────────────────────────────────────────────────────────────┤    │   │
│  │  │ Vendor A      │ 98% 🟢  │  2%   │   5d      │  $2.1M   │ Superior   │    ✓        │    │   │
│  │  │ Vendor B      │ 95% 🟢  │  5%   │   8d      │  $1.8M   │ Excellent  │    ✓        │    │   │
│  │  │ Vendor C      │ 88% 🟡  │ 12%   │  12d      │  $1.2M   │ Average    │             │    │   │
│  │  │ Vendor D      │ 78% 🔴  │ 22%   │  15d      │  $0.9M   │ Below Avg  │             │    │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │   │
│  │  🟢 Score ≥ 95%   🟡 Score 85-95%   🔴 Score < 85%                                        │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Vendor Lead Time & Rejection Rate Trend                                                    │   │
│  │  ┌────────────────────────────────────────────────────────────────────────────────────┐     │   │
│  │  │   ── Avg Lead Time (days)    ── Rejection %    ── Prior Yr Lead Time              │     │   │
│  │  │  20d ┌──────────────────────────────────────────────────────────────┐  10%         │     │   │
│  │  │      │                                                              │              │     │   │
│  │  │  15d │  ●──●──●                                                    │   5%         │     │   │
│  │  │      │           ●──●──●──●──●──●                                  │              │     │   │
│  │  │  10d │                             ●──●──●──●                      │   3%         │     │   │
│  │  │      │  M1   M3   M5   M7   M9   M11                              │              │     │   │
│  │  │   5d └──────────────────────────────────────────────────────────────┘   0%         │     │   │
│  │  └────────────────────────────────────────────────────────────────────────────────────┘     │   │
│  │  🟧 Drop-Down Filter – Vendor                                                              │   │
│  │  🟥 Filter – Product Category                                                               │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Spend by Vendor Tier      │  │  Spend Concentration        │  │ Spend: Top vs Unreliable       │ │
│  │                           │  │  (Pareto Analysis)          │  │                                │ │
│  │  Tier       Spend  % Tot │  │                              │  │  ┌──────────┐                  │ │
│  │  Preferred  $5.2M   41%  │  │  $3M ┌──────────────────┐   │  │  │Top Perf. │ $7.8M (61%)     │ │
│  │  Top-Rated  $3.8M   30%  │  │      │ ████████████████ │   │  │  └──────────┘                  │ │
│  │  Average    $2.5M   19%  │  │      │ ████  ████  ████ │   │  │  ┌──────────┐                  │ │
│  │  Unreliable $1.3M   10%  │  │  $0  │ ████  ████      │   │  │  │Unreliable│ $1.3M (10%)     │ │
│  │                           │  │      V1   V5   V10  V15│   │  │  └──────────┘                  │ │
│  │  Vendor Cnt: 15|22|30|8  │  │      ──●──●──●──●  100%│   │  │                                │ │
│  │  Avg Quality: 97|92|88|76│  │  Top 5 → 62% of spend   │   │  │  Shift Opportunity: $1.3M     │ │
│  │                           │  │                          │   │  │  from unreliable → top perf.  │ │
│  │                          │  │  🟧 Toggle - Vendor/Cat  │   │  │                                │ │
│  └───────────────────────────┘  └────────────────────────────┘  │  🟥 Filter – Credit Rating     │ │
│                                                                  │  🟥 Filter – Category          │ │
│                                                                  └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_purchase` | Fact – grain: PO line item |
| `dim_vendor` | Vendor name, credit rating, preferred status, active |
| `dim_product` | Product category hierarchy (for spend by category) |
| `dim_date` | Date dimension (order_date_key, ship_date_key, due_date_key) |
| `dim_ship_method` | Shipping method |
| `base_product_vendor` | Lead time, standard price, min/max order qty per vendor-product |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Spend | `line_total`, `order_total_due`, `order_sub_total` |
| Freight/Tax | `order_freight_amount`, `order_tax_amount` |
| Volume | `order_qty`, `received_qty`, `stocked_qty`, `rejected_qty` |
| Quality | `rejected_qty`, `rejected_amount`, `line_item_status` |
| PO Cycle | `order_date`, `ship_date`, `due_date`, `order_status` |
| Vendor | `vendor_name`, `credit_rating`, `credit_rating_desc`, `is_preferred_vendor` |
| Lead Time | `average_lead_time` (base_product_vendor) |
| Cost | `unit_price`, `standard_price`, `last_receipt_cost` |

### **Key Calculations**
```sql
-- Spend
Total_Spend = SUM(order_total_due)
Line_Spend = SUM(line_total)
Avg_PO_Value = SUM(order_total_due) / COUNT(DISTINCT purchase_order_id)

-- Demand Alignment
Fulfillment_% = SUM(received_qty) / SUM(order_qty) * 100
Waste_% = (SUM(order_qty) - SUM(stocked_qty)) / SUM(order_qty) * 100
Alignment_% = SUM(stocked_qty) / SUM(order_qty) * 100

-- Quality
Rejection_% = SUM(rejected_qty) / SUM(received_qty) * 100
Quality_Score = (1 - Rejection_%) * 100
Rejected_Amount = SUM(rejected_amount)

-- PO Cycle
Avg_Cycle_Days = AVG(DATEDIFF(ship_date, order_date))
On_Time_% = COUNT(CASE WHEN ship_date <= due_date THEN 1 END) / COUNT(*) * 100

-- Vendor Tier
Tier = CASE
    WHEN is_preferred_vendor = true THEN 'Preferred'
    WHEN credit_rating IN (1,2) THEN 'Top-Rated'
    WHEN credit_rating IN (3,4) THEN 'Average'
    ELSE 'Unreliable'
END

-- Vendor Matrix Quadrants
Best:             Avg_Lead_Time < 10d AND Quality_Score >= 95%
Fast-but-Risky:   Avg_Lead_Time < 10d AND Quality_Score < 95%
Reliable-but-Slow: Avg_Lead_Time >= 10d AND Quality_Score >= 95%
Avoid:            Avg_Lead_Time >= 10d AND Quality_Score < 95%

-- Spend Concentration (Pareto)
Cumulative_% = SUM(spend) OVER (ORDER BY spend DESC ROWS UNBOUNDED PRECEDING) 
               / SUM(spend) OVER ()
```
