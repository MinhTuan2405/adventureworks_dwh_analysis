# SCM Cost Deep Dive Dashboard

**Overall Objective:** Decompose total supply chain costs by type (material, manufacturing, freight, tax, inventory carrying value), analyze cost-per-unit trends over time, and identify where costs concentrate across work centers, sales territories, vendors, and product lines — to prioritize cost reduction initiatives and monitor cost efficiency.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   SCM Cost Deep Dive Dashboard                                       │
│                                                                                                      │
│  Cross-domain cost aggregation from Procurement, Manufacturing, Inventory, and Sales                 │
│  For domain-specific detail, see dedicated dashboards                                                │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ Total SCM Cost   │ Total SCM Cost Trend by Month        │                                  │
│          │ YTD & Cost Per   │   Stacked by Component (Material,    │  • Total cost overview with      │
│ Cost     │ Unit Headline    │   Mfg, Freight, Tax)                 │    cost-per-unit efficiency      │
│ Over     │                  │                                      │    tracking                      │
│ Time     ├──────────────────┼──────────────────────────────────────┤  • Use to quickly assess if      │
│          │ Freight Expense  │ Cost Per Unit & Inventory Carrying   │    costs are rising, stable,     │
│          │ Breakdown        │ Value Trend Over Time                │    or declining relative to      │
│          │ (Sales + PO)     │                                      │    output volume                 │
│          ├──────────────────┼────────────────────┬─────────────────┤  • Enable visibility into        │
│          │ Inventory        │ YoY Cost Growth    │ MoM Cost        │    freight and inventory         │
│          │ Carrying Value   │ by Component       │ Variance        │    carrying value trajectory     │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Cost Component   │                                      │  • Summarizes how cost splits    │
│ Cost     │ Distribution     │ Cost Component Waterfall:            │    across material, manufacturing│
│ Compo-   │ (Material, Mfg,  │   From Total → Breakdown by Driver  │    freight, tax and their        │
│ nents    │ Freight, Tax)    │   with YoY delta per component      │    operational drivers           │
│ &        ├──────────────────┼──────────────────────────────────────┤  • Leverage to pinpoint which    │
│ Drivers  │ Cost by Operatio-│ Cost Driver Matrix:                  │    component is growing fastest  │
│          │ nal Driver       │   Component × Driver (Vendor, Ship   │    and which driver is           │
│          │ ( Intermediate ) │   Method, Product) Heatmap           │    responsible                   │
│          │                  │                                      │                                  │
├──────────┼──────────────────┼────────────────────┬─────────────────┤                                  │
│          │ Cost by Work     │ Cost by Sales      │ Cost by Product │  • Three-dimensional drill into  │
│ Cost     │ Center           │ Territory          │ Line            │    cost distribution across      │
│ Distri-  │                  │                    │                 │    facility, geography, and      │
│ bution   ├──────────────────┼────────────────────┴─────────────────┤    product portfolio             │
│          │ Cost Trend by    │ Cost Distribution Treemap:           │  • Use to identify cost          │
│          │ Top Dimension    │   Work Center × Territory × Product  │    concentration and target      │
│          │ ( Intermediate ) │   (nested breakdown)                 │    specific reduction programs   │
│          │                  │                                      │                                  │
└──────────┴──────────────────┴────────────────────┴─────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (aggregated from fct_purchase + fct_workorder + fct_workorder_routing + fct_inventory + fct_sale + dimensions)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY            │
                    │ Product Category / Subcategory │
                    │ Cost Component (All / Specific)│
                    │ Territory Group (Sales costs)  │
                    │ Vendor (Procurement costs)     │
                    │ Work Center (Mfg costs)        │
                    │ Ship Method (Freight costs)    │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total SCM Cost YTD & Cost Per Unit Headline

| Cell | Spec |
|------|------|
| **Total SCM Cost YTD & Cost Per Unit** | KPI Cards — 5 headline metrics with delta indicators |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase + fct_workorder + fct_sale + fct_inventory |
| | **Total SCM Cost** = Material + Manufacturing + Freight + Tax |
| | `Material_Cost = SUM(line_total) FROM fct_purchase` |
| | `Manufacturing_Cost = SUM(total_actual_cost) FROM fct_workorder` |
| | `Total_Freight = SUM(order_freight_amount) FROM fct_sale + SUM(order_freight_amount) FROM fct_purchase` |
| | `Total_Tax = SUM(order_tax_amount) FROM fct_sale + SUM(order_tax_amount) FROM fct_purchase` |
| | **Cost Per Unit** = `Total_SCM_Cost / SUM(stocked_qty) FROM fct_workorder` |
| | Each KPI shows: Current Value, YoY %, MoM %, Trend Arrow (▲/▼) |

| Cell | Spec |
|------|------|
| **Total SCM Cost Trend by Month** | Stacked Area Chart |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly Total |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_date |
| | Stacks: Material (blue), Manufacturing (orange), Freight (teal), Tax (grey) |
| | Secondary Y-axis line: Total SCM Cost trendline |
| | Dotted overlay: Prior Year same period |
| | 🟧 Toggle – Stacked vs Unstacked |
| | 🟧 Toggle – Product Category |

