# Revenue Deep Dive & Growth Dashboard

**Overall Objective:** Analyse revenue dynamics in depth — time-series trends (MoM, QoQ, YoY), growth momentum, channel mix shift (Internet vs Reseller), discount impact on net revenue, and seasonal patterns to identify consistently strong/weak periods.

---

## BUSINESS QUESTIONS ADDRESSED

1. What is the revenue trend over time (MoM, QoQ, YoY), and which periods show the strongest/weakest growth?
2. How is the revenue mix shifting between Internet and Reseller channels, and what is the discount impact on each channel's net revenue?
3. What are the revenue seasonality patterns, and which months/quarters consistently over- or under-perform?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  Revenue Deep Dive & Growth Dashboard                                │
│                                                                                                      │
│  Drill-down from Financial Overview (#1);                                                            │
│  feeds into Territory & Channel (#5) and Product Portfolio (#7) for dimensional cuts                 │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Revenue KPI     │ Monthly Revenue & Growth Rate Trend  │                                   │
│          │ Cards           │                                      │  • Headline financial pulse:       │
│ Revenue  │  Total Revenue  │   Revenue (Bar) + Growth% (Line)     │    revenue size + momentum        │
│  Pulse   │  YoY Growth %   │   + Prior Year Overlay               │  • Identify strongest/weakest     │
│          │  QoQ Growth %   │                                      │    periods at a glance             │
│          │  MoM Growth %   │                                      │  • Prior-period overlay for        │
│          │  + Sparklines   │                                      │    context (Q1: growth vs Q1 PY)   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Channel Revenue │ Discount Impact Analysis             │                                   │
│ Channel  │ Mix Over Time   │   by Channel                         │  • Track channel share shift:      │
│  Mix &   │                 │                                      │    is Internet gaining on           │
│ Discount │  Stacked Area   │   Gross Rev vs Net Rev (Grouped Bar) │    Reseller month-over-month?      │
│          │  (Internet vs   │   + Discount Amount (Bar)            │  • Quantify discount impact on     │
│          │   Reseller)     │   + Discount Penetration % (Line)    │    each channel's net revenue      │
│          │  + Share % Line │                                      │  • Alert if discounts erode > X%   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Revenue         │ Quarterly Revenue Comparison         │                                   │
│ Season-  │ Seasonality     │   (Multi-Year)                       │  • Spot consistent seasonal highs  │
│  ality   │ Heatmap         │                                      │    (e.g., Q4 always strong) and    │
│          │  Rows = Year    │   Grouped Bar by Quarter             │    lows (e.g., Q1 dip)             │
│          │  Cols = Month   │   across Years                       │  • Support demand planning and     │
│          │  Cell = Revenue │   + YoY Growth % per Quarter         │    resource allocation decisions   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Top/Bottom      │ Revenue Detail Table                 │                                   │
│  Growth  │ Growth Periods  │                                      │  • Quickly surface best/worst      │
│ Ranking  │                 │   Monthly: Revenue | Qty | AOV |     │    performing periods for action    │
│          │  Top 5 Growth   │   Discount | Growth% | PY Rev |     │  • Full detail table for export    │
│          │  Bottom 5 Growth│   YoY%                               │    and ad-hoc review               │
│          │  (Month-level)  │                                      │  • Sortable by any column          │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_sale + dim_date)
- ◻ Intermediate metric (derived from multiple fields)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: Full Range / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default shows full date range for trend and seasonality analysis.

```
Global Filters:     │ Timeframe: XX - YY    │
                    │ Sales Channel         │
                    │ Territory Group       │
                    │ Product Category      │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Revenue KPI Cards + Monthly Revenue & Growth Rate Trend

| Cell | Spec |
|------|------|
| **Revenue KPI Cards** | 4 Headline Cards with Period-over-Period Growth |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_date |
| | **Card 1 — Total Revenue**: `SUM(line_total)` YTD + Sparkline (last 12M) |
| | **Card 2 — YoY Growth %**: `(YTD_Rev − PY_YTD_Rev) / PY_YTD_Rev × 100` + direction arrow |
| | **Card 3 — QoQ Growth %**: `(Current_Qtr − Prior_Qtr) / Prior_Qtr × 100` + direction arrow |
| | **Card 4 — MoM Growth %**: `(Current_Month − Prior_Month) / Prior_Month × 100` + direction arrow |
| | Conditional formatting: green (positive), red (negative) |

| Cell | Spec |
|------|------|
| **Monthly Revenue & Growth Rate Trend** | Combo Chart: Revenue (Bar) + MoM Growth % (Line) + Prior Year Revenue (Dashed Line) |
| | Timeframe: Full Range (multi-year) |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_date |
| | Left axis: `Revenue = SUM(line_total) GROUP BY year_month` |
| | Right axis: `MoM_Growth = (Current_Month − Prior_Month) / Prior_Month × 100` |
| | Dashed overlay: Prior Year same month revenue |
| | Annotation: highlight months with growth > +15% (green) or < −10% (red) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

---

### ROW 2: Channel Revenue Mix Over Time + Discount Impact Analysis

| Cell | Spec |
|------|------|
| **Channel Revenue Mix Over Time** | 100% Stacked Area Chart + Channel Share % Line |
| | Timeframe: Full Range |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_date |
| | Areas: ██ Internet Revenue ██ Reseller Revenue |
| | Overlays: ── Internet Share % ── Reseller Share % |
| | `Internet_Share = Internet_Rev / Total_Rev × 100` |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Discount Impact Analysis by Channel** | Grouped Bar (Gross vs Net Revenue) + Discount Metrics |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Monthly Total |
| | Source: fct_sale |
| | Grouped bars per month: |
| | — Bar 1: `Gross_Revenue = SUM(unit_price × order_qty)` (before discount) |
| | — Bar 2: `Net_Revenue = SUM(line_total)` (after discount) |
| | — Bar 3 (small): `Discount_Amount = SUM(unit_price × unit_price_discount × order_qty)` |
| | Line overlay: `Discount_Penetration = COUNT(orders_with_discount) / COUNT(all_orders) × 100` |
| | 🟧 Toggle – Sales Channel (split view: Internet / Reseller side-by-side or stacked) |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |
| | Summary KPIs above chart: |
| | — Total Discount Amount | Discount as % of Gross Revenue | Avg Discount % per discounted order |

---

### ROW 3: Revenue Seasonality Heatmap + Quarterly Revenue Comparison

| Cell | Spec |
|------|------|
| **Revenue Seasonality Heatmap** | Matrix Heatmap; Rows = Year, Columns = Month (Jan–Dec) |
| | Timeframe: All available years |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_date |
| | Cell value: `SUM(line_total)` for each Year × Month |
| | Color scale: Low (light/cool) → High (dark/warm) |
| | Additional row: **Month Average** across all years (bottom row) |
| | Additional column: **Year Total** (rightmost column) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | Tooltip: Revenue, Order Count, MoM% change, YoY% change |

| Cell | Spec |
|------|------|
| **Quarterly Revenue Comparison (Multi-Year)** | Grouped Bar Chart; Groups = Quarter, Bars = Year |
| | Timeframe: All available years |
| | Measurement Range: Quarterly Total |
| | Source: fct_sale + dim_date |
| | `Revenue_Qtr = SUM(line_total) GROUP BY calendar_year, calendar_quarter` |
| | Bars per quarter: ██ 2011 ██ 2012 ██ 2013 ██ 2014 |
| | Line overlay: `YoY_Growth_% per quarter` |
| | Annotation: highlight quarters with consistent pattern (e.g., Q4 always highest) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

---

### ROW 4: Top/Bottom Growth Periods + Revenue Detail Table

| Cell | Spec |
|------|------|
| **Top/Bottom Growth Periods** | Two Mini-Tables or Diverging Bar Chart |
| | Timeframe: Full Range |
| | Measurement Range: Monthly |
| | Source: fct_sale + dim_date |
| | **Top 5**: Months with highest MoM Growth % |
| | **Bottom 5**: Months with lowest (most negative) MoM Growth % |
| | Columns: Period (Year-Month) | Revenue | Prior Month Rev | MoM Growth % | Channel Dominant |
| | Color: Top 5 = green bars, Bottom 5 = red bars |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Toggle – Granularity (MoM / QoQ / YoY) |

| Cell | Spec |
|------|------|
| **Revenue Detail Table** | Full Detail Table; Sortable; Exportable |
| | Timeframe: Full Range |
| | Measurement Range: Monthly |
| | Source: fct_sale + dim_date + dim_product |
| | Columns: Year-Month | Revenue | Order Qty | AOV | Discount Amount | Discount % | MoM Growth % | PY Revenue | YoY Growth % |
| | Features: Sortable by any column, conditional formatting on growth columns |
| | Subtotal rows per Quarter and Year |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |
| | Export: CSV / Excel |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: Full Range / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Sales Channel            │
  (e.g., specific month revenue, growth rate)             │  Territory Group          │
                                                          │  Product Category         │
  Drill-through to Territory & Channel (#5)               └──────────────────────────┘
  or Product Portfolio (#7) for dimensional detail

  Legend:                                                      
  🟧 Filters for "Crawl"                                       
  🟥 Filters for "Walk/Run"                                     

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: REVENUE PULSE                                                                   Q1         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Revenue KPI Cards                        │  │  Monthly Revenue & Growth Rate Trend             │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────┐ ┌─────────┐                │  │  ██ Revenue   ┈┈ PY Revenue   ── MoM Growth %    │ │
│  │  │  Total  │ │  YoY    │                │  │                                                  │ │
│  │  │ Revenue │ │ Growth  │                │  │ $6M ┌──────────────────────────────────┐  +20%   │ │
│  │  │ $45.2M  │ │  +7.2%  │                │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │         │ │
│  │  │ ~~~~~~  │ │   ▲     │                │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │  +10%   │ │
│  │  └─────────┘ └─────────┘                │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │         │ │
│  │  ┌─────────┐ ┌─────────┐                │  │     │ ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈  │   0%    │ │
│  │  │  QoQ    │ │  MoM    │                │  │     │──●──●──●──●──●──●──●──●──●───── │         │ │
│  │  │ Growth  │ │ Growth  │                │  │ $0  └──────────────────────────────────┘  -10%   │ │
│  │  │  +3.4%  │ │  +1.8%  │                │  │     Jan  Feb  Mar  Apr  May  Jun  Jul  Aug       │ │
│  │  │   ▲     │ │   ▲     │                │  │                                                  │ │
│  │  └─────────┘ └─────────┘                │  │     ● Highlight: >+15% green | <-10% red        │ │
│  │                                          │  │                                                  │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: CHANNEL MIX & DISCOUNT IMPACT                                                   Q2         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Channel Revenue Mix Over Time            │  │ Discount Impact Analysis by Channel              │ │
│  │                                          │  │                                                  │ │
│  │  ██ Internet  ██ Reseller                │  │  Disc Amt: $2.1M | % of Gross: 4.5% | Avg: 8%  │ │
│  │  ── Internet Share %                     │  │                                                  │ │
│  │                                          │  │  ██ Gross Rev  ██ Net Rev  ▒▒ Discount Amt      │ │
│  │ 100%┌──────────────────────────────────┐ │  │  ── Discount Penetration %                      │ │
│  │     │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ │  │                                                  │ │
│  │     │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ │  │ $6M ┌──────────────────────────────────┐  60%   │ │
│  │     │████████████████████████████████│ │  │     │ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ │         │ │
│  │     │████████████████████████████████│ │  │     │ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ │  40%   │ │
│  │     │████████████████████████████████│ │  │     │ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ ██▓▓ │         │ │
│  │  0% └──────────────────────────────────┘ │  │     │──●──●──●──●──●──●──●──●──●──── │  20%   │ │
│  │      2011    2012    2013    2014         │  │ $0  └──────────────────────────────────┘         │ │
│  │                                          │  │     Jan  Feb  Mar  Apr  May  Jun  Jul  Aug       │ │
│  │      ── Internet Share: 55% → 62%  ▲     │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│  🟥 Filter – Territory Group | Product Cat     🟧 Toggle – Sales Channel (side-by-side)            │
│                                                 🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: SEASONALITY ANALYSIS                                                             Q3         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Revenue Seasonality Heatmap              │  │ Quarterly Revenue Comparison (Multi-Year)        │ │
│  │                                          │  │                                                  │ │
│  │        Jan  Feb  Mar  Apr  May  Jun ...  │  │   ██ 2011  ██ 2012  ██ 2013  ██ 2014            │ │
│  │  2011 │ ░░ │ ░░ │ ░▒ │ ░▒ │ ▒▒ │ ▒▒ │  │  │   ── YoY Growth % per Quarter                  │ │
│  │  2012 │ ░▒ │ ░▒ │ ▒▒ │ ▒▒ │ ▒▓ │ ▒▓ │  │  │                                                  │ │
│  │  2013 │ ▒▒ │ ▒▒ │ ▒▓ │ ▒▓ │ ▓▓ │ ▓▓ │  │  │ $15M ┌────────────────────────────────┐  +20%  │ │
│  │  2014 │ ▒▓ │ ▒▓ │ ▓▓ │ ▓▓ │ ▓█ │ ▓█ │  │  │      │ ████  ████  ████  ████        │         │ │
│  │       │    │    │    │    │    │    │  │  │      │ ████  ████  ████  ████        │  +10%  │ │
│  │  Avg  │$1.2│$1.1│$1.5│$1.4│$1.8│$1.9│  │  │      │ ████  ████  ████  ████        │         │ │
│  │                                          │  │      │ ████  ████  ████  ████        │   0%   │ │
│  │  Color: ░░ Low  ▒▒ Medium  ▓▓ High  ██  │  │      │──●──────●──────●──────●─────── │         │ │
│  │                                          │  │ $0   └────────────────────────────────┘  -10%  │ │
│  │  Tooltip: Rev, Qty, MoM%, YoY%          │  │        Q1       Q2       Q3       Q4            │ │
│  │                                          │  │                                                  │ │
│  │  [Pattern: Q3-Q4 consistently highest]   │  │  [Insight: Q4 avg +18% over Q3 every year]      │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│  🟧 Toggle – Sales Channel                     🟧 Toggle – Sales Channel                           │
│  🟥 Filter – Territory Group                    🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: GROWTH RANKING & DETAIL TABLE                                                    Q1         │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Top / Bottom Growth Periods              │  │ Revenue Detail Table                             │ │
│  │                                          │  │                                                  │ │
│  │  ▓ TOP 5 (Highest MoM Growth)            │  │  Year-Mth │ Revenue │ Qty │ AOV   │ Disc  │ MoM │ │
│  │  ┌───────────────────────────────────┐   │  │           │         │     │       │ Amt   │ Grw │ │
│  │  │ 2014-Jun  ██████████████  +22.3%  │   │  │  ─────────┼─────────┼─────┼───────┼───────┼─────│ │
│  │  │ 2013-Oct  █████████████   +19.8%  │   │  │  2014-Jan │ $3.8M   │ 2.1K│ $1.8K │ $120K │ +3% │ │
│  │  │ 2014-Mar  ████████████    +17.1%  │   │  │  2014-Feb │ $3.6M   │ 1.9K│ $1.9K │ $105K │ -5% │ │
│  │  │ 2013-Jun  ███████████     +15.6%  │   │  │  2014-Mar │ $4.2M   │ 2.3K│ $1.8K │ $140K │+17% │ │
│  │  │ 2012-Nov  ██████████      +14.2%  │   │  │  2014-Apr │ $4.0M   │ 2.2K│ $1.8K │ $135K │ -5% │ │
│  │  └───────────────────────────────────┘   │  │  ...      │ ...     │ ... │ ...   │ ...   │ ... │ │
│  │                                          │  │  ─────────┼─────────┼─────┼───────┼───────┼─────│ │
│  │  ▒ BOTTOM 5 (Lowest MoM Growth)          │  │  Q1 Sub   │ $11.6M  │ 6.3K│ $1.8K │ $365K │     │ │
│  │  ┌───────────────────────────────────┐   │  │  2014 Tot │ $45.2M  │ 25K │ $1.8K │ $2.1M │ +7% │ │
│  │  │ 2012-Jan  ██████████████  -18.5%  │   │  │                                                  │ │
│  │  │ 2013-Feb  █████████████   -14.2%  │   │  │  Sortable by any column                         │ │
│  │  │ 2014-Feb  ████████████    -12.8%  │   │  │  Conditional: growth green (+) / red (−)        │ │
│  │  │ 2012-Aug  ███████████     -10.1%  │   │  │  Subtotal per Quarter & Year                    │ │
│  │  │ 2013-Jan  ██████████       -8.7%  │   │  │                                                  │ │
│  │  └───────────────────────────────────┘   │  │  → Export: CSV / Excel                           │ │
│  │                                          │  │                                                  │ │
│  │  🟧 Toggle – Sales Channel               │  │  PY Rev │ YoY% ← additional columns scrollable  │ │
│  │  🟥 Toggle – MoM / QoQ / YoY             │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact – grain: order line item. Revenue, discount, quantity, channel |
| `dim_date` | Date dimension — calendar_year, calendar_quarter, month_of_year, year_month |
| `dim_product` | Product details — category, subcategory (filter only) |
| `dim_sales_territory` | Territory group, country (filter only) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue (Net) | `fct_sale.line_total` — after discount, before tax/freight |
| Revenue (Gross) | `fct_sale.unit_price × fct_sale.order_qty` — before discount |
| Discount Amount | `fct_sale.unit_price × fct_sale.unit_price_discount × fct_sale.order_qty` |
| Discount Rate | `fct_sale.unit_price_discount` |
| Order Quantity | `fct_sale.order_qty` |
| Channel | `fct_sale.sales_channel` (Internet / Reseller) |
| Order ID | `fct_sale.sales_order_id` — for AOV and order-level calcs |
| Time | `dim_date.calendar_year`, `dim_date.calendar_quarter`, `dim_date.month_of_year`, `dim_date.year_month` |

### **Key Calculations**
```sql
-- =====================================================
-- ROW 1: Revenue Pulse — KPI Cards & Growth Trend
-- =====================================================

-- Total Revenue (Net — after discount)
Total_Revenue = SUM(fct_sale.line_total)

-- MoM Growth %
MoM_Growth = (Current_Month_Rev - Prior_Month_Rev) / Prior_Month_Rev * 100

-- QoQ Growth %
QoQ_Growth = (Current_Qtr_Rev - Prior_Qtr_Rev) / Prior_Qtr_Rev * 100

-- YoY Growth %
YoY_Growth = (Current_YTD_Rev - PY_YTD_Rev) / PY_YTD_Rev * 100

-- Monthly Revenue Trend
Monthly_Revenue = SUM(line_total) GROUP BY year_month
PY_Monthly_Revenue = SUM(line_total) WHERE calendar_year = current_year - 1 GROUP BY month_of_year


-- =====================================================
-- ROW 2: Channel Mix & Discount Impact
-- =====================================================

-- Channel Revenue Mix
Internet_Revenue  = SUM(line_total) WHERE sales_channel = 'Internet'
Reseller_Revenue  = SUM(line_total) WHERE sales_channel = 'Reseller'
Internet_Share_%  = Internet_Revenue / Total_Revenue * 100

-- Gross Revenue (before discount)
Gross_Revenue = SUM(unit_price * order_qty)

-- Net Revenue (after discount, = line_total)
Net_Revenue = SUM(line_total)

-- Discount Amount
Discount_Amount = SUM(unit_price * unit_price_discount * order_qty)
-- Verification: Gross_Revenue - Net_Revenue ≈ Discount_Amount

-- Discount as % of Gross Revenue
Discount_Pct_of_Gross = Discount_Amount / Gross_Revenue * 100

-- Discount Penetration % (share of orders that have any discount)
Discount_Penetration = COUNT(DISTINCT CASE WHEN unit_price_discount > 0 
                              THEN sales_order_id END)
                     / COUNT(DISTINCT sales_order_id) * 100

-- Average Discount % per discounted order
Avg_Discount_Rate = AVG(unit_price_discount) WHERE unit_price_discount > 0


-- =====================================================
-- ROW 3: Seasonality Analysis
-- =====================================================

-- Seasonality Heatmap Cell
Heatmap_Cell = SUM(line_total) GROUP BY calendar_year, month_of_year

-- Month Average across years
Month_Avg = AVG(Monthly_Revenue) GROUP BY month_of_year

-- Quarterly Revenue
Quarterly_Revenue = SUM(line_total) GROUP BY calendar_year, calendar_quarter

-- QoQ (same quarter, year-over-year)
Quarter_YoY = (Current_Year_Qtr_Rev - PY_Same_Qtr_Rev) / PY_Same_Qtr_Rev * 100

-- Seasonality Index (month avg vs overall monthly avg)
Seasonality_Index = Month_Avg / Overall_Monthly_Avg * 100
-- >100 = above-average month, <100 = below-average month


-- =====================================================
-- ROW 4: Growth Ranking & Detail Table
-- =====================================================

-- Top/Bottom Growth Periods
WITH monthly_growth AS (
    SELECT
        year_month,
        SUM(line_total) AS revenue,
        LAG(SUM(line_total)) OVER (ORDER BY year_month) AS prior_month_rev,
        (SUM(line_total) - LAG(SUM(line_total)) OVER (ORDER BY year_month)) 
            / LAG(SUM(line_total)) OVER (ORDER BY year_month) * 100 AS mom_growth
    FROM fct_sale
    JOIN dim_date ON fct_sale.order_date_key = dim_date.date_key
    GROUP BY year_month
)
-- Top 5
SELECT * FROM monthly_growth ORDER BY mom_growth DESC LIMIT 5
-- Bottom 5
SELECT * FROM monthly_growth ORDER BY mom_growth ASC LIMIT 5

-- AOV (for detail table)
AOV = SUM(order_total_due) / COUNT(DISTINCT sales_order_id)

-- Revenue Detail Table
SELECT
    d.year_month,
    SUM(s.line_total)                                           AS revenue,
    SUM(s.order_qty)                                            AS order_qty,
    SUM(s.order_total_due) / COUNT(DISTINCT s.sales_order_id)   AS aov,
    SUM(s.unit_price * s.unit_price_discount * s.order_qty)     AS discount_amount,
    SUM(s.unit_price * s.unit_price_discount * s.order_qty) 
        / NULLIF(SUM(s.unit_price * s.order_qty), 0) * 100     AS discount_pct,
    -- MoM Growth (via LAG)
    -- PY Revenue (via self-join on month_of_year, calendar_year - 1)
    -- YoY Growth
FROM fct_sale s
JOIN dim_date d ON s.order_date_key = d.date_key
GROUP BY d.year_month
ORDER BY d.year_month
```

### **Cross-Dashboard Navigation**
| From This Dashboard | Drill To | Purpose |
|---------------------|----------|---------|
| Channel Revenue Mix chart | Territory & Channel (#5) | See which territories drive channel shift |
| Heatmap month cell | Product Portfolio (#7) | Which products drive seasonal spikes |
| Growth ranking period | Financial Overview (#1) | See full P&L for that period |
| Discount Impact section | Profitability & Margin (#4) | Quantify margin erosion from discounts |
