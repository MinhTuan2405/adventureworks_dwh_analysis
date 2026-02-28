# Manufacturing Operations & Quality Dashboard

**Overall Objective:** Analyze production output vs planned targets, identify scrap/waste drivers by category and work center, and evaluate manufacturing cost per unit versus plan — to improve yield, reduce waste, and control production costs.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                            Manufacturing Operations & Quality Dashboard                              │
│                                                                                                      │
│  Detailed routing-level cost breakdowns                                                              │
│  incorporated in separate SCM Cost Deep Dive dashboard                                               │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ Total Output     │ Work Order Volume & Yield Trend      │                                  │
│          │ (Ordered vs      │   Breakout by Month                  │  • High-level summary of         │
│ Produc-  │ Stocked) & Yield │                                      │    production output vs plan      │
│ tion     ├──────────────────┼──────────────────────────────────────┤  • Use to quickly assess if      │
│ Output   │ Output by        │ Delivery Status Distribution &       │    work orders are meeting        │
│ & Yield  │ Product Category │ Lead Time Performance                │    planned targets and if yield   │
│          │                  │   On Time / Early / Late             │    is trending up or down         │
│          ├──────────────────┼────────────────────┬─────────────────┤  • Enable deep insight into       │
│          │ WO Completion    │ Yield Rate Trend   │ Delivery Status │    on-time delivery and lead      │
│          │ Rate             │ by Category        │ Trend           │    time performance               │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Total Scrap      │                                      │  • Summarizes scrap and waste     │
│ Scrap    │ (Qty & Rate)     │ Scrap Breakdown by Category &        │    drivers across categories,     │
│ & Waste  │                  │ Work Center (Heatmap / Matrix)       │    work centers, and products     │
│ Analysis ├──────────────────┼──────────────────────────────────────┤  • Leverage to pinpoint root      │
│          │ Top 10 Products  │ Scrap Rate Trend by Scrap Category   │    causes and prioritize          │
│          │ by Scrap Rate    │                                      │    improvement actions             │
│          │ ( Intermediate ) │                                      │                                  │
├──────────┼──────────────────┼────────────────────┬─────────────────┤                                  │
│          │ Total Planned    │ Cost Per Unit Trend│ Cost Variance   │  • Detail on manufacturing        │
│ Mfg.     │ vs Actual Cost   │ (Actual vs Plan)   │ by Work Center  │    cost efficiency vs plan        │
│ Cost     │ & Variance       │                    │                 │  • Use alongside routing data     │
│          │                  │                    │                 │    to identify where cost          │
│          │                  │                    │                 │    overruns originate              │
└──────────┴──────────────────┴────────────────────┴─────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_workorder + fct_workorder_routing + dimensions)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY          │
                    │ Product Category             │
                    │ Work Center                  │
                    │ Scrap Category               │
                    │ Delivery Status              │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total Output & Yield KPIs

| Cell | Spec |
|------|------|
| **Total Output (Ordered vs Stocked) & Yield** | Headline Number + Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder |
| | `Total_Ordered = SUM(order_qty)` |
| | `Total_Stocked = SUM(stocked_qty)` |
| | `Total_Scrapped = SUM(scrapped_qty)` |
| | `Yield_Rate = SUM(stocked_qty) / SUM(order_qty) * 100` |
| | `WO_Count = COUNT(DISTINCT work_order_id)` |
| | `Avg_Yield = AVG(yield_rate_pct)` |

