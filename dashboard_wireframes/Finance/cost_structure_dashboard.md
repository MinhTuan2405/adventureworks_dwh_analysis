# Cost Structure & Control Dashboard

**Overall Objective:** Decompose all production-related costs (COGS, manufacturing, freight, tax, scrap loss) by component, track their trends over time, identify where cost variances concentrate (by product, work center, vendor), and monitor the cost-to-revenue ratio to detect cost creep early.

---

## BUSINESS QUESTIONS ADDRESSED

1. What is the total cost breakdown by major cost components (COGS, manufacturing, freight, tax, scrap loss), and how is each component trending over time?
2. Where are the largest cost variances occurring — which products, work centers, or vendors are driving costs above expected levels?
3. What is the cost-to-revenue ratio trend, and are production-related costs (COGS, manufacturing, freight) growing faster than revenue?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  Cost Structure & Control Dashboard                                   │
│                                                                                                      │
│  Drill-down from Financial Overview (#1);                                                            │
│  complements SCM Cost Deep Dive (operational lens) with a financial lens                             │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Cost KPI Cards  │ Cost Component Trend                 │                                   │
│          │                 │   (Stacked Area)                     │  • Headline cost snapshot:         │
│  Total   │  Total Cost     │                                      │    total cost size + direction     │
│  Cost    │  COGS           │   COGS + Manufacturing + Freight     │  • Stacked area shows absolute    │
│ Summary  │  Mfg Cost       │   + Tax + Scrap Loss                 │    growth and composition shift    │
│          │  Freight+Tax    │   + Prior Year overlay               │  • KPIs include YoY% delta &      │
│          │  Scrap Loss     │                                      │    % of Revenue for each           │
│          │  + YoY & % Rev  │                                      │    component                       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Manufacturing   │ Cost Variance Breakdown by           │                                   │
│  Cost    │ Cost Variance   │ Dimension                            │  • Planned vs Actual cost gap —    │
│ Variance │ Summary         │                                      │    which dimension drives it?       │
│ Analysis │                 │   By Product Category (Treemap)      │  • Product treemap shows where     │
│          │  Total Variance │   By Work Center (Horizontal Bar)    │    cost overruns concentrate        │
│          │  Variance %     │   By Vendor (Top 10 Bar)             │  • Work center + vendor breakdowns │
│          │  Overrun Count  │                                      │    pinpoint operational root causes │
│          │  + YoY trend    │                                      │                                   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Cost-to-Revenue │ Component Growth Rate Comparison     │                                   │
│ Cost vs  │ Ratio Trend     │                                      │  • Is cost growing faster than     │
│ Revenue  │                 │   Indexed Growth (Base 100) over     │    revenue? → cost creep alert     │
│  Creep   │  Line chart:    │   time for:                          │  • Indexed comparison normalizes   │
│          │  Cost/Revenue%  │   Revenue, COGS, Mfg, Freight        │    different scales — all start    │
│          │  + target line  │   + Revenue as reference line        │    at 100 to show relative speed   │
│          │  + YoY delta    │                                      │  • Gap widening = cost creep       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Cost Component  │ Cost Detail Table                    │                                   │
│  Detail  │ Waterfall       │                                      │  • Waterfall visualizes flow from  │
│  Break-  │                 │   Monthly: Component | Amount |      │    Revenue → each cost deduction   │
│  down    │  Revenue →      │   % of Rev | MoM% | YoY% |          │  • Full sortable detail table      │
│          │  COGS →         │   Variance                           │    for monthly drill and export     │
│          │  Mfg → Freight  │                                      │  • Waterfall links this dashboard  │
│          │  → Tax → Scrap  │                                      │    to Financial Overview P&L view  │
│          │  → Net Proxy    │                                      │                                   │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (from fct_sale + fct_workorder + fct_workorder_routing + fct_purchase + dim_product)
- ◻ Intermediate metric (derived from multiple fact tables)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default shows YTD with monthly granularity.

```
Global Filters:     │ Timeframe: XX - YY            │
                    │ Product Category / Subcategory │
                    │ Cost Component (All / Specific)│
                    │ Sales Channel                  │
                    │ Work Center                    │
                    │ Vendor                         │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Cost KPI Cards + Cost Component Trend

| Cell | Spec |
|------|------|
| **Cost KPI Cards** | 5 Headline Cards with YoY% and % of Revenue |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase |
| | **Card 1 — Total Production Cost**: COGS + Mfg + Freight + Tax + Scrap |
| | **Card 2 — COGS**: `SUM(dim_product.standard_cost × fct_sale.order_qty)` |
| | **Card 3 — Manufacturing Cost**: `SUM(fct_workorder.total_actual_cost)` |
| | **Card 4 — Freight + Tax**: Sales Freight (dedup) + Sales Tax (dedup) + PO Freight (dedup) + PO Tax (dedup) |
| | **Card 5 — Scrap Loss**: `SUM(fct_workorder.scrapped_qty × dim_product.standard_cost)` |
| | Each card: Amount | YoY% | % of Revenue | Sparkline (last 12M) |

| Cell | Spec |
|------|------|
| **Cost Component Trend (Stacked Area)** | Stacked Area Chart + Prior Year Overlay |
| | Timeframe: Full Range (multi-year) |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase + dim_date |
| | Stacks: ██ COGS ██ Manufacturing ██ Freight ██ Tax ██ Scrap Loss |
| | Dashed overlay: Prior Year total cost trendline |
| | 🟧 Toggle – Stacked vs Unstacked view |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Work Center |

---

### ROW 2: Manufacturing Cost Variance Summary + Variance by Dimension

| Cell | Spec |
|------|------|
| **Manufacturing Cost Variance Summary** | KPI Cards + Mini Trend Line |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_workorder + fct_workorder_routing |
| | **Total Planned Cost**: `SUM(fct_workorder.total_planned_cost)` |
| | **Total Actual Cost**: `SUM(fct_workorder.total_actual_cost)` |
| | **Total Variance**: `SUM(fct_workorder.cost_variance)` (positive = overrun) |
| | **Variance %**: `SUM(cost_variance) / SUM(total_planned_cost) × 100` |
| | **Overrun Count**: `COUNT(*) WHERE cost_variance > 0` |
| | **Underrun Count**: `COUNT(*) WHERE cost_variance < 0` |
| | Mini line chart: Monthly variance trend (trailing 12M) |
| | Color: Red if total variance > 0 (overrun), Green if < 0 (underrun) |

| Cell | Spec |
|------|------|
| **Cost Variance by Dimension** | 3 Sub-Charts — Treemap + Horizontal Bar + Horizontal Bar |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | **Sub-chart A — By Product Category (Treemap)** |
| | Source: fct_workorder + dim_product |
| | Size: `ABS(SUM(cost_variance))` per `product_category_name` |
| | Color: Green (underrun) → Red (overrun) by `cost_variance_pct` |
| | Drill-down: Category → Subcategory → Product |
| | **Sub-chart B — By Work Center (Horizontal Bar)** |
| | Source: fct_workorder_routing + dim_workcenter |
| | Bars: `SUM(cost_variance)` per `workcenter_name`, sorted by variance desc |
| | Color: Positive = red, Negative = green |
| | Tooltip: Planned Cost, Actual Cost, Variance %, Resource Hrs |
| | **Sub-chart C — By Vendor (Top 10 Horizontal Bar)** |
| | Source: fct_purchase + dim_vendor |
| | Metric: `Unit Price Variance = AVG(current_unit_price) − AVG(prior_unit_price)` per vendor |
| | Or: `Price Change % = (AVG(unit_price_current) − AVG(unit_price_prior)) / AVG(unit_price_prior) × 100` |
| | Top 10 vendors by absolute price change, sorted desc |
| | Color coding: preferred_vendor = blue border |
| | 🟧 Toggle – Sub-chart view (Treemap / Bar / Bar) |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Variance direction (Overrun only / Underrun only / All) |

---

### ROW 3: Cost-to-Revenue Ratio Trend + Component Growth Rate Comparison

| Cell | Spec |
|------|------|
| **Cost-to-Revenue Ratio Trend** | Line Chart + Target Reference Line |
| | Timeframe: Full Range |
| | Measurement Range: Monthly |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase + dim_date |
| | Primary line: `Cost_to_Revenue_% = Total_Production_Cost / Revenue × 100` |
| | Secondary line: `COGS_to_Revenue_% = COGS / Revenue × 100` (largest component) |
| | Reference line: Prior Year average ratio (dashed horizontal) |
| | Annotation: Alert zones — flag months where ratio > PY average + 2pp |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |

| Cell | Spec |
|------|------|
| **Component Growth Rate Comparison (Indexed)** | Multi-Line Chart, Base = 100 |
| | Timeframe: Full Range |
| | Measurement Range: Quarterly (to smooth noise) |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase + dim_date |
| | Lines (all indexed to 100 at first period): |
| | — ██ Revenue (reference, bold) |
| | — ── COGS growth |
| | — ── Manufacturing Cost growth |
| | — ── Freight growth |
| | — ── Scrap Loss growth |
| | `Index_Q = (Value_Q / Value_Q1) × 100` |
| | Insight: If a cost line grows faster than Revenue line → cost creep for that component |
| | Annotation: highlight gap widening between cost line and revenue line |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |

---

### ROW 4: Cost Component Waterfall + Cost Detail Table

| Cell | Spec |
|------|------|
| **Cost Component Waterfall** | Waterfall Chart (Vertical) |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase |
| | Bars: |
| | — Revenue (green, start) |
| | — COGS (red, decrease) |
| | — **Gross Profit** (blue, subtotal) |
| | — Manufacturing Cost (red, decrease) |
| | — Sales Freight (red, decrease) |
| | — Sales Tax (red, decrease) |
| | — Scrap Loss (red, decrease) |
| | — **Net Proxy** (blue, subtotal end) |
| | Each bar label: Amount + % of Revenue |
| | 🟧 Toggle – Sales Channel |
| | 🟧 Toggle – Period (YTD / Quarterly / Monthly) |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Cost Detail Table** | Full Detail Table; Sortable; Exportable |
| | Timeframe: Full Range |
| | Measurement Range: Monthly |
| | Source: fct_sale + dim_product + fct_workorder + fct_purchase + dim_date |
| | Columns: Year-Month | Revenue | COGS | Mfg Cost | Freight | Tax | Scrap | Total Cost | Cost/Rev % | MoM Chg % | YoY Chg % |
| | Features: |
| | — Sortable by any column |
| | — Conditional formatting on Cost/Rev%: green < 60%, yellow 60-65%, red > 65% |
| | — Subtotal rows per Quarter and Year |
| | — Sparkline column for Cost/Rev% trend |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Work Center |
| | Export: CSV / Excel |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Product Category         │
  (e.g., specific cost component, variance)               │  Cost Component           │
                                                          │  Sales Channel            │
  Drill-through to SCM Cost Deep Dive for                 │  Work Center              │
  operational cost detail; to Procurement (#6)             │  Vendor                   │
  for vendor spend detail                                 └──────────────────────────┘

  Legend:                                                      
  🟧 Filters for "Crawl"                                       
  🟥 Filters for "Walk/Run"                                     

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: TOTAL COST SUMMARY                                                              Q1         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Cost KPI Cards                           │  │  Cost Component Trend (Stacked Area)             │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐   │  │  ██ COGS  ██ Manufacturing  ██ Freight           │ │
│  │  │  Total  │ │  COGS   │ │   Mfg   │   │  │  ██ Tax   ██ Scrap Loss    ┈┈ PY Total          │ │
│  │  │ ProdCost│ │         │ │  Cost   │   │  │                                                  │ │
│  │  │ $33.4M  │ │ $27.1M  │ │ $4.2M   │   │  │ $5M ┌──────────────────────────────────┐        │ │
│  │  │ +5% YoY │ │ +4% YoY │ │ +8% YoY │   │  │     │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│        │ │
│  │  │ 73.9%Rev│ │ 59.9%Rev│ │ 9.3%Rev │   │  │     │ ████████████████████████████████│        │ │
│  │  │ ~~~~~~  │ │ ~~~~~~  │ │ ~~~~~~  │   │  │     │ ████████████████████████████████│        │ │
│  │  └─────────┘ └─────────┘ └─────────┘   │  │     │ ████████████████████████████████│        │ │
│  │  ┌──────────────┐ ┌──────────────┐      │  │     │ ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈│        │ │
│  │  │ Freight+Tax  │ │ Scrap Loss   │      │  │ $0  └──────────────────────────────────┘        │ │
│  │  │    $1.9M     │ │    $0.2M     │      │  │     Jan  Feb  Mar  Apr  May  Jun  Jul  Aug      │ │
│  │  │  +6% YoY     │ │  -5% YoY     │      │  │                                                  │ │
│  │  │  4.2% Rev    │ │  0.4% Rev    │      │  │     🟧 Toggle – Stacked / Unstacked              │ │
│  │  │  ~~~~~~      │ │  ~~~~~~      │      │  │                                                  │ │
│  │  └──────────────┘ └──────────────┘      │  │                                                  │ │
│  │                                          │  │                                                  │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Product Category | Work Center          │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: COST VARIANCE ANALYSIS                                                          Q2         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Mfg Cost Variance Summary                │  │ Cost Variance by Dimension                       │ │
│  │                                          │  │                                                  │ │
│  │  Total Planned     Total Actual          │  │ ┌─ A: By Product Category (Treemap) ──────────┐ │ │
│  │  $3.9M             $4.2M                 │  │ │ ┌──────────┐ ┌──────┐ ┌──────┐ ┌────┐      │ │ │
│  │           ┌──────────────────┐           │  │ │ │ Bikes    │ │Compo-│ │Cloth-│ │Acc │      │ │ │
│  │  Variance │ ██████████████   │ +$0.3M    │  │ │ │ +$220K   │ │nents │ │ ing  │ │-5K │      │ │ │
│  │  %        │ ████████████     │  +7.7%    │  │ │ │ ██ RED   │ │+$60K │ │+$15K │ │GRN │      │ │ │
│  │           └──────────────────┘           │  │ │ └──────────┘ └──────┘ └──────┘ └────┘      │ │ │
│  │                                          │  │ └────────────────────────────────────────────┘ │ │
│  │  Overrun WO: 2,847 (68%)                │  │                                                  │ │
│  │  Underrun WO: 1,340 (32%)               │  │ ┌─ B: By Work Center (Bar) ───────────────────┐ │ │
│  │                                          │  │ │ Frame Welding  ███████████████████  +$95K    │ │ │
│  │  Monthly Variance Trend:                 │  │ │ Paint Shop     ████████████████    +$72K    │ │ │
│  │  +$40K ┌──────────────────┐              │  │ │ Assembly       ███████████         +$48K    │ │ │
│  │        │  ●──●──●──●──●── │              │  │ │ Machining      ██████              +$33K    │ │ │
│  │   $0   │──────────────────│              │  │ │ Sub-Assembly   ████ (green)        -$18K    │ │ │
│  │  -$20K │──────────────────│              │  │ └────────────────────────────────────────────┘ │ │
│  │        Jan   Apr   Jul   Oct             │  │                                                  │ │
│  │                                          │  │ ┌─ C: By Vendor Price Change (Top 10) ────────┐ │ │
│  │                                          │  │ │ Vendor A       ████████████████    +12.3%   │ │ │
│  │                                          │  │ │ Vendor B       ██████████████      +10.1%   │ │ │
│  │                                          │  │ │ Vendor C       ██████████          + 7.5%   │ │ │
│  │                                          │  │ │ ...            ...                           │ │ │
│  │                                          │  │ │ Vendor J ████ (green)              - 3.2%   │ │ │
│  │                                          │  │ └────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sub-chart (A / B / C)                   │
│                                                 🟥 Filter – Product Category | Variance Direction   │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: COST vs REVENUE (COST CREEP DETECTION)                                          Q3         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Cost-to-Revenue Ratio Trend              │  │ Component Growth Rate Comparison (Indexed)       │ │
│  │                                          │  │                                                  │ │
│  │  ── Total Cost/Rev %                     │  │ All lines indexed to 100 at start period         │ │
│  │  ── COGS/Rev %                           │  │                                                  │ │
│  │  ┈┈ PY Avg Ratio (reference)             │  │  ── Revenue (bold)   ── COGS                     │ │
│  │                                          │  │  ── Mfg Cost         ── Freight                  │ │
│  │ 80% ┌──────────────────────────────────┐ │  │  ── Scrap Loss                                  │ │
│  │     │                                  │ │  │                                                  │ │
│  │ 70% │  ●───●───●──●───●───●───●───●   │ │  │ 160 ┌──────────────────────────────────┐        │ │
│  │     │                                  │ │  │     │        ── Freight (150)           │        │ │
│  │ 60% │  ○───○───○──○───○───○───○───○   │ │  │ 140 │     ── Mfg Cost (135)             │        │ │
│  │     │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈   │ │  │     │  ── COGS (125)                    │        │ │
│  │ 50% │                                  │ │  │ 120 │  ══ Revenue (120) ← reference     │        │ │
│  │     │                                  │ │  │     │                                    │        │ │
│  │ 40% └──────────────────────────────────┘ │  │ 100 │──●──────────────────────────────── │        │ │
│  │     Jan Feb Mar Apr May Jun Jul Aug      │  │     │  ── Scrap (90)                    │        │ │
│  │                                          │  │  80 └──────────────────────────────────┘        │ │
│  │  ⚠ Alert: Jun-Aug ratio > PY avg + 2pp  │  │     Q1'11  Q3'11  Q1'12  Q3'12  Q1'13  Q3'13   │ │
│  │                                          │  │                                                  │ │
│  │                                          │  │  ⚠ Freight growing 30% faster than revenue       │ │
│  │                                          │  │  ✅ Scrap declining — good cost control           │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│  🟧 Toggle – Sales Channel                     🟧 Toggle – Sales Channel                           │
│  🟥 Filter – Product Category | Territory      🟥 Filter – Product Category                        │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: COST WATERFALL & DETAIL TABLE                                                    Q1         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Cost Component Waterfall                 │  │ Cost Detail Table                                │ │
│  │                                          │  │                                                  │ │
│  │  Revenue                                 │  │  Year-Mth│ Rev   │ COGS │ Mfg  │Frght│ Tax │Scrp│ │
│  │  ████████████████████████████  $45.2M    │  │          │       │      │ Cost │     │     │Loss│ │
│  │            COGS                          │  │  ────────┼───────┼──────┼──────┼─────┼─────┼────│ │
│  │            ████████████████████ -$27.1M  │  │  2014-Jan│$3.8M  │$2.3M │$350K │$105K│$52K │$18K│ │
│  │                    Gross Profit          │  │  2014-Feb│$3.6M  │$2.1M │$330K │$98K │$49K │$15K│ │
│  │                    ████████████ =$18.1M  │  │  2014-Mar│$4.2M  │$2.5M │$380K │$115K│$56K │$20K│ │
│  │                       Mfg Cost           │  │  ...     │...    │...   │...   │...  │...  │... │ │
│  │                       ██████ -$4.2M      │  │  ────────┼───────┼──────┼──────┼─────┼─────┼────│ │
│  │                         Freight          │  │  Q1 Sub  │$11.6M │$6.9M │$1.1M │$318K│$157K│$53K│ │
│  │                         ████ -$1.3M      │  │  2014 Tot│$45.2M │$27.1M│$4.2M │$1.3M│$0.6M│$0.2M│
│  │                           Tax            │  │                                                  │ │
│  │                           ███ -$0.6M     │  │  +Columns: TotCost│Cost/Rev%│MoM%│YoY%          │ │
│  │                            Scrap         │  │                                                  │ │
│  │                            ██ -$0.2M     │  │  Sortable │ Conditional formatting               │ │
│  │                             Net Proxy    │  │  Subtotals per Quarter & Year                    │ │
│  │                             ███████      │  │                                                  │ │
│  │                             =$11.8M      │  │  → Export: CSV / Excel                           │ │
│  │                                          │  │                                                  │ │
│  │  🟧 Toggle – Sales Channel               │  │  🟧 Toggle – Sales Channel                      │ │
│  │  🟧 Toggle – Period (YTD/Qtr/Month)      │  │  🟥 Filter – Product Cat | Work Center          │ │
│  │  🟥 Filter – Product Category             │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Revenue + COGS (via dim_product.standard_cost × order_qty) + order-level tax & freight |
| `fct_workorder` | Manufacturing actual cost, planned cost, cost variance, scrapped qty |
| `fct_workorder_routing` | Operation-level cost variance by work center |
| `fct_purchase` | Procurement line_total, order-level tax & freight, vendor unit_price trends |
| `dim_product` | Standard cost (for COGS & scrap valuation), category hierarchy |
| `dim_date` | Calendar year, quarter, month — for time-series analysis |
| `dim_workcenter` | Work center name — for variance decomposition |
| `dim_vendor` | Vendor name, credit_rating, is_preferred_vendor — for price change analysis |
| `dim_sales_territory` | Territory group — filter only |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `fct_sale.line_total` |
| COGS | `dim_product.standard_cost × fct_sale.order_qty` |
| Manufacturing Cost | `fct_workorder.total_actual_cost` |
| Manufacturing Variance | `fct_workorder.cost_variance`, `fct_workorder.cost_variance_pct` |
| Routing Variance | `fct_workorder_routing.cost_variance`, `cost_variance_pct`, `cost_per_resource_hr` |
| Scrap Loss | `fct_workorder.scrapped_qty × dim_product.standard_cost` |
| Sales Freight | `fct_sale.order_freight_amount` (dedup by sales_order_id) |
| Sales Tax | `fct_sale.order_tax_amount` (dedup by sales_order_id) |
| PO Freight | `fct_purchase.order_freight_amount` (dedup by purchase_order_id) |
| PO Tax | `fct_purchase.order_tax_amount` (dedup by purchase_order_id) |
| Vendor Price | `fct_purchase.unit_price` per `dim_vendor` |

### **Key Calculations**
```sql
-- =====================================================
-- ROW 1: Total Cost Summary — KPI Cards & Trend
-- =====================================================

-- Cost Components
COGS              = SUM(dp.standard_cost * fs.order_qty)             -- fct_sale + dim_product
Mfg_Cost          = SUM(fw.total_actual_cost)                        -- fct_workorder
Sales_Freight     = SUM(DISTINCT fs.order_freight_amount              -- dedup by sales_order_id
                        PER sales_order_id)
Sales_Tax         = SUM(DISTINCT fs.order_tax_amount                  -- dedup by sales_order_id
                        PER sales_order_id)
PO_Freight        = SUM(DISTINCT fp.order_freight_amount              -- dedup by purchase_order_id
                        PER purchase_order_id)
PO_Tax            = SUM(DISTINCT fp.order_tax_amount                  -- dedup by purchase_order_id
                        PER purchase_order_id)
Scrap_Loss        = SUM(fw.scrapped_qty * dp.standard_cost)          -- fct_workorder + dim_product

-- Aggregated
Total_Freight     = Sales_Freight + PO_Freight
Total_Tax         = Sales_Tax + PO_Tax
Total_Prod_Cost   = COGS + Mfg_Cost + Total_Freight + Total_Tax + Scrap_Loss

-- % of Revenue
Component_%_Rev   = Component / SUM(fs.line_total) * 100


-- =====================================================
-- ROW 2: Cost Variance Analysis
-- =====================================================

-- Work Order Level Variance
WO_Planned        = SUM(fw.total_planned_cost)
WO_Actual         = SUM(fw.total_actual_cost)
WO_Variance       = SUM(fw.cost_variance)                 -- actual - planned; positive = overrun
WO_Variance_%     = WO_Variance / WO_Planned * 100

-- By Product Category
Variance_By_Cat   = SUM(fw.cost_variance) GROUP BY dp.product_category_name

-- By Work Center (routing level)
Variance_By_WC    = SUM(fwr.cost_variance) GROUP BY dw.workcenter_name
-- Additional: cost_per_resource_hr trend by workcenter

-- By Vendor (purchase price change)
Vendor_Price_Chg  = (AVG(fp_current.unit_price) - AVG(fp_prior.unit_price))
                    / AVG(fp_prior.unit_price) * 100
-- Where current = most recent 12M, prior = preceding 12M

-- Overrun / Underrun Counts
Overrun_Count     = COUNT(*) FROM fct_workorder WHERE cost_variance > 0
Underrun_Count    = COUNT(*) FROM fct_workorder WHERE cost_variance < 0


-- =====================================================
-- ROW 3: Cost-to-Revenue Ratio & Indexed Growth
-- =====================================================

-- Cost-to-Revenue Ratio (monthly)
Cost_to_Rev_%     = Total_Prod_Cost / Revenue * 100 GROUP BY year_month
COGS_to_Rev_%     = COGS / Revenue * 100             GROUP BY year_month

-- PY Average (reference line)
PY_Avg_Ratio      = AVG(Cost_to_Rev_%) WHERE calendar_year = current_year - 1

-- Indexed Growth (Base 100 = Q1 of first available year)
-- For each component and revenue:
Index_Q = (Value_Q / Value_Q1_Base) * 100

-- Example:
Revenue_Index     = SUM(line_total)_Q / SUM(line_total)_Q1_2011 * 100
COGS_Index        = COGS_Q / COGS_Q1_2011 * 100
Mfg_Index         = Mfg_Cost_Q / Mfg_Cost_Q1_2011 * 100
Freight_Index     = Total_Freight_Q / Total_Freight_Q1_2011 * 100
Scrap_Index       = Scrap_Loss_Q / Scrap_Loss_Q1_2011 * 100

-- Cost Creep Detection:
-- If Component_Index > Revenue_Index → component is growing faster than revenue
-- Gap = Component_Index - Revenue_Index (positive = creep)


-- =====================================================
-- ROW 4: Waterfall & Detail Table
-- =====================================================

-- Waterfall values (same period, cumulative)
Revenue           = SUM(fs.line_total)
COGS              = -SUM(dp.standard_cost * fs.order_qty)     -- negative (deduction)
Gross_Profit      = Revenue + COGS                            -- subtotal
Mfg_Cost          = -SUM(fw.total_actual_cost)                -- negative
Freight           = -(Sales_Freight + PO_Freight)             -- negative
Tax               = -(Sales_Tax + PO_Tax)                     -- negative
Scrap             = -SUM(fw.scrapped_qty * dp.standard_cost)  -- negative
Net_Proxy         = Gross_Profit + Mfg_Cost + Freight + Tax + Scrap  -- end subtotal

-- Detail Table
SELECT
    d.year_month,
    SUM(fs.line_total)                               AS revenue,
    SUM(dp.standard_cost * fs.order_qty)             AS cogs,
    SUM(fw.total_actual_cost)                        AS mfg_cost,
    -- freight & tax (dedup needed — see dedup note)
    total_freight,
    total_tax,
    SUM(fw.scrapped_qty * dp.standard_cost)          AS scrap_loss,
    (cogs + mfg_cost + total_freight + total_tax 
     + scrap_loss)                                   AS total_cost,
    total_cost / revenue * 100                       AS cost_rev_pct,
    -- MoM% via LAG
    -- YoY% via same-month prior year join
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
-- Cross-join with fct_workorder & fct_purchase aggregates per month
GROUP BY d.year_month
ORDER BY d.year_month
```

### **Deduplication Note**
Same as Financial Overview: `order_tax_amount`, `order_freight_amount`, and `order_total_due` are **order-level** in both `fct_sale` and `fct_purchase`. When aggregating from line-item grain:
- **Option A**: Pre-aggregate per distinct order_id, then sum
- **Option B**: Prorate to line items: `line_freight = order_freight × (line_total / order_sub_total)`

This applies to both sales-side and purchase-side freight & tax.

### **Cross-Dashboard Navigation**
| From This Dashboard | Drill To | Purpose |
|---------------------|----------|---------|
| Cost KPI Cards → Mfg Cost card | SCM Cost Deep Dive | Operational cost decomposition (work center hours, cost/unit) |
| Variance by Vendor chart | Procurement Finance (#6) | Vendor spend concentration, rejection cost |
| Variance by Product treemap | Product Portfolio (#7) | Margin impact of cost overruns by product |
| Cost-to-Revenue trend | Financial Overview (#1) | Full P&L context for high cost ratio periods |
| Waterfall chart | Revenue Deep Dive (#2) | Investigate if revenue decline contributing to ratio increase |

### **Key Differentiation: Finance #3 vs SCM Cost Deep Dive**
| Aspect | Finance #3 (This Dashboard) | SCM Cost Deep Dive |
|--------|---------------------------|-------------------|
| **Lens** | Cost as % of revenue, cost creep, financial impact | Cost per unit, operational efficiency |
| **Primary KPI** | Cost-to-Revenue %, Cost Variance $ | Cost Per Unit, Inventory Carrying Value |
| **Waterfall** | Revenue → COGS → GP → Charges → Net Proxy | Total Cost → Component breakdown |
| **Indexed Growth** | Revenue as reference line | Output volume as reference |
| **Audience** | CFO, Finance Manager | Operations VP, Production Manager |