---

### ROW 2: Freight Expense & Inventory Carrying Value

| Cell | Spec |
|------|------|
| **Freight Expense Breakdown** | Donut Chart + KPI Cards |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_sale + fct_purchase + dim_ship_method |
| | `Sales_Freight = SUM(order_freight_amount) FROM fct_sale` |
| | `Purchase_Freight = SUM(order_freight_amount) FROM fct_purchase` |
| | `Freight_as_%_Revenue = Total_Freight / SUM(line_total) FROM fct_sale * 100` |
| | Donut slices: Sales Freight vs Purchase Freight |
| | KPI: Total Freight $, Freight % of Revenue, YoY % |
| | 🟧 Toggle – By Ship Method |
| | 🟥 Filter – Territory Group (for sales freight) |

| Cell | Spec |
|------|------|
| **Cost Per Unit & Inventory Carrying Value Trend** | Dual-Axis Line Chart |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly |
| | Source: fct_workorder + fct_inventory_daily_snapshot + dim_product + dim_date |
| | Left Y-axis (Line): `Cost_Per_Unit = SUM(total_actual_cost) / SUM(stocked_qty) FROM fct_workorder` grouped by month |
| | Right Y-axis (Area): `Inventory_Carrying_Value = SUM(quantity_on_hand × standard_cost)` from fct_inventory_daily_snapshot (end-of-month snapshot) |
| | Dotted lines: Prior Year for both metrics |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Work Center |

---

### ROW 3: YoY Cost Growth & MoM Variance

| Cell | Spec |
|------|------|
| **Inventory Carrying Value** | KPI Card + Sparkline |
| | Timeframe: Point-in-Time (latest snapshot) |
| | Source: fct_inventory + dim_product |
| | `Carrying_Value = SUM(quantity × standard_cost) FROM fct_inventory` |
| | `Excess_Value = SUM((quantity - safety_stock_level) × standard_cost) WHERE quantity > safety_stock_level` |
| | Sparkline: 12-month trend from fct_inventory_daily_snapshot |
| | YoY %: vs same period prior year |

| Cell | Spec |
|------|------|
| **YoY Cost Growth by Component** | Grouped Horizontal Bar Chart |
| | Timeframe: YTD vs Prior YTD |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_date |
| | Bars (one per component): Material, Manufacturing, Freight, Tax |
| | Value: `(Current_YTD - Prior_YTD) / Prior_YTD * 100` |
| | Color: 🟢 Cost decreased / 🔴 Cost increased |
| | Labels: Absolute $ change + % change |
| | 🟧 Toggle – Product Category |

| Cell | Spec |
|------|------|
| **MoM Cost Variance** | Waterfall Chart |
| | Timeframe: Current Month vs Prior Month |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_date |
| | Steps: Prior Month Total → +/- Material → +/- Mfg → +/- Freight → +/- Tax → Current Month Total |
| | Color: 🟢 Decrease step / 🔴 Increase step / 🔵 Total |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Cost Component |

---

### ROW 4: Cost Component Distribution

| Cell | Spec |
|------|------|
| **Cost Component Distribution** | Donut / Pie Chart with summary table |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder + fct_sale |
| | Slices: Material Cost, Manufacturing Cost, Freight (Sales + Purchase), Tax (Sales + Purchase) |
| | `Material_%  = Material_Cost / Total_SCM_Cost * 100` |
| | `Mfg_%       = Mfg_Cost / Total_SCM_Cost * 100` |
| | `Freight_%   = Total_Freight / Total_SCM_Cost * 100` |
| | `Tax_%       = Total_Tax / Total_SCM_Cost * 100` |
| | Summary table: Component, $ Amount, % Share, YoY change |
| | 🟧 Toggle – YTD / QTD / MTD |

| Cell | Spec |
|------|------|
| **Cost Component Waterfall (YoY Delta)** | Waterfall Chart |
| | Timeframe: YTD vs Prior YTD |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_date |
| | Steps: Prior Year Total → +/- Material Δ → +/- Mfg Δ → +/- Freight Δ → +/- Tax Δ → Current Year Total |
| | Color: 🟢 Decrease / 🔴 Increase / 🔵 Total |
| | Labels: Each step shows absolute Δ and % of total change |
| | 🟧 Toggle – Product Category |

---

### ROW 5: Cost Driver Matrix

| Cell | Spec |
|------|------|
| **Cost by Operational Driver** | KPI Summary Cards |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder + fct_workorder_routing + fct_sale |
| | `Avg_Cost_Per_Vendor = SUM(line_total) / COUNT(DISTINCT vendor_id) FROM fct_purchase` |
| | `Avg_Cost_Per_WorkCenter = SUM(actual_cost) / COUNT(DISTINCT location_id) FROM fct_workorder_routing` |
| | `Cost_Efficiency = Total_SCM_Cost / SUM(line_total) FROM fct_sale` (cost-to-revenue ratio) |
| | `Mfg_Cost_Variance_% = SUM(cost_variance) / SUM(total_planned_cost) * 100 FROM fct_workorder` |