| Cell | Spec |
|------|------|
| **Work Order Volume & Yield Trend** | WO Volume (Stackbar) & Yield % (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total (Volume) and Average (Yield) |
| | Source: fct_workorder + dim_date |
| | `Monthly_WO_Count = COUNT(DISTINCT work_order_id) GROUP BY month` |
| | `Monthly_Stocked = SUM(stocked_qty) GROUP BY month` |
| | `Monthly_Yield = SUM(stocked_qty) / SUM(order_qty) * 100 GROUP BY month` |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Work Center |
| | 🟥 Filter – Delivery Status |

---

### ROW 2: Output by Category & Delivery Performance

| Cell | Spec |
|------|------|
| **Output by Product Category** | Table; Headline # & Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder + dim_product |
| | Columns: Category, Ordered Qty, Stocked Qty, Yield %, Scrap %, WO Count |
| | 🟧 Toggle – Category vs Subcategory |
| | 🟥 Filter – Delivery Status |

| Cell | Spec |
|------|------|
| **Delivery Status Distribution & Lead Time** | Stacked Bar (Delivery) + KPI Cards (Lead Time) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_workorder |
| | `On_Time = COUNT(delivery_status = 'On Time')` |
| | `Early = COUNT(delivery_status = 'Early')` |
| | `Late = COUNT(delivery_status = 'Late')` |
| | `Avg_Actual_Lead = AVG(actual_lead_time_days)` |
| | `Avg_Planned_Lead = AVG(planned_lead_time_days)` |
| | `Avg_Days_Ahead_Behind = AVG(days_ahead_or_behind)` |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Work Center |

---

### ROW 3: Completion Rate, Yield by Category & Delivery Trend

| Cell | Spec |
|------|------|
| **WO Completion Rate** | KPI Cards |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder |
| | `Completion_Rate = SUM(completed_routing_steps) / SUM(total_routing_steps) * 100` |
| | `Avg_Routing_Steps = AVG(total_routing_steps)` |
| | `Total_Resource_Hrs = SUM(total_actual_resource_hrs)` |
| | `Hrs_Per_WO = SUM(total_actual_resource_hrs) / COUNT(DISTINCT work_order_id)` |

| Cell | Spec |
|------|------|
| **Yield Rate Trend by Category** | Multi-line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_workorder + dim_product |
| | `Yield_% = SUM(stocked_qty) / SUM(order_qty) * 100` per category per month |
| | One line per product category (Bikes, Components, Clothing, Accessories) |
| | 🟧 Drop-Down Filter – Product Category |
| | 🟥 Filter – Work Center |

| Cell | Spec |
|------|------|
| **Delivery Status Trend** | Stacked Area Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Count |
| | Source: fct_workorder + dim_date |
| | `COUNT(work_order_id) GROUP BY delivery_status, month` |
| | Stacks: On Time (green), Early (blue), Late (red) |
| | 🟥 Filter – Product Category |

---

### ROW 4: Scrap KPIs & Breakdown Matrix

| Cell | Spec |
|------|------|
| **Total Scrap (Qty & Rate)** | Headline Number + Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder |
| | `Total_Scrapped = SUM(scrapped_qty)` |
| | `Scrap_Rate = SUM(scrapped_qty) / SUM(order_qty) * 100` |
| | `WO_With_Scrap = COUNT(has_scrap = true)` |
| | `Scrap_%_of_WO = WO_With_Scrap / WO_Count * 100` |

| Cell | Spec |
|------|------|
| **Scrap Breakdown by Category & Work Center** | Heatmap / Matrix |
| | Rows: Scrap Category (Paint/Finish, Machining, Welding, Forming, Other) |
| | Columns: Work Center (location_name) |
| | Values: SUM(scrapped_qty) or Scrap Rate % |
| | Color: Intensity by scrap volume |
| | Timeframe: YTD |
| | Source: fct_workorder + dim_scrap_reason + dim_workcenter (via fct_workorder_routing) |
| | 🟧 Toggle – Qty vs Rate % |
| | 🟥 Filter – Product Category |

---

### ROW 5: Product-level Scrap & Scrap Category Trend

| Cell | Spec |
|------|------|
| **Top 10 Products by Scrap Rate** | Table with Conditional Formatting |
| | Timeframe: YTD |
| | Source: fct_workorder + dim_product |
| | Columns: Product, Scrap Rate %, Scrapped Qty, Order Qty, Yield %, Scrap Reason |
| | `Scrap_Rate = SUM(scrapped_qty) / SUM(order_qty) * 100` per product |
| | 🔴 Rate > 10% / 🟡 Rate 5–10% / 🟢 Rate < 5% |
| | 🟧 Toggle – Top 10 / Bottom 10 |
| | 🟥 Filter – Scrap Category |

| Cell | Spec |
|------|------|
| **Scrap Rate Trend by Scrap Category** | Multi-line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_workorder + dim_scrap_reason + dim_date |
| | `Scrap_Rate_% per scrap_category per month` |
| | Lines: Paint/Finish, Machining, Welding, Forming, Other |
| | 🟧 Drop-Down Filter – Scrap Category |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Work Center |

---

### ROW 6: Manufacturing Cost Analysis

| Cell | Spec |
|------|------|
| **Total Planned vs Actual Cost & Variance** | Headline Number + Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder |
| | `Planned_Cost = SUM(total_planned_cost)` |
| | `Actual_Cost = SUM(total_actual_cost)` |
| | `Cost_Variance = SUM(cost_variance)` |
| | `Variance_% = SUM(cost_variance) / SUM(total_planned_cost) * 100` |
| | `Avg_Cost_Per_Unit = SUM(total_actual_cost) / SUM(stocked_qty)` |

| Cell | Spec |
|------|------|
| **Cost Per Unit Trend (Actual vs Plan)** | Dual-line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_workorder + dim_date |
| | `Actual_CPU = SUM(total_actual_cost) / SUM(stocked_qty) GROUP BY month` |
| | `Planned_CPU = SUM(total_planned_cost) / SUM(order_qty) GROUP BY month` |
| | 🟧 Drop-Down Filter – Product Category |
| | 🟥 Filter – Work Center |

| Cell | Spec |
|------|------|
| **Cost Variance by Work Center** | Horizontal Bar Chart (sorted by variance) |
| | Timeframe: YTD |
| | Measurement Range: Cumulative YTD |
| | Source: fct_workorder_routing + dim_workcenter |
| | `Variance = SUM(actual_cost) - SUM(planned_cost) GROUP BY location_name` |
| | `Variance_% = Variance / SUM(planned_cost) * 100` |
| | `Avg_Cost_Per_Hr = SUM(actual_cost) / SUM(actual_resource_hrs)` |
| | Color: 🔴 Over budget (positive variance) / 🟢 Under budget (negative) |
| | 🟧 Toggle – Variance $ vs Variance % |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Schedule Status |

---

### ROW 7: Cost Deep Dive by Product & Resource Hours

| Cell | Spec |
|------|------|
| **Cost Variance by Product Category** | Table with Conditional Formatting |
| | Timeframe: YTD |
| | Source: fct_workorder + dim_product |
| | Columns: Category, Planned Cost, Actual Cost, Variance $, Variance %, CPU, Resource Hrs |
| | 🔴 Variance > +10% / 🟡 Variance 0–10% / 🟢 Variance < 0% (under budget) |
| | 🟧 Toggle – Category vs Subcategory |

| Cell | Spec |
|------|------|
| **Resource Hours & Cost Per Hour Trend** | Dual-axis: Resource Hrs (Bar) & Cost/Hr (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total (Hrs) and Average (Cost/Hr) |
| | Source: fct_workorder_routing + dim_date |
| | `Monthly_Hrs = SUM(actual_resource_hrs) GROUP BY month` |
| | `Cost_Per_Hr = SUM(actual_cost) / SUM(actual_resource_hrs) GROUP BY month` |
| | 🟧 Drop-Down Filter – Work Center |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Schedule Status (On Schedule / Behind / In Progress) |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Product Category        │
  (e.g., performance by work center or product)           │  Work Center             │
                                                          │  Scrap Category          │
  Align Dashboard permissions with existing               │  Delivery Status         │
  reporting (some users can't see cost detail)            └──────────────────────────┘

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total Output & Yield      │  │  Work Order Volume & Yield Trend                 │  Filter       │
│  │                           │  │                                                  │               │
│  │  72,500       97.2%       │  │   ██ WO Count   ██ Stocked Qty   ── Yield %     │  🟧 Toggle -  │
│  │  Ordered Qty  Yield Rate  │  │                                                  │  Product Cat  │
│  │                           │  │  8K ┌──────────────────────────────────┐  100%   │               │
│  │  70,400       2.8%        │  │     │ ████  ████  ████  ████  ████    │         │  🟥 Filter -  │
│  │  Stocked Qty  Scrap Rate  │  │     │ ████  ████  ████  ████  ████    │   95%   │  Work Center  │
│  │                           │  │     │ ████  ████  ████  ████  ████    │         │               │
│  │  2,100        1,820       │  │  0  │────────────────────────────────│   90%   │  🟥 Filter -  │
│  │  Scrapped     WO Count    │  │     M1   M3   M5   M7   M9   M11     │         │  Delivery     │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘  Status       │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Output by Product Category│  │  Delivery Status & Lead Time                     │  Filter       │
│  │                           │  │                                                  │               │
│  │          Ordered  Yield   │  │   ██ On Time  ██ Early  ██ Late                  │  🟧 Toggle -  │
│  │           Stocked Scrap%  │  │                                                  │  Product Cat  │
│  │ Bikes    32,500  96.1%    │  │  ┌──────────────────────────────────┐             │               │
│  │ Comp.    28,200  97.8%    │  │  │ ██████████████████████████████  │ On Time 72% │  🟥 Filter -  │
│  │ Cloth.    8,300  98.5%    │  │  │ ████████████                    │ Early   18% │  Work Center  │
│  │ Access.   3,500  99.0%    │  │  │ ██████                          │ Late    10% │               │
│  │                           │  │  └──────────────────────────────────┘             │               │
│  │         Drop-Down Filter  │  │  Avg Lead: 8.2d (plan: 7.5d) | +0.7d behind     │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ WO Completion Rate        │  │  Yield Rate Trend           │  │ Delivery Status Trend          │ │
│  │                           │  │  by Category                │  │                                │ │
│  │  Completion: 94.2%        │  │                              │  │   ██ On Time ██ Early ██ Late  │ │
│  │  +1.5%     -0.3%    +2%  │  │  ── Bikes  ── Comp.         │  │                                │ │
│  │  Over      Prior    YoY  │  │  ── Cloth.  ── Access.       │  │  100%┌──────────────────────┐  │ │
│  │  Target    Month         │  │                              │  │      │██████████████████████│  │ │
│  │                           │  │  100%──●──●──●──●           │  │   80%│████████████████      │  │ │
│  │  Avg Steps: 4.2           │  │   97%       ●──●──●        │  │      │████████              │  │ │
│  │  Total Hrs: 52,300        │  │   94%              ●──●    │  │   60%│                      │  │ │
│  │  Hrs/WO: 28.7             │  │   M1  M3  M5  M7  M9  M11 │  │      M1  M3  M5  M7  M9    │  │ │
│  │                           │  │                              │  │                                │ │
│  │                           │  │  🟧 Drop-Down - Prod. Cat   │  │  🟥 Filter - Product Cat       │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total Scrap               │  │  Scrap Breakdown: Category × Work Center         │  Filter       │
│  │                           │  │                                                  │               │
│  │  2,100        2.8%        │  │  Scrap Category  │ Frame  │ Paint │ SubAsm │ ... │  🟧 Toggle -  │
│  │  Scrapped     Scrap Rate  │  │  ────────────────┼────────┼───────┼────────┼──── │  Qty vs Rate  │
│  │                           │  │  Paint/Finish    │  ██    │ ████  │   █    │     │               │
│  │  420          23.1%       │  │  Machining       │ ████   │  ██   │  ███   │     │  🟥 Filter -  │
│  │  WO w/ Scrap  % of WOs   │  │  Welding         │  ███   │   █   │ ████   │     │  Product Cat  │
│  │                           │  │  Forming         │   ██   │       │  ██    │     │               │
│  │  Prior Year: 2,350        │  │  Other           │    █   │   █   │   █    │     │               │
│  │  YoY: -10.6% ▼           │  │                                                  │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Top 10 Products by Scrap Rate                                                              │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │   │
│  │  │ Product          │ Scrap Rate │ Scrapped │ Ordered │ Yield % │ Top Scrap Reason    │    │   │
│  │  ├─────────────────────────────────────────────────────────────────────────────────────┤    │   │
│  │  │ HL Road Frame    │ 12.5% 🔴   │   250   │  2,000  │  87.5%  │ Paint Defect        │    │   │
│  │  │ ML Mountain      │  9.8% 🟡   │   180   │  1,840  │  90.2%  │ Machining Error     │    │   │
│  │  │ HL Touring Frame │  7.2% 🟡   │   120   │  1,670  │  92.8%  │ Weld Flaw           │    │   │
│  │  │ ML Road Frame    │  4.1% 🟢   │    85   │  2,080  │  95.9%  │ Forming Issue       │    │   │
│  │  │ ...              │            │         │         │         │                     │    │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │   │
│  │  🔴 Rate > 10%   🟡 Rate 5-10%   🟢 Rate < 5%                                             │   │
│  │  🟧 Toggle - Top 10 / Bottom 10                                                            │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Scrap Rate Trend by Scrap Category                                                         │   │
│  │  ┌────────────────────────────────────────────────────────────────────────────────────┐     │   │
│  │  │   ── Paint/Finish   ── Machining   ── Welding   ── Forming   ── Other             │     │   │
│  │  │  8% ┌──────────────────────────────────────────────────────────────┐               │     │   │
│  │  │     │  ●                                                          │               │     │   │
│  │  │  6% │  ●──●                                                       │               │     │   │
│  │  │     │       ●──●──●                                               │               │     │   │
│  │  │  4% │  ○──○──○     ●──●──●                                       │               │     │   │
│  │  │     │              ○──○──○──○──○                                  │               │     │   │
│  │  │  2% │  △──△──△──△──△──△──△──△──△                                │               │     │   │
│  │  │     │  M1   M3   M5   M7   M9   M11                              │               │     │   │
│  │  │  0% └──────────────────────────────────────────────────────────────┘               │     │   │
│  │  └────────────────────────────────────────────────────────────────────────────────────┘     │   │
│  │  🟧 Drop-Down Filter – Scrap Category                                                      │   │
│  │  🟥 Filter – Product Category | 🟥 Filter – Work Center                                    │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Total Cost & Variance     │  │  Cost Per Unit Trend        │  │ Cost Variance by Work Center   │ │
│  │                           │  │  (Actual vs Plan)           │  │                                │ │
│  │  $2.85M      $2.72M      │  │                              │  │  Frame Welding  ████████ +$32K │ │
│  │  Actual      Planned     │  │  ── Actual CPU  ── Plan CPU  │  │  Frame Forming  ██████   +$21K │ │
│  │                           │  │                              │  │  Paint Shop     ████     +$14K │ │
│  │  +$130K       +4.8%      │  │  $50 ┌──────────────────┐   │  │  Subassembly    ██       +$8K  │ │
│  │  Variance $   Variance % │  │      │  ●──●             │   │  │  Final Assembly ██       -$5K  │ │
│  │                           │  │  $40 │       ●──●──●     │   │  │  Misc.          █        -$2K  │ │
│  │  $40.50    $38.70        │  │      │            ●──●   │   │  │                                │ │
│  │  Actual CPU  Plan CPU    │  │  $30 │  ○──○──○──○──○──○ │   │  │  🔴 Over Budget                │ │
│  │                           │  │      M1  M3  M5  M7  M9 │   │  │  🟢 Under Budget               │ │
│  │  52,300 hrs              │  │                              │  │                                │ │
│  │  Total Resource Hrs       │  │  🟧 Drop-Down - Prod. Cat   │  │  🟧 Toggle - $ vs %            │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Cost Variance by Product Category                                                          │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │   │
│  │  │ Category     │ Planned    │ Actual     │ Variance $ │ Var %   │  CPU    │ Res. Hrs  │    │   │
│  │  ├─────────────────────────────────────────────────────────────────────────────────────┤    │   │
│  │  │ Bikes        │ $1.52M     │ $1.62M     │ +$100K 🔴  │ +6.6%  │ $49.80  │ 28,500    │    │   │
│  │  │ Components   │ $0.82M     │ $0.84M     │  +$20K 🟡  │ +2.4%  │ $29.80  │ 15,200    │    │   │
│  │  │ Clothing     │ $0.28M     │ $0.27M     │  -$10K 🟢  │ -3.6%  │ $32.50  │  6,100    │    │   │
│  │  │ Accessories  │ $0.10M     │ $0.12M     │  +$20K 🔴  │+20.0%  │ $34.30  │  2,500    │    │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │   │
│  │  🔴 Variance > +10%   🟡 Variance 0-10%   🟢 Variance < 0% (under budget)                 │   │
│  │  🟧 Toggle - Category / Subcategory                                                        │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Resource Hours & Cost Per Hour Trend                                                       │   │
│  │  ┌────────────────────────────────────────────────────────────────────────────────────┐     │   │
│  │  │   ██ Resource Hrs    ── Cost Per Hr ($)    ── Prior Year Cost/Hr                  │     │   │
│  │  │  6K ┌──────────────────────────────────────────────────────────────┐  $60          │     │   │
│  │  │     │ ████  ████  ████  ████  ████  ████  ████  ████  ████       │               │     │   │
│  │  │  4K │ ████  ████  ████  ████  ████  ████  ████  ████  ████       │  $50          │     │   │
│  │  │     │ ████  ████  ████  ████  ████  ████  ████  ████  ████       │               │     │   │
│  │  │  2K │ ████  ████  ████  ████  ████  ████  ████  ████  ████       │  $40          │     │   │
│  │  │     │  ●────●────●────●────●────●────●────●────●                 │               │     │   │
│  │  │  0  │  M1   M2   M3   M4   M5   M6   M7   M8   M9              │  $30          │     │   │
│  │  │     └──────────────────────────────────────────────────────────────┘               │     │   │
│  │  └────────────────────────────────────────────────────────────────────────────────────┘     │   │
│  │  🟧 Drop-Down Filter – Work Center                                                         │   │
│  │  🟥 Filter – Product Category | 🟥 Filter – Schedule Status                                │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_workorder` | Fact – grain: work order. Output, yield, scrap, cost at WO level |
| `fct_workorder_routing` | Fact – grain: work order operation step. Cost, hours at routing level |
| `dim_product` | Product name, category, subcategory, standard_cost, days_to_manufacture |
| `dim_scrap_reason` | Scrap reason name, scrap category (Paint/Finish, Machining, Welding, Forming, Other) |
| `dim_workcenter` | Location name, cost rate, availability |
| `dim_date` | Date dimension (start_date_key, end_date_key, due_date_key) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Output | `order_qty`, `stocked_qty`, `scrapped_qty` |
| Yield/Scrap | `yield_rate_pct`, `scrap_rate_pct`, `has_scrap` |
| Scrap Detail | `scrap_reason_name`, `scrap_category` (dim_scrap_reason) |
| Delivery | `delivery_status` (On Time/Early/Late), `days_ahead_or_behind` |
| Lead Time | `actual_lead_time_days`, `planned_lead_time_days` |
| Routing | `total_routing_steps`, `completed_routing_steps` |
| Cost (WO) | `total_planned_cost`, `total_actual_cost`, `cost_variance`, `cost_variance_pct` |
| Cost (Routing) | `planned_cost`, `actual_cost`, `cost_variance`, `cost_per_resource_hr` |
| Resource | `total_actual_resource_hrs` (WO), `actual_resource_hrs` (routing) |
| Schedule | `schedule_status` (On Schedule / Behind / In Progress / Not Started) |
| Work Center | `location_name`, `cost_rate`, `availability` |

### **Key Calculations**
```sql
-- Production Output
Total_Ordered       = SUM(order_qty)
Total_Stocked       = SUM(stocked_qty)
Total_Scrapped      = SUM(scrapped_qty)
Yield_Rate          = SUM(stocked_qty) / SUM(order_qty) * 100
Scrap_Rate          = SUM(scrapped_qty) / SUM(order_qty) * 100
WO_Count            = COUNT(DISTINCT work_order_id)

-- Delivery Performance
On_Time_%           = COUNT(CASE WHEN delivery_status = 'On Time' THEN 1 END) / COUNT(*) * 100
Early_%             = COUNT(CASE WHEN delivery_status = 'Early' THEN 1 END) / COUNT(*) * 100
Late_%              = COUNT(CASE WHEN delivery_status = 'Late' THEN 1 END) / COUNT(*) * 100
Avg_Lead_Time       = AVG(actual_lead_time_days)
Avg_Days_Behind     = AVG(days_ahead_or_behind)

-- Completion
Completion_Rate     = SUM(completed_routing_steps) / SUM(total_routing_steps) * 100
Hrs_Per_WO          = SUM(total_actual_resource_hrs) / COUNT(DISTINCT work_order_id)

-- Scrap Analysis
WO_With_Scrap       = COUNT(CASE WHEN has_scrap = true THEN 1 END)
Scrap_%_of_WO       = WO_With_Scrap / WO_Count * 100
-- Breakdown by scrap_category × location_name (heatmap)

-- Manufacturing Cost
Cost_Variance       = SUM(total_actual_cost) - SUM(total_planned_cost)
Variance_%          = Cost_Variance / SUM(total_planned_cost) * 100
Actual_CPU          = SUM(total_actual_cost) / SUM(stocked_qty)
Planned_CPU         = SUM(total_planned_cost) / SUM(order_qty)

-- Routing-level Cost (by Work Center)
WC_Variance         = SUM(actual_cost) - SUM(planned_cost) GROUP BY location_name
Cost_Per_Hr         = SUM(actual_cost) / SUM(actual_resource_hrs)

-- Conditional Formatting
Scrap:    🔴 Rate > 10%  |  🟡 Rate 5-10%   |  🟢 Rate < 5%
Cost:     🔴 Var > +10%  |  🟡 Var 0-10%    |  🟢 Var < 0% (under budget)
```
