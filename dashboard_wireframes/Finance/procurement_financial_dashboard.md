# Procurement Financial Analysis Dashboard

**Overall Objective:** Analyse procurement spending through a financial lens — track total spend trend and its correlation with revenue growth, measure vendor spend concentration and pricing efficiency, and quantify the cost of quality failures (rejected materials) by vendor to support sourcing decisions and procurement ROI evaluation.

---

## BUSINESS QUESTIONS ADDRESSED

1. What is the total procurement spend trend, and how does it correlate with revenue growth — are we spending proportionally to growth?
2. How concentrated is our procurement spend across vendors, and are we getting better pricing from high-volume vendors?
3. What is the financial impact of rejected materials — how much spend is wasted on defective receipts, and which vendors are responsible?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                             Procurement Financial Analysis Dashboard                                  │
│                                                                                                      │
│  Drill-down from Cost Structure (#3) — procurement spend component;                                 │
│  complements SCM Purchasing Efficiency (operational lens) with a financial lens                       │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Spend KPI Cards │ Spend vs Revenue Correlation         │                                   │
│          │                 │                                      │  • Headline: total procurement     │
│ Spend    │  Total Spend    │   Dual-Axis Line:                    │    spend + YoY + spend-to-revenue │
│  vs      │  Spend Growth%  │   ── Procurement Spend               │  • Dual-axis: are spend and       │
│ Revenue  │  Spend-to-Rev   │   ── Revenue                         │    revenue growing in sync?        │
│ Trend    │  Ratio          │   + Spend/Rev Ratio trend line       │  • Ratio > baseline = over-       │
│          │  + Sparklines   │   + Highlight divergence zones       │    spending relative to revenue    │
│          │                 │                                      │                                   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Vendor Pareto   │ Volume vs Price Scatter              │                                   │
│ Vendor   │ Chart           │                                      │  • Pareto: top 20% vendors often  │
│ Spend    │                 │   X = Purchase Volume (qty)          │    account for 80% of spend        │
│ Concen-  │  Cumulative %   │   Y = Avg Unit Price                 │  • Scatter: do high-volume        │
│ tration  │  of total spend │   Color = Credit Rating              │    vendors offer better pricing?   │
│          │  by vendor      │   Size = Total Spend                 │  • Identify vendors with pricing   │
│          │  (80/20 rule)   │   + Trend arrows (price direction)  │    leverage opportunities          │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Rejection Cost  │ Rejection by Vendor & Product        │                                   │
│ Cost of  │ KPI Cards       │                                      │  • Total $ wasted on rejections   │
│ Quality  │                 │   Top 10 Vendors by Rejected $       │  • Which vendors are responsible  │
│  —       │  Total Rejected$│   (Horizontal Bar)                   │    for most rejection cost         │
│ Rejected │  Rejection Rate │   + By Product Category              │  • Product category breakdown     │
│ Material │  % of Spend     │   (Stacked or secondary view)       │    to detect material-specific    │
│          │  + YoY trend    │                                      │    quality issues                  │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Vendor          │ Procurement Detail Table              │                                   │
│  Detail  │ Scorecard       │                                      │  • Vendor scorecard radar for     │
│  Break-  │ (Radar Chart)   │   Vendor | Spend | % Total |         │    selected vendor: spend, price, │
│  down    │                 │   Avg Price | Volume | Rejected$ |   │    volume, rejection, rating      │
│          │  Selected       │   Reject Rate | Credit Rating |      │  • Full detail table — sortable,  │
│          │  vendor deep    │   Preferred? | Price Trend |          │    exportable, conditional flags  │
│          │  dive           │   Spend Rank                         │                                   │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (from fct_purchase + dim_vendor + dim_product + dim_date)
- ◻ Intermediate metric (derived: spend-to-revenue ratio requires fct_sale)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard — default shows YTD with monthly granularity.

```
Global Filters:     │ Timeframe: XX - YY            │
                    │ Vendor                         │
                    │ Credit Rating                  │
                    │ Product Category               │
                    │ Preferred Vendor (Yes/No/All)  │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Spend KPI Cards + Spend vs Revenue Correlation

| Cell | Spec |
|------|------|
| **Spend KPI Cards** | 4 Headline Cards + Sparklines |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_purchase + fct_sale (for ratio) |
| | **Card 1 — Total Procurement Spend**: `SUM(fct_purchase.line_total)` + YoY% |
| | **Card 2 — Spend Growth YoY %**: `(Spend_YTD − Spend_PY) / Spend_PY × 100` + direction arrow |
| | **Card 3 — Spend-to-Revenue Ratio**: `Total_Spend / Total_Revenue × 100` + YoY delta (pp) + Sparkline (12M) |
| | **Card 4 — Procurement Freight**: `SUM(order_freight_amount)` from fct_purchase (DISTINCT order) + YoY% |
| | Conditional: Spend/Rev Ratio green < 55%, yellow 55-65%, red > 65% |
| | Sub-metric on Card 3: Revenue Growth % for comparison |

| Cell | Spec |
|------|------|
| **Spend vs Revenue Correlation** | Dual-Axis Line Chart + Ratio Trend |
| | Timeframe: Full Range |
| | Measurement Range: Monthly |
| | Source: fct_purchase + fct_sale + dim_date |
| | **Left Y-axis**: Dollar amount |
| | **Right Y-axis**: Ratio % |
| | Lines: |
| | — ── Procurement Spend (blue, solid) = `SUM(fct_purchase.line_total)` per month |
| | — ── Revenue (green, solid) = `SUM(fct_sale.line_total)` per month |
| | — ┈┈ Spend/Revenue Ratio % (orange, dashed) = Spend / Revenue × 100 |
| | Annotations: |
| | — ⚠ Highlight months where Ratio increases > 5 pp vs prior month → "Spend spike" |
| | — Shaded zones where Spend grows faster than Revenue → "Overspending zone" |
| | 🟧 Toggle – Quarterly / Monthly granularity |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Vendor |

---

### ROW 2: Vendor Pareto Chart + Volume vs Price Scatter

| Cell | Spec |
|------|------|
| **Vendor Pareto Chart** | Pareto (Bar + Cumulative Line) |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Vendor |
| | Source: fct_purchase + dim_vendor |
| | Bars: `Spend = SUM(line_total)` per vendor, sorted descending |
| | Cumulative line: Running total % of grand total spend |
| | Reference lines: |
| | — 80% cumulative threshold (horizontal dashed) |
| | — Vertical line at the vendor where 80% is crossed |
| | KPI annotations above chart: |
| | — Vendors in top 80%: XX of YY total (XX%) |
| | — Top 1 vendor spend %: XX% |
| | — HHI (Herfindahl index) or CR5 (Concentration Ratio top 5): XX% |
| | Bar color: Credit Rating (gradient: Superior=dark blue → Below Average=red) |
| | 🟧 Toggle – Top N vendors (10 / 20 / All) |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Credit Rating |
| | 🟥 Filter – Preferred Vendor |

| Cell | Spec |
|------|------|
| **Volume vs Price Scatter Plot** | Scatter / Bubble Chart |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Per Vendor |
| | Source: fct_purchase + dim_vendor |
| | X-axis: `Purchase_Volume = SUM(order_qty)` per vendor |
| | Y-axis: `Avg_Unit_Price = AVG(unit_price)` per vendor |
| | Bubble size: `Total_Spend = SUM(line_total)` |
| | Bubble color: `credit_rating_desc` (Superior → Below Average gradient) |
| | Trend line: Regression — does higher volume correlate with lower price? |
| | — Negative slope = volume discount works ✅ |
| | — Flat/positive slope = no pricing leverage ⚠ |
| | Quadrant lines: |
| | — Vertical: Median Volume |
| | — Horizontal: Median Avg Unit Price |
| | Quadrants: |
| | — Q1 (top-left): Low Volume + High Price → 🚨 **"Expensive niche — negotiate or consolidate"** |
| | — Q2 (top-right): High Volume + High Price → ⚠️ **"Volume without leverage — renegotiate"** |
| | — Q3 (bottom-left): Low Volume + Low Price → ─ **"Small & cheap — maintain"** |
| | — Q4 (bottom-right): High Volume + Low Price → ✅ **"Best deal — strategic partners"** |
| | Tooltip: Vendor name, Credit Rating, Total Spend, Volume, Avg Unit Price, Rejection Rate |
| | 🟧 Toggle – Granularity (Product / Vendor) |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Credit Rating |

---

### ROW 3: Rejection Cost KPIs + Rejection by Vendor & Product

| Cell | Spec |
|------|------|
| **Rejection Cost KPI Cards** | 3 Headline Cards |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_purchase |
| | **Card 1 — Total Rejection Cost**: `SUM(rejected_amount)` + YoY% |
| | **Card 2 — Rejection Rate %**: `SUM(rejected_qty) / SUM(received_qty) × 100` + YoY delta (pp) |
| | **Card 3 — Rejection as % of Spend**: `SUM(rejected_amount) / SUM(line_total) × 100` + YoY delta |
| | Conditional: Rejection Rate green < 2%, yellow 2-5%, red > 5% |
| | Sub-metric: Estimated annual rejection cost if rate continues |

| Cell | Spec |
|------|------|
| **Rejection by Vendor & Product** | Horizontal Bar + Category Breakdown |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Vendor |
| | Source: fct_purchase + dim_vendor + dim_product |
| | **Primary View — Top 10 Vendors by Rejection Cost**: |
| | Horizontal bar: `SUM(rejected_amount)` per vendor, sorted descending |
| | Bar color: Rejection rate % gradient (green < 2%, yellow 2-5%, red > 5%) |
| | Label on each bar: Rejected $ + Rejection Rate % + Volume (rejected_qty) |
| | **Secondary View — By Product Category** (toggle): |
| | Stacked bar: Rejection cost per product category, stacked by vendor |
| | Or treemap: area = Rejected $, color = Rejection Rate % |
| | **Comparison Table below chart**: |
| | Columns: Vendor │ Rejected $ │ Rejected Qty │ Received Qty │ Rejection Rate % │ % of Total Rejection │ Credit Rating │ Preferred? |
| | 🟧 Toggle – By Vendor / By Product Category |
| | 🟧 Toggle – Top N (5 / 10 / All) |
| | 🟥 Filter – Credit Rating |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Vendor |

---

### ROW 4: Vendor Scorecard + Procurement Detail Table

| Cell | Spec |
|------|------|
| **Vendor Scorecard (Radar Chart)** | Radar / Spider Chart for Selected Vendor |
| | Timeframe: YTD |
| | Measurement Range: Percentile rank among all vendors |
| | Source: fct_purchase + dim_vendor |
| | Axes (5 dimensions, each 0-100 percentile): |
| | — **Spend Volume** (higher = more spend = larger axis) |
| | — **Price Competitiveness** (lower avg price vs category benchmark = higher score) |
| | — **Quality** (lower rejection rate = higher score) |
| | — **Credit Rating** (1=Superior → mapped to 100, 5=Below Average → 20) |
| | — **Reliability** (higher stocked_qty / order_qty = higher score) |
| | Overlay: Selected vendor (blue filled) vs Overall average (dashed outline) |
| | Dropdown: Select vendor from list |
| | Sub-metrics below radar: |
| | — Total Spend: $XX.XM |
| | — Avg Unit Price: $XX.XX |
| | — Rejection Rate: X.X% |
| | — Credit Rating: X (label) |
| | — Preferred: Yes/No |
| | 🟧 Dropdown – Select Vendor |

| Cell | Spec |
|------|------|
| **Procurement Detail Table** | Full Detail Table; Sortable; Exportable |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Vendor |
| | Source: fct_purchase + dim_vendor + dim_product + dim_date |
| | Columns: |
| | — Vendor Name |
| | — Credit Rating |
| | — Preferred? |
| | — Total Spend ($) |
| | — % of Total Spend |
| | — Order Count |
| | — Total Volume (order_qty) |
| | — Avg Unit Price |
| | — Avg Price Change vs PY ($) |
| | — Avg Price Change vs PY (%) |
| | — Received Qty |
| | — Rejected Qty |
| | — Rejection Rate % |
| | — Rejected Amount ($) |
| | — Stocked Qty |
| | — Freight ($) |
| | — Spend Rank |
| | Features: |
| | — Sortable by any column |
| | — Conditional formatting: Rejection Rate (green/yellow/red), Price Change (green=decrease, red=increase) |
| | — Flag: vendors with Rejection Rate > 5% → "Quality alert" |
| | — Flag: vendors with Spend Rank ≤ 5 AND Price Change > +10% → "Key vendor price increase alert" |
| | — Flag: preferred vendors with declining quality → "Review preferred status" |
| | — Expandable rows: Click vendor → show product-level breakdown |
| | 🟧 Toggle – Vendor / Product view |
| | 🟥 Filter – Credit Rating |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Preferred Vendor |
| | Export: CSV / Excel |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌───────────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY           │
  highlight vendor detail & pricing info                  │  Vendor                        │
  (e.g., spend, rejection, credit rating)                 │  Credit Rating                 │
                                                          │  Product Category              │
  Drill-through to Cost Structure (#3)                    │  Preferred Vendor (Y/N/All)    │
  for cost component context                              └───────────────────────────────┘

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: SPEND vs REVENUE TREND                                                           Q1        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Spend KPI Cards                          │  │  Spend vs Revenue Correlation                    │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────────────────────────────┐     │  │  ── Procurement Spend  ── Revenue                │ │
│  │  │  Total Spend       $24.8M      │     │  │  ┈┈ Spend/Revenue Ratio %                        │ │
│  │  │                    +14.5% YoY  │     │  │                                                  │ │
│  │  │                    ~~~~~~      │     │  │  $5M ┌─────────────────────────────────┐  70%   │ │
│  │  └─────────────────────────────────┘     │  │      │  ●───●───●───●───●───●───●───●  │        │ │
│  │  ┌─────────────────────────────────┐     │  │  $4M │  ○───○───○───○───○───○───○───○  │  60%   │ │
│  │  │  Spend Growth      +14.5%      │     │  │      │                                  │        │ │
│  │  │  (Rev Growth:      +12.3%)     │     │  │  $3M │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈  │  55%   │ │
│  │  │                    ▲           │     │  │      │          ░░░░░░░░░               │        │ │
│  │  └─────────────────────────────────┘     │  │  $2M │     (overspend zone shaded)     │  50%   │ │
│  │  ┌─────────────────────────────────┐     │  │      └─────────────────────────────────┘        │ │
│  │  │  Spend/Rev Ratio   54.9%       │     │  │     Jan  Feb  Mar  Apr  May  Jun  Jul  Aug       │ │
│  │  │                    +1.1 pp YoY │     │  │                                                  │ │
│  │  │                    ~~~~~~      │     │  │  ⚠ Apr-May: Ratio spiked to 62% (investigate)   │ │
│  │  └─────────────────────────────────┘     │  │                                                  │ │
│  │  ┌─────────────────────────────────┐     │  │  🟧 Toggle – Monthly / Quarterly                 │ │
│  │  │  Procurement Freight  $1.2M    │     │  │                                                  │ │
│  │  │                    +8.3% YoY   │     │  │                                                  │ │
│  │  └─────────────────────────────────┘     │  │                                                  │ │
│  │                                          │  │                                                  │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟥 Filter – Product Category | Vendor              │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: VENDOR SPEND CONCENTRATION                                                       Q2        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Vendor Pareto Chart                      │  │ Volume vs Price Scatter Plot                     │ │
│  │                                          │  │                                                  │ │
│  │  Vendors in top 80%: 8 of 104 (7.7%)    │  │  ● = Vendor (size = spend)                      │ │
│  │  Top vendor: 18.2% │ CR5: 62.4%         │  │  Color = Credit Rating                           │ │
│  │                                          │  │                                                  │ │
│  │  Spend                          Cum%     │  │  🚨 Expensive │ ⚠️ Vol w/o leverage              │ │
│  │  $5M ┌──────────────────────┐  100%     │  │    niche      │                                  │ │
│  │      │ ██                   │           │  │               │                                  │ │
│  │  $4M │ ██ ██                │   80%     │  │ $50 ┌────────┼──────────────────────┐            │ │
│  │      │ ██ ██ ██   ──────────│─ ─ ─      │  │     │  ●     │              ●       │            │ │
│  │  $3M │ ██ ██ ██ ██         │   60%     │  │ Avg │  ● ●   │    ●                 │            │ │
│  │      │ ██ ██ ██ ██ ██      │           │  │ Prc │────────┼──────────────────────│            │ │
│  │  $2M │ ██ ██ ██ ██ ██ ██   │   40%     │  │     │        │  ●         ●         │            │ │
│  │      │ ██ ██ ██ ██ ██ ██ ██│           │  │ $20 │  ●     │    ●    ●   ●  ●     │            │ │
│  │  $1M │ ██ ██ ██ ██ ██ ██ ██│   20%     │  │     └────────┴──────────────────────┘            │ │
│  │      │ ██ ██ ██ ██ ██ ██ ██│           │  │     0       Median           100K                 │ │
│  │   0  └──────────────────────┘    0%     │  │              Purchase Volume (qty)                │ │
│  │      V1  V2  V3  V4  V5  V6 ...        │  │                                                  │ │
│  │                                          │  │  ── Regression line (expected: negative slope)   │ │
│  │  Bar color = Credit Rating gradient      │  │                                                  │ │
│  │  ── Cumulative % line                    │  │  ✅ Best deal (BtmR) │ ─ Small & cheap (BtmL)   │ │
│  │                                          │  │                                                  │ │
│  │  🟧 Toggle – Top N (10/20/All)           │  │  🟧 Toggle – Product / Vendor granularity        │ │
│  │  🟥 Filter – Credit Rating | Preferred   │  │  🟥 Filter – Credit Rating | Product Category    │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: COST OF QUALITY — REJECTION ANALYSIS                                             Q3        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Rejection Cost KPI Cards                 │  │ Rejection by Vendor & Product                    │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────────────────────────────┐     │  │  ─── By Vendor (Top 10 by Rejected $) ─────     │ │
│  │  │  Total Rejection    $482K      │     │  │                                                  │ │
│  │  │  Cost               +18% YoY  │     │  │  Vendor A █████████████████████  $112K  6.2%     │ │
│  │  └─────────────────────────────────┘     │  │  Vendor B ████████████████       $89K  4.8%     │ │
│  │  ┌─────────────────────────────────┐     │  │  Vendor C ████████████           $67K  3.1%     │ │
│  │  │  Rejection Rate     3.4%       │     │  │  Vendor D █████████              $52K  7.5%     │ │
│  │  │                    +0.6 pp YoY │     │  │  Vendor E ███████                $41K  2.8%     │ │
│  │  │  ⚠ TRENDING UP                │     │  │  Vendor F █████                  $33K  8.1%     │ │
│  │  └─────────────────────────────────┘     │  │  Vendor G ████                   $28K  2.1%     │ │
│  │  ┌─────────────────────────────────┐     │  │  Vendor H ███                    $22K  5.4%     │ │
│  │  │  % of Total Spend  1.9%       │     │  │  Vendor I ██                     $18K  1.9%     │ │
│  │  │                    +0.3 pp YoY │     │  │  Vendor J ██                     $15K  3.3%     │ │
│  │  └─────────────────────────────────┘     │  │                                                  │ │
│  │                                          │  │  Bar color = Rejection Rate gradient              │ │
│  │  Annualized rejection cost at            │  │  Labels: Rejected $ + Rejection Rate %            │ │
│  │  current rate: ~$640K                    │  │                                                  │ │
│  │                                          │  │  🟧 Toggle – By Vendor / By Product Category     │ │
│  │  🟥 Filter – Vendor                      │  │  🟧 Toggle – Top N (5/10/All)                    │ │
│  │  🟥 Filter – Product Category            │  │  🟥 Filter – Credit Rating | Preferred           │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: VENDOR SCORECARD & DETAIL TABLE                                                  Q1-Q3     │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Vendor Scorecard (Radar Chart)           │  │ Procurement Detail Table                         │ │
│  │                                          │  │                                                  │ │
│  │  Select Vendor: [ Vendor A        ▼]    │  │  Vendor │Spend │%Tot│AvgPrc│Vol │Rej$ │Rej%│Rtg │ │
│  │                                          │  │  ───────┼──────┼────┼──────┼────┼─────┼────┼────│ │
│  │          Spend Volume                    │  │  Vnd A  │$4.5M │18% │$42   │107K│$112K│6.2%│ 2  │ │
│  │              ●─────●                     │  │  Vnd B  │$3.8M │15% │$35   │109K│ $89K│4.8%│ 1  │ │
│  │           ╱      ╲                       │  │  Vnd C  │$3.2M │13% │$38   │ 84K│ $67K│3.1%│ 2  │ │
│  │  Reliability       Price                 │  │  Vnd D  │$2.1M │ 8% │$51   │ 41K│ $52K│7.5%│ 4  │ │
│  │       ●─────────────────●                │  │  ...    │...   │... │...   │... │...  │... │... │ │
│  │           ╲      ╱                       │  │                                                  │ │
│  │            ●─────●                       │  │  ⚠ Vendor D: Rej Rate 7.5% → Quality alert      │ │
│  │       Quality   Credit                   │  │  ⚠ Vendor A: Top spend + Rej Rate > 5%          │ │
│  │              Rating                      │  │    → Key vendor quality concern                   │ │
│  │                                          │  │                                                  │ │
│  │  ■ Selected vendor  ┈ Overall average    │  │  + Price Chg vs PY ($) │ Price Chg vs PY (%)    │ │
│  │                                          │  │  + Freight $  │ Spend Rank │ Preferred?          │ │
│  │  Spend:     $4.5M                        │  │                                                  │ │
│  │  Avg Price: $42.30                       │  │  ► Click vendor row → expand product breakdown   │ │
│  │  Rej Rate:  6.2%                         │  │                                                  │ │
│  │  Rating:    Excellent (2)                │  │  Sortable │ Conditional formatting               │ │
│  │  Preferred: Yes                          │  │  🟧 Toggle – Vendor / Product view               │ │
│  │                                          │  │  🟥 Filter – Credit Rating | Product Category    │ │
│  │  🟧 Dropdown – Select Vendor             │  │  🟥 Filter – Preferred Vendor                    │ │
│  │                                          │  │  → Export: CSV / Excel                           │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_purchase` | Fact — grain: PO line item. Spend (`line_total`), quantities (`order_qty`, `received_qty`, `rejected_qty`, `stocked_qty`), `unit_price`, `rejected_amount`, order-level amounts |
| `dim_vendor` | Vendor attributes: `vendor_name`, `credit_rating` (1-5), `credit_rating_desc`, `is_preferred_vendor`, `is_active` |
| `dim_product` | Product hierarchy for procurement: `product_category_name`, `product_subcategory_name`, `standard_cost` |
| `dim_date` | Calendar year, quarter, month — for spend trending |
| `fct_sale` | Cross-reference: Revenue for spend-to-revenue ratio |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Procurement Spend | `fct_purchase.line_total` (line level), `order_sub_total` (order level) |
| Unit Price | `fct_purchase.unit_price` |
| Order Volume | `fct_purchase.order_qty` |
| Received | `fct_purchase.received_qty` |
| Rejected | `fct_purchase.rejected_qty`, `fct_purchase.rejected_amount` |
| Stocked | `fct_purchase.stocked_qty` (= received − rejected) |
| Freight (Purchase) | `fct_purchase.order_freight_amount` (order-level, needs DISTINCT dedup) |
| Tax (Purchase) | `fct_purchase.order_tax_amount` (order-level, needs DISTINCT dedup) |
| Vendor | `dim_vendor.vendor_name`, `credit_rating`, `credit_rating_desc`, `is_preferred_vendor` |
| Revenue (cross-ref) | `fct_sale.line_total` (for spend/revenue ratio) |

### **Key Calculations**
```sql
-- =====================================================
-- ROW 1: Spend vs Revenue Trend
-- =====================================================

-- Total Procurement Spend
Total_Spend = SUM(fp.line_total)

-- Spend-to-Revenue Ratio
Spend_Revenue_Ratio = SUM(fp.line_total) / NULLIF(SUM(fs.line_total), 0) * 100

-- Monthly Spend vs Revenue
SELECT
    d.year_month,
    SUM(fp.line_total)                                           AS procurement_spend,
    (SELECT SUM(fs2.line_total)
     FROM fct_sale fs2
     JOIN dim_date d2 ON fs2.order_date_key = d2.date_key
     WHERE d2.year_month = d.year_month)                         AS revenue,
    SUM(fp.line_total) / NULLIF(
        (SELECT SUM(fs2.line_total)
         FROM fct_sale fs2
         JOIN dim_date d2 ON fs2.order_date_key = d2.date_key
         WHERE d2.year_month = d.year_month), 0) * 100           AS spend_rev_ratio
FROM fct_purchase fp
JOIN dim_date d ON fp.order_date_key = d.date_key
GROUP BY d.year_month
ORDER BY d.year_month

-- Procurement Freight (order-level dedup)
SELECT SUM(order_freight_amount) 
FROM (
    SELECT DISTINCT purchase_order_id, order_freight_amount
    FROM fct_purchase
) t


-- =====================================================
-- ROW 2: Vendor Spend Concentration & Volume vs Price
-- =====================================================

-- Vendor Pareto
SELECT
    dv.vendor_name,
    dv.credit_rating,
    dv.credit_rating_desc,
    dv.is_preferred_vendor,
    SUM(fp.line_total)                                           AS vendor_spend,
    SUM(fp.line_total) * 100.0 / SUM(SUM(fp.line_total)) OVER() AS pct_of_total,
    SUM(SUM(fp.line_total)) OVER (ORDER BY SUM(fp.line_total) DESC
        ROWS UNBOUNDED PRECEDING) * 100.0 
        / SUM(SUM(fp.line_total)) OVER()                         AS cumulative_pct
FROM fct_purchase fp
JOIN dim_vendor dv ON fp.dim_vendor_sk = dv.dim_vendor_sk
JOIN dim_date d ON fp.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dv.vendor_name, dv.credit_rating, dv.credit_rating_desc, dv.is_preferred_vendor
ORDER BY vendor_spend DESC

-- CR5 (Concentration Ratio — top 5 vendors)
-- = SUM of pct_of_total for top 5 vendors

-- Volume vs Price Scatter
SELECT
    dv.vendor_name,
    dv.credit_rating_desc,
    SUM(fp.order_qty)                                            AS purchase_volume,
    AVG(fp.unit_price)                                           AS avg_unit_price,
    SUM(fp.line_total)                                           AS total_spend,
    SUM(fp.rejected_qty) * 100.0 / NULLIF(SUM(fp.received_qty), 0) AS rejection_rate
FROM fct_purchase fp
JOIN dim_vendor dv ON fp.dim_vendor_sk = dv.dim_vendor_sk
JOIN dim_date d ON fp.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dv.vendor_name, dv.credit_rating_desc


-- =====================================================
-- ROW 3: Cost of Quality — Rejected Materials
-- =====================================================

-- Rejection KPIs
Total_Rejection_Cost = SUM(fp.rejected_amount)
Rejection_Rate       = SUM(fp.rejected_qty) / NULLIF(SUM(fp.received_qty), 0) * 100
Rejection_Pct_Spend  = SUM(fp.rejected_amount) / NULLIF(SUM(fp.line_total), 0) * 100

-- Top Vendors by Rejection Cost
SELECT
    dv.vendor_name,
    dv.credit_rating_desc,
    dv.is_preferred_vendor,
    SUM(fp.rejected_amount)                                      AS rejection_cost,
    SUM(fp.rejected_qty)                                         AS rejected_volume,
    SUM(fp.received_qty)                                         AS received_volume,
    SUM(fp.rejected_qty) * 100.0 / NULLIF(SUM(fp.received_qty), 0) AS rejection_rate_pct,
    SUM(fp.rejected_amount) * 100.0 / SUM(SUM(fp.rejected_amount)) OVER() AS pct_of_total_rejection
FROM fct_purchase fp
JOIN dim_vendor dv ON fp.dim_vendor_sk = dv.dim_vendor_sk
JOIN dim_date d ON fp.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dv.vendor_name, dv.credit_rating_desc, dv.is_preferred_vendor
ORDER BY rejection_cost DESC
LIMIT 10

-- By Product Category
SELECT
    dp.product_category_name,
    SUM(fp.rejected_amount)                                      AS rejection_cost,
    SUM(fp.rejected_qty) * 100.0 / NULLIF(SUM(fp.received_qty), 0) AS rejection_rate_pct
FROM fct_purchase fp
JOIN dim_product dp ON fp.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fp.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dp.product_category_name
ORDER BY rejection_cost DESC


-- =====================================================
-- ROW 4: Vendor Scorecard & Detail Table
-- =====================================================

-- Vendor Scorecard (percentile rank per dimension)
WITH vendor_metrics AS (
    SELECT
        dv.vendor_name,
        SUM(fp.line_total)                                       AS spend,
        AVG(fp.unit_price)                                       AS avg_price,
        SUM(fp.rejected_qty) * 100.0 
            / NULLIF(SUM(fp.received_qty), 0)                    AS rejection_rate,
        dv.credit_rating,
        SUM(fp.stocked_qty) * 100.0 
            / NULLIF(SUM(fp.order_qty), 0)                       AS fulfillment_rate
    FROM fct_purchase fp
    JOIN dim_vendor dv ON fp.dim_vendor_sk = dv.dim_vendor_sk
    JOIN dim_date d ON fp.order_date_key = d.date_key
    WHERE d.calendar_year = 2014
    GROUP BY dv.vendor_name, dv.credit_rating
)
SELECT
    vendor_name,
    -- Spend Volume (higher = bigger = higher percentile)
    PERCENT_RANK() OVER (ORDER BY spend) * 100           AS spend_score,
    -- Price Competitiveness (lower price = higher score, so invert)
    (1 - PERCENT_RANK() OVER (ORDER BY avg_price)) * 100 AS price_score,
    -- Quality (lower rejection = higher score, so invert)
    (1 - PERCENT_RANK() OVER (ORDER BY rejection_rate)) * 100 AS quality_score,
    -- Credit Rating (1=Superior→100, 5=Below Average→20)
    (6 - credit_rating) * 20                              AS credit_score,
    -- Reliability (higher fulfillment = higher score)
    PERCENT_RANK() OVER (ORDER BY fulfillment_rate) * 100 AS reliability_score
FROM vendor_metrics

-- Detail Table — Full Vendor Export
-- Combines: spend, volume, avg price, price change vs PY, 
--           rejection metrics, credit rating, preferred status, spend rank
-- Add PY comparison via self-join on prior calendar year
-- Expandable rows → product-level breakdown per vendor
```

### **Order-Level Deduplication Note**
`fct_purchase` order-level fields (`order_sub_total`, `order_tax_amount`, `order_freight_amount`, `order_total_due`) are repeated across line items of the same PO. When aggregating:
- **Line-level metrics** (spend, qty, rejection): use directly — `SUM(line_total)`, `SUM(order_qty)`
- **Order-level metrics** (freight, tax): deduplicate first — `SELECT DISTINCT purchase_order_id, order_freight_amount` then aggregate

### **Differentiation: Finance vs SCM Purchasing**
| Aspect | Finance (This Dashboard) | SCM Purchasing Efficiency |
|--------|--------------------------|--------------------------|
| **Primary metric** | Spend $ (monetary value) | Lead time (days) |
| **Vendor evaluation** | Cost, price trend, spend concentration | Delivery timeliness, fulfillment rate |
| **Quality lens** | Rejection cost $ (wasted spend) | Rejection rate % (operational defect) |
| **Key question** | "Are we spending wisely?" | "Are vendors delivering reliably?" |
| **Pareto focus** | Spend concentration risk | — |
| **Scatter plot** | Volume vs Price (pricing leverage) | Volume vs Lead Time (speed) |
| **Ratio** | Spend-to-Revenue | — |

### **Cross-Dashboard Navigation**
| From This Dashboard | Drill To | Purpose |
|---------------------|----------|---------|
| Spend/Revenue ratio spike month | Cost Structure (#3) | See which cost components drove the spike |
| High-rejection vendor | SCM Purchasing Efficiency | Investigate delivery patterns, lead time for that vendor |
| Vendor with price increase | Product Portfolio (#7) | Check impact on product COGS and margin |
| Overall spend trend | Financial Overview (#1) | Full P&L context — how procurement fits total cost picture |
| High-spend + low-quality vendor | Profitability (#4) | Margin impact of vendor quality issues on sold products |

### **Key Insight: Vendor Evaluation Framework**
```
Vendor Financial Health Matrix:
┌───────────────────┬──────────────────────┬────────────────────────┐
│                   │ Low Rejection (< 2%) │ High Rejection (> 5%)  │
├───────────────────┼──────────────────────┼────────────────────────┤
│ Competitive Price │ ✅ STRATEGIC PARTNER  │ ⚠ QUALITY REMEDIATION  │
│ (below median)    │  Grow volume          │  Fix quality or switch  │
├───────────────────┼──────────────────────┼────────────────────────┤
│ Expensive Price   │ ⚠ PRICE RENEGOTIATE  │ 🚨 EXIT / REPLACE      │
│ (above median)    │  Good quality, push   │  Expensive + bad quality│
│                   │  for better pricing   │  → immediate action     │
└───────────────────┴──────────────────────┴────────────────────────┘

Action triggers:
• CRs (top 5) > 70% spend → concentration risk → diversify
• Preferred vendor with rejection > 5% → review preferred status
• Vendor price increase > 10% YoY → escalate to procurement director
```