| Cell | Spec |
|------|------|
| **Cost Driver Matrix (Heatmap)** | Matrix / Heatmap |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder_routing + fct_sale + dim_product + dim_vendor + dim_workcenter + dim_ship_method |
| | Rows: Cost Component (Material, Manufacturing, Freight, Tax) |
| | Columns: Top Drivers per component |
| |   Material → Top 10 Vendors (by spend) |
| |   Manufacturing → Work Centers (by actual_cost) |
| |   Freight → Ship Methods (by freight amount) |
| |   Tax → Sales Territories (by tax amount) |
| | Cell value: Cost $ |
| | Color intensity: % of row total (darker = higher concentration) |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Specific Vendor |
| | 🟥 Filter – Specific Work Center |
| | 🟥 Filter – Specific Ship Method |

---

### ROW 6: Cost by Work Center & Sales Territory

| Cell | Spec |
|------|------|
| **Cost by Work Center** | Horizontal Bar Chart |
| | Timeframe: YTD |
| | Source: fct_workorder_routing + dim_workcenter |
| | Bars: Each work center (location_name) |
| | Value: `SUM(actual_cost)` |
| | Color segments: Planned Cost (light) vs Variance (dark, red if overrun / green if under) |
| | Sorted by actual_cost descending |
| | Labels: actual_cost, cost_variance_pct |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Schedule Status |

| Cell | Spec |
|------|------|
| **Cost by Sales Territory** | Horizontal Bar Chart |
| | Timeframe: YTD |
| | Source: fct_sale + dim_sales_territory |
| | Bars: Each territory (territory_name, grouped by territory_group) |
| | Value: `SUM(order_freight_amount + order_tax_amount)` (sales-side cost) |
| | Secondary bar: `SUM(line_total)` as revenue reference |
| | `Cost_as_%_Revenue = Cost / Revenue * 100` per territory |
| | Sorted by cost descending |
| | 🟧 Toggle – Freight Only / Tax Only / Both |
| | 🟥 Filter – Sales Channel |

---

### ROW 7: Cost by Product Line & Distribution Treemap

| Cell | Spec |
|------|------|
| **Cost by Product Line** | Table with Sparkline + Conditional Formatting |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_product |
| | Columns: |
| |   Product Category |
| |   Material $ = SUM(line_total) from fct_purchase by product |
| |   Mfg $ = SUM(total_actual_cost) from fct_workorder by product |
| |   Freight $ = SUM(order_freight_amount) from fct_sale by product |
| |   Total Cost $ |
| |   Cost Per Unit = Total Cost / SUM(stocked_qty) from fct_workorder |
| |   YoY % (conditional: 🟢 decrease / 🔴 increase) |
| |   12M Sparkline (total cost trend) |
| | Sorted by Total Cost descending |
| | 🟧 Toggle – Category / Subcategory / Product |
| | 🟥 Filter – Work Center |
| | 🟥 Filter – Vendor |

| Cell | Spec |
|------|------|
| **Cost Distribution Treemap** | Treemap (nested hierarchy) |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder_routing + fct_sale + dim_product + dim_vendor + dim_workcenter + dim_sales_territory |
| | Hierarchy Level 1: Cost Component (Material / Mfg / Freight / Tax) |
| | Level 2 (Material): Top Vendors by SUM(line_total) |
| | Level 2 (Mfg): Work Centers by SUM(actual_cost) |
| | Level 2 (Freight): Territory Groups by SUM(freight) |
| | Level 2 (Tax): Territory Groups by SUM(tax) |
| | Size: Cost $ amount |
| | Color: YoY % change (gradient: 🟢 cost decreased ↔ 🔴 cost increased) |
| | 🟧 Toggle – By Component / By Product Category |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Vendor |
| | 🟥 Filter – Work Center |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌────────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY        │
  highlight individual data points & detail               │  Product Category / Subcat  │
  (e.g., by component, territory, vendor, workcenter)     │  Cost Component             │
                                                          │  Territory Group (Sales)    │
  Each cost component drills through to its               │  Vendor (Procurement)       │
  domain-specific dashboard on click                      │  Work Center (Mfg)          │
                                                          │  Ship Method (Freight)      │
                                                          └────────────────────────────┘
  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────────────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Total SCM Cost & Cost Per Unit                            │  │ Total SCM Cost Trend (12M)     │ │
