# Overall SCM Dashboard

**Overall Objective:** Provide an executive-level view of end-to-end supply chain performance — aggregating headline KPIs from procurement, manufacturing, inventory, and sales — to benchmark against prior periods, identify cross-functional bottlenecks, and analyze total SCM cost distribution.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     Overall SCM Dashboard                                            │
│                                                                                                      │
│  Domain-specific drill-downs available in dedicated dashboards:                                       │
│  Purchasing | Manufacturing | Inventory | Sales | Product | Cost Deep Dive                           │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ SCM Scorecard    │ KPI Trend Sparklines                 │                                  │
│          │ (Headline KPIs   │   Revenue, Cost, Yield, Fill Rate,   │  • Executive summary of all      │
│ SCM      │ with YoY / MoM   │   Scrap Rate — vs Prior Period       │    supply chain health in one    │
│ Score-   ├──────────────────┼──────────────────────────────────────┤    view                          │
│ card &   │ SCM Health       │ Period-over-Period Comparison         │  • Use to quickly assess if      │
│ Bench-   │ Gauge            │   YTD vs Prior YTD across            │    the overall chain is on       │
│ mark     │ (Composite Index)│   all domains                        │    track or degrading            │
│          ├──────────────────┼────────────────────┬─────────────────┤  • Enable quick navigation to    │
│          │ Performance vs   │ YoY Variance by    │ MoM Variance by │    domain-specific dashboards    │
│          │ Prior Year       │ Domain             │ Domain          │                                  │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ SCM Funnel       │                                      │  • Visualizes the end-to-end     │
│ Funnel   │ Flow             │ Funnel Stage KPI Trend               │    flow from procurement to      │
│ Perform- │ (Procurement →   │   Each stage: key metric + trend     │    sales with key metric per     │
│ ance     │ Mfg → Inventory  │                                      │    stage                         │
│          │ → Sales)         │                                      │  • Leverage to identify which    │
│          ├──────────────────┼──────────────────────────────────────┤    funnel stage is the            │
│          │ Stage Efficiency │ Cross-Domain Impact Matrix            │    bottleneck dragging overall   │
│          │ Comparison       │   Procurement → Manufacturing →      │    performance down              │
│          │ ( Intermediate ) │   Inventory → Sales correlations     │                                  │
├──────────┼──────────────────┼────────────────────┬─────────────────┤                                  │
│          │ Total SCM Cost   │ Cost Breakdown by  │ Cost by Product │  • Detail on where total SCM     │
│ Cost     │ by Type          │ Domain & Trend     │ Line / Category │    costs are concentrated and    │
│ Break-   │ (Material, Mfg,  │                    │                 │    how they distribute across    │
│ down     │ Freight, Tax,    │                    │                 │    cost types, domains, and      │
│          │ Inventory Value) │                    │                 │    product lines                 │
│          ├──────────────────┼────────────────────┴─────────────────┤  • Use to prioritize cost        │
│          │ Cost by          │ Cost Distribution:                    │    reduction initiatives          │
│          │ Segment          │   Territory × Vendor × Facility      │                                  │
│          │ ( Intermediate ) │                                      │                                  │
└──────────┴──────────────────┴──────────────────────────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (aggregated from all fact tables + dimensions)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY          │
                    │ Product Category             │
                    │ SCM Domain (All / Specific)  │
                    │ Territory Group (Sales)      │
                    │ Vendor (Procurement)         │
                    │ Work Center (Manufacturing)  │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: SCM Scorecard — Headline KPIs

| Cell | Spec |
|------|------|
| **SCM Scorecard (Headline KPIs with YoY / MoM)** | KPI Cards — 6 headline metrics with delta indicators |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + fct_purchase + fct_workorder + fct_inventory |
| | **Sales:** `Revenue = SUM(line_total)` from fct_sale |
| | **Sales:** `Gross_Margin_% = (SUM(line_total) - SUM(standard_cost × order_qty)) / SUM(line_total) * 100` |
| | **Procurement:** `PO_Spend = SUM(order_total_due)` from fct_purchase |
| | **Procurement:** `Fulfillment_% = SUM(received_qty) / SUM(order_qty) * 100` from fct_purchase |
| | **Manufacturing:** `Yield_% = SUM(stocked_qty) / SUM(order_qty) * 100` from fct_workorder |
| | **Inventory:** `Inventory_Value = SUM(total_manufacture_value)` from fct_inventory |
| | Each KPI shows: Current Value, YoY %, MoM %, Trend Arrow (▲/▼) |

| Cell | Spec |
|------|------|
| **KPI Trend Sparklines** | 6 Sparkline mini-charts (one per KPI) |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly |
| | Source: all fact tables + dim_date |
| | One sparkline per headline KPI showing 12-month trend |
| | Dotted line: Prior Year same period for visual comparison |
| | 🟧 Toggle – YTD vs Rolling 12M |

---

### ROW 2: SCM Health Gauge & Period-over-Period

| Cell | Spec |
|------|------|
| **SCM Health Gauge (Composite Index)** | Gauge / Dial Chart |
| | Timeframe: Current Period |
| | Source: Composite of all domains |
| | `SCM_Index = Weighted average of normalized KPIs:` |
| |   `(0.30 × Revenue_Growth_YoY_normalized)` |
| |   `+ (0.20 × Yield_%_normalized)` |
| |   `+ (0.20 × Fulfillment_%_normalized)` |
| |   `+ (0.15 × (1 - Scrap_Rate)_normalized)` |
| |   `+ (0.15 × Inventory_Readiness_%_normalized)` |
| | Scale: 0–100 (🔴 < 60/🟡 60–80/🟢 > 80) |

| Cell | Spec |
|------|------|
| **Period-over-Period Comparison** | Table: YTD vs Prior YTD vs YoY Delta |
| | Timeframe: YTD vs Prior YTD |
| | Source: all fact tables + dim_date |
| | Rows: Each domain (Sales, Procurement, Manufacturing, Inventory) |
| | Columns: Key Metric, Current YTD, Prior YTD, YoY %, MoM % |
| | **Sales:** Revenue, GM%, AOV |
| | **Procurement:** Spend, Fulfillment%, Rejection% |
| | **Manufacturing:** Output, Yield%, Cost Variance% |
| | **Inventory:** Value, Dead Stock%, Readiness% |
| | 🟢 Improved / 🔴 Degraded (conditional formatting) |
| | 🟧 Toggle – YTD / QTD / MTD |

---

### ROW 3: YoY & MoM Variance by Domain

| Cell | Spec |
|------|------|
| **Performance vs Prior Year** | KPI Summary cards |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: all fact tables |
| | `Revenue_YoY = (Current_YTD - Prior_YTD) / Prior_YTD * 100` |
| | `Spend_YoY`, `Yield_YoY`, `Inventory_Value_YoY` |
| | Arrow indicators: ▲ improvement / ▼ degradation |

| Cell | Spec |
|------|------|
| **YoY Variance by Domain** | Grouped Bar Chart |
| | Timeframe: YTD vs Prior YTD |
| | Source: all fact tables + dim_date |
| | X-axis: Domain (Sales, Procurement, Manufacturing, Inventory) |
| | Bars: Key metric YoY % change |
| | Color: 🟢 Positive / 🔴 Negative |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Territory Group (Sales only) |

| Cell | Spec |
|------|------|
| **MoM Variance by Domain** | Grouped Bar Chart |
| | Timeframe: Current Month vs Prior Month |
| | Source: all fact tables + dim_date |
| | Same structure as YoY but month-over-month |
| | 🟥 Filter – Vendor (Procurement only) |
| | 🟥 Filter – Work Center (Manufacturing only) |

---

### ROW 4: SCM Funnel Flow

| Cell | Spec |
|------|------|
| **SCM Funnel Flow** | Funnel / Sankey Diagram |
| | Timeframe: YTD |
| | Source: fct_purchase + fct_workorder + fct_inventory + fct_sale |
| | Stages (left → right, connected by product_id): |
| |   **Procurement**: SUM(order_qty) from fct_purchase |
| |   **Manufacturing**: SUM(order_qty) from fct_workorder |
| |   **Inventory**: SUM(quantity) from fct_inventory (current snapshot) |
| |   **Sales**: SUM(order_qty) from fct_sale |
| | Drop-off between stages = waste/loss at each step |
| | `Procurement → Mfg gap = mfg input not covered by purchases` |
| | `Mfg → Inventory gap = scrapped_qty (yield loss)` |
| | `Inventory → Sales gap = unsold stock` |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Specific Product |

| Cell | Spec |
|------|------|
| **Funnel Stage KPI Trend** | Multi-metric Line Chart (4 lines, one per stage) |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly |
| | Source: all fact tables + dim_date |
| | **Procurement line**: Fulfillment_% per month |
| | **Manufacturing line**: Yield_% per month |
| | **Inventory line**: Readiness_% per month (% SKUs above reorder point) |
| | **Sales line**: Revenue Growth MoM % per month |
| | 🟧 Toggle – Absolute Values vs % |
| | 🟥 Filter – Product Category |

---

### ROW 5: Stage Efficiency & Cross-Domain Impact

| Cell | Spec |
|------|------|
| **Stage Efficiency Comparison** | Radar / Spider Chart |
| | Timeframe: Current YTD |
| | Source: all fact tables |
| | Axes (one per domain): |
| |   Procurement: Fulfillment % |
| |   Manufacturing: Yield % |
| |   Inventory: Readiness % |
| |   Sales: GM % |
| |   Cost: (1 - Cost_Variance_%) |
| | Two series: Current YTD vs Prior YTD |
| | 🟧 Toggle – Product Category |

| Cell | Spec |
|------|------|
| **Cross-Domain Impact Matrix** | Correlation Table / Heatmap |
| | Timeframe: Trailing 12 Months (monthly data points) |
| | Source: all fact tables aggregated by month |
| | Rows/Columns: Procurement Fulfillment, Mfg Yield, Inventory Turnover, Sales Revenue |
| | Values: Correlation coefficient or directional indicator |
| | Example insights: |
| |   "When Fulfillment drops → Mfg Yield also drops (0.72 correlation)" |
| |   "When Scrap rises → Inventory Readiness falls" |
| | 🟥 Filter – Product Category |

---

### ROW 6: Total SCM Cost by Type & Domain

| Cell | Spec |
|------|------|
| **Total SCM Cost by Type** | Headline Number + Donut Chart |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase + fct_workorder + fct_inventory + fct_sale |
| | **Material Cost** = SUM(line_total) from fct_purchase |
| | **Manufacturing Cost** = SUM(total_actual_cost) from fct_workorder |
| | **Sales Freight** = SUM(order_freight_amount) from fct_sale |
| | **Purchase Freight** = SUM(order_freight_amount) from fct_purchase |
| | **Tax** = SUM(order_tax_amount) from fct_sale + fct_purchase |
| | **Inventory Value** = SUM(total_manufacture_value) from fct_inventory |
| | `Total_SCM_Cost = Material + Manufacturing + Total Freight + Tax` |
| | `Inv_Capital_Tied = Inventory Value (not a P&L cost, but capital at risk)` |

| Cell | Spec |
|------|------|
| **Cost Breakdown by Domain & Trend** | Stacked Area Chart |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly Total |
| | Source: fct_purchase + fct_workorder + fct_sale + dim_date |
| | Stacks: Material (purchase), Manufacturing (workorder), Freight, Tax |
| | 🟧 Toggle – Stacked vs Unstacked |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Territory Group |

| Cell | Spec |
|------|------|
| **Cost by Product Line / Category** | Table with Trend Sparklines |
| | Timeframe: YTD |
| | Source: all fact tables + dim_product |
| | Columns: Category, Material $, Mfg $, Freight $, Total $, % of Grand Total, YoY % |
| | Sorted by Total $ descending |
| | 🟧 Toggle – Category vs Subcategory |

---

### ROW 7: Cost Distribution by Segment

| Cell | Spec |
|------|------|
| **Cost by Segment** | KPI Cards |
| | Timeframe: Point-in-Time |
| | Source: all fact tables |
| | `Cost_Per_Revenue_$ = Total_SCM_Cost / Revenue` (cost efficiency ratio) |
| | `Freight_as_%_Revenue = Total_Freight / Revenue * 100` |
| | `Mfg_Cost_Per_Unit = SUM(total_actual_cost) / SUM(stocked_qty)` |

| Cell | Spec |
|------|------|
| **Cost Distribution: Territory × Vendor × Facility** | Treemap / Nested Breakdown |
| | Timeframe: YTD |
| | Source: fct_sale (territory), fct_purchase (vendor), fct_workorder_routing (workcenter) |
| | Level 1: Cost Domain (Sales/Procurement/Manufacturing) |
| | Level 2a (Sales): Territory Group → Country |
| | Level 2b (Procurement): Top Vendors (Pareto-weighted) |
| | Level 2c (Manufacturing): Work Center |
| | Size: Cost $ |
| | Color: YoY change (🟢 decreased / 🔴 increased) |
| | 🟧 Toggle – By Domain / By Product |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Vendor |
| | 🟥 Filter – Work Center |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Product Category        │
  (e.g., by domain, territory, vendor, facility)          │  SCM Domain              │
                                                          │  Territory Group (Sales) │
  Each KPI card navigates to its dedicated                │  Vendor (Procurement)    │
  domain dashboard on click                               │  Work Center (Mfg.)      │
                                                          └──────────────────────────┘
  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────────────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ SCM Scorecard                                             │  │ KPI Trend Sparklines           │ │
│  │                                                           │  │ (Trailing 12 Months)           │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                     │  │                                │ │
│  │  │REVENUE  │ │PO SPEND │ │YIELD    │                     │  │  Revenue   ──────●──●──●  ▲7%  │ │
│  │  │ $45.2M  │ │ $12.8M  │ │ 97.2%   │                     │  │  PO Spend  ──●──●──●──── ▼2%  │ │
│  │  │ ▲ +7%   │ │ ▼ -2%   │ │ ▲ +1.1% │                     │  │  Yield     ────────●──●  ▲1%  │ │
│  │  │  YoY    │ │  YoY    │ │  YoY    │                     │  │  Fill Rate ──●──●──●──● ▲3%   │ │
│  │  └─────────┘ └─────────┘ └─────────┘                     │  │  Scrap     ────●──●──── ▼0.5% │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                     │  │  Inv Value ──●──●──●─── ▲4%   │ │
│  │  │FULFILL  │ │SCRAP    │ │INV VALUE│                     │  │                                │ │
│  │  │ 94.5%   │ │ 2.8%    │ │ $5.2M   │                     │  │  ── Current  ‥‥ Prior Year     │ │
│  │  │ ▲ +3%   │ │ ▼ -0.5% │ │ ▲ +4%   │                     │  │                                │ │
│  │  │  YoY    │ │  YoY    │ │  YoY    │                     │  │  🟧 Toggle - YTD / Rolling 12M │ │
│  │  └─────────┘ └─────────┘ └─────────┘                     │  │                                │ │
│  └───────────────────────────────────────────────────────────┘  └────────────────────────────────┘ │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────────────────┐   │
│  │ SCM Health Gauge          │  │  Period-over-Period Comparison                                │   │
│  │                           │  │                                                              │   │
│  │       ╭────────╮         │  │  Domain        │ Key Metric    │ YTD    │ Prior │ YoY   │ MoM │   │
│  │     ╱   78/100   ╲       │  │  ─────────────┼───────────────┼────────┼───────┼───────┼──── │   │
│  │    ╱     🟢       ╲      │  │  Sales        │ Revenue       │ $45.2M │$42.2M │ +7% 🟢│ +2% │   │
│  │   ╱    "Good"      ╲     │  │  Sales        │ GM%           │ 40.1%  │ 38.8% │+1.3pp🟢│+0.2%│   │
│  │   ╲                ╱     │  │  Procurement  │ Spend         │ $12.8M │$13.1M │ -2% 🟢│ -1% │   │
│  │    ╲              ╱      │  │  Procurement  │ Fulfillment%  │ 94.5%  │ 91.8% │ +3% 🟢│ +1% │   │
│  │     ╲────────────╱       │  │  Manufacturing│ Yield%        │ 97.2%  │ 96.1% │+1.1%🟢│+0.3%│   │
│  │                           │  │  Manufacturing│ Cost Var%     │ +4.8%  │ +5.2% │-0.4pp🟢│-0.1%│   │
│  │  🔴 < 60  🟡 60-80       │  │  Inventory    │ Value         │ $5.2M  │ $5.0M │ +4% 🟡│ +1% │   │
│  │  🟢 > 80                  │  │  Inventory    │ Dead Stock%   │ 7.6%   │ 8.2%  │-0.6pp🟢│-0.1%│   │
│  │                           │  │                                                              │   │
│  │                           │  │  🟧 Toggle - YTD / QTD / MTD                                 │   │
│  └───────────────────────────┘  └──────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Performance vs Prior Year │  │  YoY Variance by Domain     │  │ MoM Variance by Domain         │ │
│  │                           │  │                              │  │                                │ │
│  │  Revenue:    +$3.0M ▲    │  │   ██ YoY %                   │  │   ██ MoM %                     │ │
│  │  PO Spend:   -$0.3M ▼    │  │                              │  │                                │ │
│  │  Yield:     +1.1pp  ▲    │  │  Sales    ████████  +7%      │  │  Sales    ████  +2%            │ │
│  │  Inv Value: +$0.2M  ▲    │  │  Procure  ████     -2% 🟢   │  │  Procure  ██   -1% 🟢         │ │
│  │                           │  │  Mfg      ██████   +1%      │  │  Mfg      ███  +0.3%          │ │
│  │  🟢 = Improved           │  │  Inv      █████    +4%      │  │  Inv      ██   +1%            │ │
│  │  🔴 = Degraded           │  │                              │  │                                │ │
│  │                           │  │  🟧 Toggle - Prod Category   │  │  🟥 Filter - Vendor / WC      │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────────────────────────┐  ┌──────────────────────────────────────────┐   │
│  │ SCM Funnel Flow                                │  │ Funnel Stage KPI Trend                   │   │
│  │                                                │  │                                          │   │
│  │  Procurement   Manufacturing   Inventory  Sales│  │  ── Fulfillment%  ── Yield%              │   │
│  │                                                │  │  ── Readiness%    ── Revenue Growth MoM  │   │
│  │  ┌─────────┐  ┌─────────┐  ┌────────┐  ┌────┐│  │                                          │   │
│  │  │ PO Qty  │  │ WO Qty  │  │ Stock  │  │Sale││  │  100%┌─────────────────────────────────┐ │   │
│  │  │ 85,000  │→│ 72,500  │→│ 39,200 │→│Sold ││  │      │ ●──●──●──●──●──●──●──●──●     │ │   │
│  │  │         │  │         │  │        │  │31K  ││  │   95%│     ○──○──○──○──○──○──○──○   │ │   │
│  │  └─────────┘  └─────────┘  └────────┘  └────┘│  │      │  △──△──△──△──△──△──△──△──△   │ │   │
│  │  Fulfil: 94%  Yield: 97%  Ready: 82%  GM: 40%│  │   90%│                                 │ │   │
│  │                                                │  │      │  □──□──□──□──□──□──□──□──□     │ │   │
│  │  Drop: -5.5%   Drop: -2.8%  Drop: -18%       │  │   85%└─────────────────────────────────┘ │   │
│  │                                                │  │      M1  M2  M3  M4  M5  M6  M7  M8  M9│   │
│  │  🟧 Toggle - Product Category                  │  │                                          │   │
│  └───────────────────────────────────────────────┘  │  🟧 Toggle - Absolute / %                │   │
│                                                      │  🟥 Filter - Product Category             │   │
│                                                      └──────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌───────────────────────────────────────────────┐  ┌──────────────────────────────────────────┐   │
│  │ Stage Efficiency Comparison (Radar)            │  │ Cross-Domain Impact Matrix               │   │
│  │                                                │  │                                          │   │
│  │         Fulfillment%                           │  │              │ Fulfill │ Yield │ Turn. │ Rev│   │
│  │            94.5                                │  │  ────────────┼─────────┼───────┼───────┼───│   │
│  │           ╱    ╲                               │  │  Fulfillment │    —    │  ↑↑   │  ↑    │ ↑ │   │
│  │    Cost ╱        ╲ Yield                       │  │  Yield       │   ↑↑   │   —   │  ↑↑   │ ↑↑│   │
│  │   95.2 ╱  ╱──●──╲ ╲ 97.2                      │  │  Turnover    │    ↑   │  ↑↑   │   —   │ ↑ │   │
│  │       ╱──╱ ‥‥‥‥‥ ╲──╲                         │  │  Revenue     │    ↑   │  ↑↑   │  ↑    │  — │   │
│  │  Ready ──────────── GM%                        │  │                                          │   │
│  │   82.0              40.1                       │  │  ↑↑ Strong positive  ↑ Moderate positive │   │
│  │                                                │  │  ↓↓ Strong negative  ↓ Moderate negative │   │
│  │  ── Current YTD   ‥‥ Prior YTD                │  │                                          │   │
│  │  🟧 Toggle - Product Category                  │  │  🟥 Filter - Product Category             │   │
│  └───────────────────────────────────────────────┘  └──────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Total SCM Cost by Type    │  │  Cost Breakdown by Domain   │  │ Cost by Product Line           │ │
│  │                           │  │  & Trend                    │  │                                │ │
│  │  $32.5M Total SCM Cost   │  │                              │  │  Category │ Mat$  │Mfg$ │Total│ │
│  │  +$1.2M | +3.8% YoY     │  │  ██ Material ██ Mfg         │  │  ─────────┼───────┼─────┼─────│ │
│  │                           │  │  ██ Freight  ██ Tax         │  │  Bikes    │$5.2M  │$1.6M│$7.8M│ │
│  │  ┌──────────────────┐    │  │                              │  │  Comp.    │$4.1M  │$0.8M│$5.5M│ │
│  │  │ ████ Material 39%│    │  │  $4M┌────────────────────┐  │  │  Cloth.   │$2.3M  │$0.3M│$2.9M│ │
│  │  │ ███  Mfg.    22% │    │  │     │████████████████████│  │  │  Access.  │$1.2M  │$0.1M│$1.5M│ │
│  │  │ ██   Freight 18% │    │  │  $2M│████  ████  ████    │  │  │  ...                          │ │
│  │  │ █    Tax     10% │    │  │     │████  ████  ████    │  │  │                                │ │
│  │  │ █    Inv Cap 11% │    │  │  $0 │────────────────────│  │  │  % column + sparkline trend    │ │
│  │  └──────────────────┘    │  │     M1  M3  M5  M7  M9   │  │  │                                │ │
│  │                           │  │                              │  │  🟧 Toggle - Cat / SubCat     │ │
│  │  ⓘ Inv Cap = capital tied│  │  🟧 Toggle - Stack/Unstack   │  │                                │ │
│  │  not operational cost     │  │  🟧 Toggle - Prod Category   │  │                                │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Cost Efficiency Ratios    │  │  Cost Distribution: Territory × Vendor × Facility            │   │
│  │                           │  │                                                              │   │
│  │  $0.72                    │  │  ┌──────────────────────────────────────────────────────────┐│   │
│  │  Cost per Revenue $       │  │  │ SALES COST                                              ││   │
│  │  (Prior: $0.74) 🟢       │  │  │ ┌──────────┐ ┌────────┐ ┌──────┐ ┌────┐               ││   │
│  │                           │  │  │ │   NA     │ │  EU    │ │Pacific│ │... │               ││   │
│  │  4.1%                     │  │  │ │  $18.2M  │ │ $9.5M  │ │$5.1M │ │    │               ││   │
│  │  Freight as % Revenue     │  │  │ └──────────┘ └────────┘ └──────┘ └────┘               ││   │
│  │  (Prior: 4.3%) 🟢        │  │  ├──────────────────────────────────────────────────────────┤│   │
│  │                           │  │  │ PROCUREMENT COST                                        ││   │
│  │  $40.50                   │  │  │ ┌──────────┐ ┌────────┐ ┌──────┐ ┌────┐               ││   │
│  │  Mfg Cost Per Unit        │  │  │ │ Vendor A │ │Vendor B│ │Vend C│ │... │               ││   │
│  │  (Prior: $38.70) 🔴      │  │  │ │  $2.1M   │ │ $1.8M  │ │$1.2M │ │    │               ││   │
│  │                           │  │  │ └──────────┘ └────────┘ └──────┘ └────┘               ││   │
│  │                           │  │  ├──────────────────────────────────────────────────────────┤│   │
│  │                           │  │  │ MANUFACTURING COST                                      ││   │
│  │                           │  │  │ ┌──────────┐ ┌────────┐ ┌──────┐ ┌────┐               ││   │
│  │                           │  │  │ │Frame Weld│ │ Paint  │ │SubAsm│ │... │               ││   │
│  │                           │  │  │ │  $0.8M   │ │ $0.5M  │ │$0.4M │ │    │               ││   │
│  │                           │  │  │ └──────────┘ └────────┘ └──────┘ └────┘               ││   │
│  │                           │  │  └──────────────────────────────────────────────────────────┘│   │
│  │                           │  │  Color: 🟢 YoY decreased  🔴 YoY increased                  │   │
│  │                           │  │  🟧 Toggle - By Domain / By Product                          │   │
│  │                           │  │  🟥 Filter - Territory | Vendor | Work Center               │   │
│  └───────────────────────────┘  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role | Domain |
|-------|------|--------|
| `fct_sale` | Fact – grain: order line item | Sales |
| `fct_purchase` | Fact – grain: PO line item | Procurement |
| `fct_workorder` | Fact – grain: work order | Manufacturing |
| `fct_workorder_routing` | Fact – grain: WO operation step | Manufacturing (cost by work center) |
| `fct_inventory` | Fact – grain: product × location (snapshot) | Inventory |
| `fct_inventory_daily_snapshot` | Fact – grain: product × date | Inventory (trending) |
| `fct_transaction` | Fact – grain: transaction | Inventory (turnover) |
| `dim_product` | Product hierarchy, standard_cost, list_price | All domains |
| `dim_sales_territory` | Territory, country, territory_group | Sales cost segmentation |
| `dim_vendor` | Vendor name, credit_rating | Procurement cost segmentation |
| `dim_workcenter` | Location name, cost_rate | Manufacturing cost segmentation |
| `dim_date` | Calendar hierarchy, date_key | All domains (trending) |
| `dim_ship_method` | Ship method, ship_base, ship_rate | Freight analysis |

### **Key Fields by Domain**
| Domain | KPI | Source | Fields |
|--------|-----|--------|--------|
| Sales | Revenue | fct_sale | `SUM(line_total)` |
| Sales | Gross Margin | fct_sale + dim_product | `SUM(line_total) - SUM(standard_cost × order_qty)` |
| Sales | AOV | fct_sale | `SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| Sales | Freight | fct_sale | `SUM(order_freight_amount)` |
| Procurement | Spend | fct_purchase | `SUM(order_total_due)` |
| Procurement | Fulfillment % | fct_purchase | `SUM(received_qty) / SUM(order_qty) * 100` |
| Procurement | Rejection % | fct_purchase | `SUM(rejected_qty) / SUM(received_qty) * 100` |
| Procurement | Freight | fct_purchase | `SUM(order_freight_amount)` |
| Manufacturing | Yield % | fct_workorder | `SUM(stocked_qty) / SUM(order_qty) * 100` |
| Manufacturing | Scrap Rate | fct_workorder | `SUM(scrapped_qty) / SUM(order_qty) * 100` |
| Manufacturing | Cost Variance | fct_workorder | `SUM(cost_variance)`, `cost_variance_pct` |
| Manufacturing | Cost Per Unit | fct_workorder | `SUM(total_actual_cost) / SUM(stocked_qty)` |
| Inventory | Value | fct_inventory | `SUM(total_manufacture_value)` |
| Inventory | Dead Stock % | fct_inventory | `COUNT(Dead Stock) / COUNT(*) * 100` |
| Inventory | Readiness % | fct_inventory | `COUNT(stock_level IN (Mid,High)) / COUNT(*) * 100` |
| Inventory | Turnover | fct_transaction + snapshot | `COGS_Proxy / Avg_Inventory` |

### **Key Calculations**
```sql
-- ============================================================
-- SCORECARD HEADLINE KPIs
-- ============================================================

-- Sales
Revenue          = SUM(line_total) FROM fct_sale
Gross_Margin     = SUM(line_total) - SUM(p.standard_cost * s.order_qty)
GM_%             = Gross_Margin / Revenue * 100

-- Procurement
PO_Spend         = SUM(order_total_due) FROM fct_purchase
Fulfillment_%    = SUM(received_qty) / SUM(order_qty) * 100

-- Manufacturing
Yield_%          = SUM(stocked_qty) / SUM(order_qty) * 100 FROM fct_workorder
Scrap_Rate       = SUM(scrapped_qty) / SUM(order_qty) * 100

-- Inventory
Inv_Value        = SUM(total_manufacture_value) FROM fct_inventory
Readiness_%      = COUNT(CASE WHEN stock_level_status IN ('Mid','High') THEN 1 END)
                   / COUNT(*) * 100

-- ============================================================
-- PERIOD-OVER-PERIOD (Prior Period via dim_date)
-- ============================================================
YoY_%            = (Current_YTD - Prior_YTD) / Prior_YTD * 100
MoM_%            = (Current_Month - Prior_Month) / Prior_Month * 100
-- Apply per-metric, per-domain

-- ============================================================
-- SCM HEALTH COMPOSITE INDEX (0-100)
-- ============================================================
-- Normalize each metric to 0-100 scale, then weighted average:
SCM_Index =   0.30 * normalize(Revenue_Growth_YoY, min=-20, max=+20)
            + 0.20 * normalize(Yield_%, min=85, max=100)
            + 0.20 * normalize(Fulfillment_%, min=80, max=100)
            + 0.15 * normalize(100 - Scrap_Rate, min=90, max=100)
            + 0.15 * normalize(Readiness_%, min=60, max=100)

-- ============================================================
-- TOTAL SCM COST BREAKDOWN
-- ============================================================
Material_Cost    = SUM(line_total) FROM fct_purchase
Manufacturing_Cost = SUM(total_actual_cost) FROM fct_workorder
Sales_Freight    = SUM(order_freight_amount) FROM fct_sale
Purchase_Freight = SUM(order_freight_amount) FROM fct_purchase
Total_Freight    = Sales_Freight + Purchase_Freight
Total_Tax        = SUM(order_tax_amount) FROM fct_sale + SUM(order_tax_amount) FROM fct_purchase
Total_SCM_Cost   = Material_Cost + Manufacturing_Cost + Total_Freight + Total_Tax
Inv_Capital_Tied = SUM(total_manufacture_value) FROM fct_inventory  -- separate (not P&L cost)

-- Cost Efficiency Ratios
Cost_Per_Revenue = Total_SCM_Cost / Revenue
Freight_as_%_Rev = Total_Freight / Revenue * 100
Mfg_CPU          = SUM(total_actual_cost) / SUM(stocked_qty) FROM fct_workorder

-- ============================================================
-- SCM FUNNEL (aggregate by product_id across domains)
-- ============================================================
Procurement_Qty  = SUM(order_qty) FROM fct_purchase   GROUP BY product_id
Manufacturing_Qty = SUM(order_qty) FROM fct_workorder GROUP BY product_id
Inventory_Qty    = SUM(quantity) FROM fct_inventory   GROUP BY product_id
Sales_Qty        = SUM(order_qty) FROM fct_sale       GROUP BY product_id

-- Drop-off at each stage:
Mfg_Yield_Loss   = SUM(scrapped_qty) FROM fct_workorder
Inventory_Unsold = Inventory_Qty - Sales_Qty  -- (simplified)

-- ============================================================
-- COST DISTRIBUTION (for Treemap)
-- ============================================================
-- Sales cost by territory:
Sales_Cost_by_Territory = SUM(order_freight_amount + order_tax_amount)
                          FROM fct_sale GROUP BY territory_group

-- Procurement cost by vendor:
Procurement_by_Vendor = SUM(line_total) FROM fct_purchase
                        JOIN dim_vendor GROUP BY vendor_name

-- Manufacturing cost by facility:
Mfg_by_Facility = SUM(actual_cost) FROM fct_workorder_routing
                   JOIN dim_workcenter GROUP BY location_name

-- ============================================================
-- CONDITIONAL FORMATTING
-- ============================================================
-- Scorecard: 🟢 Improved YoY | 🔴 Degraded YoY
-- Health Gauge: 🔴 < 60 | 🟡 60-80 | 🟢 > 80
-- Cost Variance: 🟢 Under prior period | 🔴 Over prior period
```