│  │                                                           │  │ Stacked Area by Component      │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │  │                                │ │
│  │  │TOTAL SCM │ │MATERIAL  │ │MFG COST  │ │COST/UNIT │    │  │  $M ▲                          │ │
│  │  │ $28.4M   │ │ $12.8M   │ │ $8.1M    │ │ $42.30   │    │  │  3.0├ ░░░░░░░▓▓▓▓▓▓▓▓▓▓▓     │ │
│  │  │ ▲ +5%    │ │ ▲ +3%    │ │ ▲ +7%    │ │ ▼ -1.2%  │    │  │  2.5├ ░░░░░▓▓▓▓▓▓▓▓▓▓▓▓▓     │ │
│  │  │  YTD YoY │ │  YTD YoY │ │  YTD YoY │ │  YTD YoY │    │  │  2.0├ ░░░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘    │  │  1.5├ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │ │
│  │  ┌──────────┐                                             │  │     └──┬──┬──┬──┬──┬──┬──┬──►  │ │
│  │  │FREIGHT   │    "Click component card to filter          │  │      J  F  M  A  M  J  J  A    │ │
│  │  │ $4.1M    │     all visuals below"                      │  │                                │ │
│  │  │ ▲ +4%    │                                             │  │  ░ Material ▓ Mfg ▒ Freight    │ │
│  │  │  YTD YoY │                                             │  │  ─ Prior Year                  │ │
│  │  └──────────┘                                             │  │ 🟧 Stacked/Unstacked │Category │ │
│  └───────────────────────────────────────────────────────────┘  └────────────────────────────────┘ │
│                                                                                                     │
│  ┌───────────────────────────────────┐  ┌──────────────────────────────────────────────────────┐   │
│  │ Freight Expense Breakdown         │  │ Cost Per Unit & Inventory Carrying Value              │   │
│  │                                   │  │ Dual-Axis Line Chart (Trailing 12M)                   │   │
│  │      ╭──────────╮                │  │                                                      │   │
│  │    ╭╯  Sales    ╰╮  KPIs:       │  │  $/unit ▲                         $M Carrying Value ▲│   │
│  │   │   Freight    │  Total $4.1M │  │     50 ├ ●                                  ◆  │ 6.0│   │
│  │   │    62%       │  % Rev: 9.1% │  │     45 ├   ●  ●                          ◆   │ 5.5│   │
│  │   │   ╭─────╮   │  YoY: ▲+4%   │  │     40 ├      ●  ●  ●  ●  ●  ●  ◆  ◆   │ 5.0│   │
│  │   ╰╮ │ PO   │ ╭╯              │  │     35 ├                        ◆         │ 4.5│   │
│  │    ╰│Freight│╯                │  │        └──┬──┬──┬──┬──┬──┬──┬──┬──┬──►   │    │   │
│  │     │  38%  │                 │  │         J  F  M  A  M  J  J  A  S  O      │    │   │
│  │     ╰───────╯                 │  │                                           │    │   │
│  │ 🟧 By Ship Method             │  │  ● Cost/Unit  ◆ Carrying Value  ‥‥ Prior  │    │   │
│  │ 🟥 Territory Group            │  │ 🟧 Product Category  🟥 Work Center       │    │   │
│  └───────────────────────────────────┘  └──────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌──────────────────┐  ┌──────────────────────────────┐  ┌──────────────────────────────────────┐ │
│  │ Inv Carrying Value│  │ YoY Cost Growth by Component │  │ MoM Cost Variance (Waterfall)       │ │
│  │                   │  │ Horizontal Bars              │  │                                      │ │
│  │  Total: $5.2M     │  │                              │  │  $M ▲                                │ │
│  │  Excess: $1.8M    │  │  Material  ████████  +3%     │  │  2.6 ├──┐                            │ │
│  │  YoY: ▲ +4%       │  │  Mfg      ████████████ +7%  │  │  2.5 │  ├─┐ +0.1M                    │ │
│  │                   │  │  Freight   ███████  +4%      │  │  2.4 │  │▓│            ┌─┐            │ │
│  │  Sparkline:       │  │  Tax       █████  +2%        │  │  2.3 │  │▓│    ┌─┐    │▓│ ┌──┐       │ │
│  │  ──●──●──●──●──   │  │                              │  │  2.2 │  │▓│    │░│  ┌─┤▓│ │  │       │ │
│  │                   │  │  🔴 = cost increased         │  │      │Prior│Mat││Mfg│Frt││Tax│Curr│    │ │
│  │                   │  │  🟢 = cost decreased         │  │      └────────────────────────────    │ │
│  │                   │  │ 🟧 Product Category          │  │  🟥 Product Category │ Component     │ │
│  └──────────────────┘  └──────────────────────────────┘  └──────────────────────────────────────┘ │
│                                                                                                     │
│  ┌──────────────────────────────────────┐  ┌────────────────────────────────────────────────────┐ │
│  │ Cost Component Distribution          │  │ Cost Component Waterfall (YoY Delta)               │ │
│  │                                      │  │                                                    │ │
│  │   ╭────────────╮   Component   $M  % │  │  $M ▲                                              │ │
│  │  ╱ Material    ╲   Material  12.8 45%│  │  30 ├──┐                                           │ │
│  │ │   45%        │   Mfg        8.1 29%│  │  29 │  ├──┐ +0.4M                                  │ │
│  │ │  ╭────────╮  │   Freight    4.1 14%│  │  28 │  │▓▓├──┐ +0.5M        ┌──┐                   │ │
│  │ │  │Mfg 29% │  │   Tax        3.4 12%│  │  27 │  │▓▓│▓▓│       ┌──┐  │  │                   │ │
│  │ │  ╰────────╯  │              ──────│  │  26 │  │▓▓│▓▓│  +0.2M│▓▓│  │  │ $28.4M             │ │
│  │ │  Freight 14% │   Total     28.4 100%│ │     │Prior│Mat│Mfg│Frt │Tax│Curr│                   │ │
│  │ │   Tax 12%    │              ──────│  │     └──────────────────────────────                  │ │
│  │  ╲            ╱                     │  │                                                    │ │
│  │   ╰────────────╯                     │  │  🟢 Decrease  🔴 Increase  🔵 Total               │ │
│  │ 🟧 YTD / QTD / MTD                  │  │ 🟧 Product Category                               │ │
│  └──────────────────────────────────────┘  └────────────────────────────────────────────────────┘ │
│                                                                                                     │
│  ┌──────────────────────────────────────┐  ┌────────────────────────────────────────────────────┐ │
│  │ Cost Driver KPIs                     │  │ Cost Driver Matrix (Heatmap)                       │ │
│  │                                      │  │                                                    │ │
│  │  ┌──────────┐ ┌──────────┐          │  │            │Vendor A│Vendor B│Vendor C│Vendor D│... │ │
│  │  │AVG COST  │ │AVG COST  │          │  │  Material  │ ██████ │ ████   │ ███    │ ██     │    │ │
│  │  │/VENDOR   │ │/WORKCTR  │          │  │            │ $3.2M  │ $2.1M  │ $1.5M  │ $0.9M  │    │ │
│  │  │ $1.28M   │ │ $1.35M   │          │  │            │WC-Paint│WC-Weld │WC-Mach │WC-Assm │    │ │
│  │  └──────────┘ └──────────┘          │  │  Mfg       │ █████  │ ████   │ ███    │ ██     │    │ │
│  │  ┌──────────┐ ┌──────────┐          │  │            │ $2.8M  │ $1.9M  │ $1.2M  │ $0.8M  │    │ │
│  │  │COST-TO-  │ │MFG COST  │          │  │            │XL Ship │Ground  │Cargo   │Express │    │ │
│  │  │REVENUE   │ │VARIANCE  │          │  │  Freight   │ ██████ │ ████   │ ███    │ █      │    │ │
│  │  │  63%     │ │  +2.3%   │          │  │            │ $1.8M  │ $1.1M  │ $0.7M  │ $0.3M  │    │ │
│  │  └──────────┘ └──────────┘          │  │                                                    │ │
│  │                                      │  │  ███ Darker = higher % of row total               │ │
│  │                                      │  │ 🟧 Product Category 🟥 Vendor 🟥 Work Center     │ │
│  └──────────────────────────────────────┘  └────────────────────────────────────────────────────┘ │
│                                                                                                     │
│  ┌──────────────────────────────┐  ┌─────────────────────────────────────────────────────────────┐ │
│  │ Cost by Work Center          │  │ Cost by Sales Territory                                     │ │
│  │ Horizontal Bars              │  │ Horizontal Bars                                             │ │
│  │                              │  │                                                             │ │
│  │  Paint     ████████████ $2.8M│  │  North America ████████████████ $8.2M  (Cost/Rev:8.5%)     │ │
│  │  Welding   ██████████  $2.1M │  │  Europe        ████████████    $5.4M  (Cost/Rev:9.1%)     │ │
│  │  Machining ████████    $1.5M │  │  Pacific       ████████        $3.1M  (Cost/Rev:8.8%)     │ │
│  │  Assembly  ██████      $1.0M │  │                                                             │ │
│  │  Finishing ████        $0.7M │  │  ████ Revenue (ref)  ████ Cost (freight+tax)               │ │
│  │                              │  │  Labels: Cost $, Cost-as-%-Revenue                          │ │
│  │  ████ Planned  ▒▒ Variance   │  │                                                             │ │
│  │ 🟧 Product Cat 🟥 Schedule  │  │ 🟧 Freight/Tax/Both  🟥 Sales Channel                     │ │
│  └──────────────────────────────┘  └─────────────────────────────────────────────────────────────┘ │
│                                                                                                     │
│  ┌──────────────────────────────────────────────┐  ┌────────────────────────────────────────────┐ │
│  │ Cost by Product Line (Table)                  │  │ Cost Distribution Treemap                  │ │
│  │                                               │  │                                            │ │
│  │  Category    │Mat $│Mfg $│Frt $│Total│CPU │YoY│  │  ┌──────────────────┬────────────────────┐ │ │
│  │  ────────────┼─────┼─────┼─────┼─────┼────┼───│  │  │                  │                    │ │ │
│  │  Bikes       │$8.2M│$5.1M│$2.8M│16.1M│$285│+6%│  │  │   MATERIAL       │  MANUFACTURING     │ │ │
│  │   ──●──●──●  │     │     │     │     │    │🔴 │  │  │   $12.8M         │  $8.1M             │ │ │
│  │  Components  │$2.8M│$1.8M│$0.8M│ 5.4M│$ 42│+3%│  │  │  ┌──────┬─────┐ │ ┌─────┬──────┐    │ │ │
│  │   ──●──●──●  │     │     │     │     │    │🔴 │  │  │  │Vend A│Vnd B│ │ │Paint│Weld  │    │ │ │
│  │  Clothing    │$1.2M│$0.9M│$0.3M│ 2.4M│$ 18│-1%│  │  │  │$3.2M │$2.1M│ │ │$2.8M│$2.1M │    │ │ │
│  │   ──●──●──●  │     │     │     │     │    │🟢 │  │  │  └──────┴─────┘ │ └─────┴──────┘    │ │ │
│  │  Accessories │$0.6M│$0.3M│$0.2M│ 1.1M│$  8│+2%│  │  ├──────────┬─────┴────────────────────┤ │ │
│  │   ──●──●──●  │     │     │     │     │    │🔴 │  │  │ FREIGHT  │         TAX               │ │ │
│  │                                               │  │  │ $4.1M    │         $3.4M              │ │ │
│  │ 🟧 Cat/Subcat/Product  🟥 WC  🟥 Vendor     │  │  │ ┌────┬──┐│ ┌──────┬───────┐           │ │ │
│  └──────────────────────────────────────────────┘  │  │ │N.Am│EU││ │N.Amer│Europe │           │ │ │
│                                                     │  │ │$1.8│$1││ │$1.5M │$1.0M  │           │ │ │
│                                                     │  │ └────┴──┘│ └──────┴───────┘           │ │ │
│                                                     │  └──────────┴────────────────────────────┘ │ │
│                                                     │  🟧 By Component/Product 🟥 Filters       │ │
│                                                     └────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## DATA MODEL MAPPING

### Tables Used

| Table | Role | Key Fields for This Dashboard |
|---|---|---|
| `fct_purchase` | Material cost & purchase freight | line_total, order_freight_amount, order_tax_amount, order_date_key |
| `fct_workorder` | Manufacturing cost (order-level) | total_planned_cost, total_actual_cost, cost_variance, cost_variance_pct, stocked_qty, start_date_key |
| `fct_workorder_routing` | Manufacturing cost (routing-level) | planned_cost, actual_cost, cost_variance, cost_per_resource_hr, actual_resource_hrs |
| `fct_sale` | Sales freight & tax | order_freight_amount, order_tax_amount, line_total, order_date_key |
| `fct_inventory` | Inventory carrying value (snapshot) | quantity, standard_cost, total_manufacture_value, safety_stock_level |
| `fct_inventory_daily_snapshot` | Inventory carrying value (time series) | quantity_on_hand, daily_change |
| `dim_product` | Product hierarchy & standard cost | product_category_name, product_subcategory_name, standard_cost, product_name |
| `dim_vendor` | Vendor dimension for material cost | vendor_name, credit_rating, is_preferred_vendor |
| `dim_workcenter` | Work center dimension for mfg cost | location_name, cost_rate, availability |
| `dim_sales_territory` | Territory dimension for sales cost | territory_name, territory_group, country_name |
| `dim_ship_method` | Ship method for freight analysis | ship_method_name, ship_base, ship_rate |
| `dim_date` | Time intelligence | date_key, calendar_year, calendar_month, calendar_quarter |

---

### KPI Definitions & SQL Calculations

**Section 1: Cost Over Time**

```sql
-- Total SCM Cost (YTD)
-- Material Cost (from Procurement)
SELECT SUM(line_total) AS material_cost
FROM fct_purchase
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

-- Manufacturing Cost (from Work Orders)
SELECT SUM(total_actual_cost) AS mfg_cost
FROM fct_workorder
WHERE start_date_key BETWEEN @ytd_start AND @ytd_end;

-- Total Freight (Sales + Purchase)
SELECT 
    (SELECT SUM(order_freight_amount) FROM fct_sale 
     WHERE order_date_key BETWEEN @ytd_start AND @ytd_end)
  + (SELECT SUM(order_freight_amount) FROM fct_purchase 
     WHERE order_date_key BETWEEN @ytd_start AND @ytd_end) AS total_freight;

-- Total Tax (Sales + Purchase)
SELECT 
    (SELECT SUM(order_tax_amount) FROM fct_sale 
     WHERE order_date_key BETWEEN @ytd_start AND @ytd_end)
  + (SELECT SUM(order_tax_amount) FROM fct_purchase 
     WHERE order_date_key BETWEEN @ytd_start AND @ytd_end) AS total_tax;

-- Total SCM Cost = Material + Mfg + Freight + Tax
-- Note: Inventory Carrying Value is capital-at-risk, not P&L cost — shown separately

-- Cost Per Unit
SELECT SUM(total_actual_cost) / NULLIF(SUM(stocked_qty), 0) AS cost_per_unit
FROM fct_workorder
WHERE start_date_key BETWEEN @ytd_start AND @ytd_end;

-- Total SCM Cost Trend by Month (Stacked Area)
SELECT 
    d.calendar_year,
    d.calendar_month,
    SUM(CASE WHEN src = 'material' THEN cost ELSE 0 END) AS material_cost,
    SUM(CASE WHEN src = 'mfg'      THEN cost ELSE 0 END) AS mfg_cost,
    SUM(CASE WHEN src = 'freight'  THEN cost ELSE 0 END) AS freight_cost,
    SUM(CASE WHEN src = 'tax'      THEN cost ELSE 0 END) AS tax_cost
FROM (
    SELECT order_date_key AS date_key, line_total AS cost, 'material' AS src FROM fct_purchase
    UNION ALL
    SELECT start_date_key, total_actual_cost, 'mfg' FROM fct_workorder
    UNION ALL
    SELECT order_date_key, order_freight_amount, 'freight' FROM fct_sale
    UNION ALL
    SELECT order_date_key, order_freight_amount, 'freight' FROM fct_purchase
    UNION ALL
    SELECT order_date_key, order_tax_amount, 'tax' FROM fct_sale
    UNION ALL
    SELECT order_date_key, order_tax_amount, 'tax' FROM fct_purchase
) costs
JOIN dim_date d ON costs.date_key = d.date_key
GROUP BY d.calendar_year, d.calendar_month
ORDER BY d.calendar_year, d.calendar_month;
```

**Section 2: Freight & Inventory Carrying Value**

```sql
-- Freight Breakdown (Sales vs Purchase)
SELECT 
    SUM(order_freight_amount) AS sales_freight
FROM fct_sale
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

SELECT 
    SUM(order_freight_amount) AS purchase_freight
FROM fct_purchase
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

-- Freight by Ship Method
SELECT 
    sm.ship_method_name,
    SUM(s.order_freight_amount) AS freight_amount
FROM fct_sale s
JOIN dim_ship_method sm ON s.dim_ship_method_sk = sm.dim_ship_method_sk
WHERE s.order_date_key BETWEEN @ytd_start AND @ytd_end
GROUP BY sm.ship_method_name;

-- Freight as % of Revenue
SELECT 
    SUM(order_freight_amount) * 100.0 / NULLIF(SUM(line_total), 0) AS freight_pct_revenue
FROM fct_sale
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

-- Inventory Carrying Value (current snapshot)
SELECT 
    SUM(quantity * standard_cost) AS carrying_value,
    SUM(CASE WHEN quantity > safety_stock_level 
        THEN (quantity - safety_stock_level) * standard_cost ELSE 0 END) AS excess_value
FROM fct_inventory;

-- Inventory Carrying Value Trend (monthly end-of-month snapshots)
SELECT 
    d.calendar_year, d.calendar_month,
    SUM(snap.quantity_on_hand * p.standard_cost) AS carrying_value
FROM fct_inventory_daily_snapshot snap
JOIN dim_product p ON snap.dim_product_sk = p.dim_product_sk
JOIN dim_date d ON snap.date_key = d.date_key
WHERE d.date_key = (  -- last day of each month
    SELECT MAX(d2.date_key) FROM dim_date d2 
    WHERE d2.calendar_year = d.calendar_year 
      AND d2.calendar_month = d.calendar_month
)
GROUP BY d.calendar_year, d.calendar_month;

-- Cost Per Unit Trend (monthly)
SELECT 
    d.calendar_year, d.calendar_month,
    SUM(wo.total_actual_cost) / NULLIF(SUM(wo.stocked_qty), 0) AS cost_per_unit
FROM fct_workorder wo
JOIN dim_date d ON wo.start_date_key = d.date_key
GROUP BY d.calendar_year, d.calendar_month;
```

**Section 3: Cost Components & Drivers**

```sql
-- YoY Cost Growth by Component
-- (use Total SCM Cost Trend query, compare YTD vs Prior YTD aggregates)

-- Cost Component Distribution (Donut)
-- Reuse Total SCM Cost query, compute % share per component

-- Cost by Operational Driver: Avg Cost Per Vendor
SELECT 
    SUM(line_total) / NULLIF(COUNT(DISTINCT vendor_id), 0) AS avg_cost_per_vendor
FROM fct_purchase
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

-- Cost by Operational Driver: Avg Cost Per Work Center
SELECT 
    SUM(actual_cost) / NULLIF(COUNT(DISTINCT location_id), 0) AS avg_cost_per_workcenter
FROM fct_workorder_routing
WHERE actual_start_date_key BETWEEN @ytd_start AND @ytd_end;

-- Cost-to-Revenue Ratio
SELECT 
    total_scm_cost / NULLIF(SUM(line_total), 0) AS cost_to_revenue
FROM fct_sale
WHERE order_date_key BETWEEN @ytd_start AND @ytd_end;

-- Mfg Cost Variance % (aggregate)
SELECT 
    SUM(cost_variance) * 100.0 / NULLIF(SUM(total_planned_cost), 0) AS mfg_cost_variance_pct
FROM fct_workorder
WHERE start_date_key BETWEEN @ytd_start AND @ytd_end;

-- Cost Driver Matrix: Material by Vendor
SELECT 
    v.vendor_name,
    SUM(p.line_total) AS material_cost,
    SUM(p.line_total) * 100.0 / SUM(SUM(p.line_total)) OVER () AS pct_of_total
FROM fct_purchase p
JOIN dim_vendor v ON p.dim_vendor_sk = v.dim_vendor_sk
WHERE p.order_date_key BETWEEN @ytd_start AND @ytd_end
GROUP BY v.vendor_name
ORDER BY material_cost DESC
LIMIT 10;

-- Cost Driver Matrix: Mfg by Work Center
SELECT 
    wc.location_name,
    SUM(r.actual_cost) AS mfg_cost,
    SUM(r.planned_cost) AS planned_cost,
    SUM(r.cost_variance) AS cost_variance
FROM fct_workorder_routing r
JOIN dim_workcenter wc ON r.dim_workcenter_sk = wc.dim_workcenter_sk
GROUP BY wc.location_name
ORDER BY mfg_cost DESC;

-- Cost Driver Matrix: Freight by Ship Method
SELECT 
    sm.ship_method_name,
    SUM(s.order_freight_amount) AS sales_freight,
    SUM(p.order_freight_amount) AS purchase_freight
FROM fct_sale s
JOIN dim_ship_method sm ON s.dim_ship_method_sk = sm.dim_ship_method_sk
GROUP BY sm.ship_method_name;
```

**Section 4: Cost Distribution**

```sql
-- Cost by Work Center (with planned vs variance)
SELECT 
    wc.location_name,
    SUM(r.planned_cost) AS planned_cost,
    SUM(r.actual_cost) AS actual_cost,
    SUM(r.cost_variance) AS cost_variance,
    ROUND(SUM(r.cost_variance) * 100.0 / NULLIF(SUM(r.planned_cost), 0), 2) AS cost_variance_pct
FROM fct_workorder_routing r
JOIN dim_workcenter wc ON r.dim_workcenter_sk = wc.dim_workcenter_sk
GROUP BY wc.location_name
ORDER BY actual_cost DESC;

-- Cost by Sales Territory (freight + tax as % of revenue)
SELECT 
    st.territory_group, st.territory_name,
    SUM(s.order_freight_amount + s.order_tax_amount) AS sales_cost,
    SUM(s.line_total) AS revenue,
    ROUND(SUM(s.order_freight_amount + s.order_tax_amount) * 100.0 
          / NULLIF(SUM(s.line_total), 0), 2) AS cost_as_pct_revenue
FROM fct_sale s
JOIN dim_sales_territory st ON s.dim_sales_territory_sk = st.dim_sales_territory_sk
WHERE s.order_date_key BETWEEN @ytd_start AND @ytd_end
GROUP BY st.territory_group, st.territory_name
ORDER BY sales_cost DESC;

-- Cost by Product Line (cross-domain)
SELECT 
    p.product_category_name,
    SUM(pur.material_cost) AS material_cost,
    SUM(wo.mfg_cost) AS mfg_cost,
    SUM(sal.freight_cost) AS freight_cost,
    SUM(pur.material_cost) + SUM(wo.mfg_cost) + SUM(sal.freight_cost) AS total_cost,
    (SUM(pur.material_cost) + SUM(wo.mfg_cost) + SUM(sal.freight_cost))
        / NULLIF(SUM(wo.stocked_qty), 0) AS cost_per_unit
FROM dim_product p
LEFT JOIN (
    SELECT dim_product_sk, SUM(line_total) AS material_cost 
    FROM fct_purchase GROUP BY dim_product_sk
) pur ON p.dim_product_sk = pur.dim_product_sk
LEFT JOIN (
    SELECT dim_product_sk, SUM(total_actual_cost) AS mfg_cost, SUM(stocked_qty) AS stocked_qty
    FROM fct_workorder GROUP BY dim_product_sk
) wo ON p.dim_product_sk = wo.dim_product_sk
LEFT JOIN (
    SELECT dim_product_sk, SUM(order_freight_amount) AS freight_cost
    FROM fct_sale GROUP BY dim_product_sk
) sal ON p.dim_product_sk = sal.dim_product_sk
GROUP BY p.product_category_name
ORDER BY total_cost DESC;

-- Cost Distribution Treemap: nested by component → driver
-- Level 1: Cost Component
-- Level 2: Top drivers (Vendor for Material, WorkCenter for Mfg, Territory for Freight/Tax)
-- Reuse individual queries above, union into single result set with hierarchy labels
```

---

### Cross-Reference to Business Questions

| Business Question | Dashboard Rows |
|---|---|
| Q1: How are total SCM costs, cost per unit, freight expenses, and inventory carrying value changing over time? | **Row 1** (Total SCM Cost YTD + Trend), **Row 2** (Freight Breakdown + Cost Per Unit & Carrying Value Trend), **Row 3** (YoY Growth + MoM Variance) |
| Q2: How do supply chain costs vary across major cost components and operational drivers? | **Row 4** (Component Distribution + Waterfall), **Row 5** (Driver KPIs + Heatmap) |
| Q3: What trends can be identified in cost distribution across work centers, sales territories, and product lines? | **Row 6** (Work Center bars + Territory bars), **Row 7** (Product Line table + Treemap) |
