# Profitability Analysis & Margin Dashboard

**Overall Objective:** Analyse gross margin dynamics across time, product dimensions, and sales channels — track margin compression/expansion trends, identify margin leaders vs laggards by category, and quantify the impact of discounting on margin erosion to support pricing and portfolio decisions.

---

## BUSINESS QUESTIONS ADDRESSED

1. What is the gross margin trend across time periods, and which quarters show margin compression or expansion?
2. Which product categories and subcategories are margin leaders vs. margin laggards, and how has this ranking changed over time?
3. How do discounts and pricing strategies affect margin by channel, and is there evidence of margin erosion from excessive discounting?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               Profitability Analysis & Margin Dashboard                               │
│                                                                                                      │
│  Drill-down from Financial Overview (#1);                                                            │
│  feeds into Product Portfolio (#7) for product-level pricing corrections                             │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Margin KPI      │ Quarterly Gross Margin Trend         │                                   │
│          │ Cards           │   (Multi-Year)                       │  • Headline profitability pulse:  │
│ Margin   │                 │                                      │    GP amount + GM% + direction    │
│  Trend   │  Gross Profit   │   GM% per Quarter (Line)             │  • Quarterly view to spot margin  │
│          │  Gross Margin % │   + GP Amount (Bar)                  │    compression or expansion       │
│          │  GP Growth YoY  │   + Prior Year overlay               │  • Compression = GM% declining   │
│          │  + Sparklines   │   + Compression/Expansion labels     │    while revenue grows            │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Category Margin │ Category Margin Ranking Over Time    │                                   │
│ Product  │ Leaderboard     │                                      │  • Current snapshot: which cats   │
│ Margin   │                 │   Bump Chart (Rank by GM%) or        │    generate most profitable $     │
│ Leaders  │  Table: Cat |   │   Small Multiples (GM% line per cat) │  • Ranking shift over time:       │
│  vs      │  Revenue | GP | │                                      │    who's rising, who's falling    │
│ Laggards │  GM% | Rank |   │   Highlight: rank changes ≥ 2       │  • Subcategory drill for detail   │
│          │  Rank Chg       │   positions since prior year         │                                   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Discount vs     │ Margin by Channel                    │                                   │
│ Discount │ Margin          │   (Internet vs Reseller)             │  • Scatter: is more discounting   │
│  Impact  │ Scatter Plot    │                                      │    = lower margin? (correlation)  │
│  &       │                 │   Side-by-side: GM%, Avg Discount,   │  • Channel comparison: which      │
│ Channel  │  X = Discount%  │   Discount Penetration, Revenue      │    channel more profitable and    │
│          │  Y = Margin %   │   + Monthly trend per channel        │    how is discount behaviour      │
│          │  Size = Revenue │                                      │    different between them          │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Margin          │ Profitability Detail Table            │                                   │
│  Detail  │ Distribution    │                                      │  • Histogram: how many products   │
│  Break-  │ Histogram       │   Monthly: Revenue | COGS | GP |     │    fall in each margin band        │
│  down    │                 │   GM% | Discount | Channel |          │  • Identify the "danger zone" —  │
│          │  X = GM% bands  │   Rank | vs PY                       │    high-rev + low-margin items    │
│          │  Y = Product    │                                      │  • Full export for finance review │
│          │      Count      │                                      │                                   │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (from fct_sale + dim_product + dim_date)
- ◻ Intermediate metric (derived from multiple fields)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Quarterly**

**"Global Filters"** govern the data that feeds into the dashboard — default shows YTD with quarterly granularity (margin analysis benefits from quarterly smoothing).

```
Global Filters:     │ Timeframe: XX - YY            │
                    │ Sales Channel                  │
                    │ Product Category / Subcategory │
                    │ Territory Group                │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Margin KPI Cards + Quarterly Gross Margin Trend

| Cell | Spec |
|------|------|
| **Margin KPI Cards** | 3 Headline Cards + Sparklines |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | **Card 1 — Gross Profit**: `SUM(line_total) − SUM(standard_cost × order_qty)` + YoY% |
| | **Card 2 — Gross Margin %**: `GP / Revenue × 100` + YoY delta (pp) + Sparkline (last 12M) |
| | **Card 3 — GP Growth YoY %**: `(GP_YTD − PY_GP_YTD) / PY_GP_YTD × 100` + direction arrow |
| | Conditional: GM% green > 40%, yellow 35-40%, red < 35% |
| | Sub-metric on Card 2: Compression/Expansion label |
| | — Compression = GM% decreased while Revenue increased |
| | — Expansion = GM% increased |

| Cell | Spec |
|------|------|
| **Quarterly Gross Margin Trend (Multi-Year)** | Combo Chart: GP (Bar) + GM% (Line) + PY GM% (Dashed) |
| | Timeframe: Full Range (all years) |
| | Measurement Range: Quarterly Total / Quarterly % |
| | Source: fct_sale + dim_product + dim_date |
| | Bars: `Gross_Profit = SUM(line_total) − SUM(standard_cost × order_qty)` per quarter |
| | Line: `GM% = GP / SUM(line_total) × 100` per quarter |
| | Dashed: Prior Year same-quarter GM% |
| | Annotation: |
| | — ▲ Green label on quarters where GM% > PY same quarter (expansion) |
| | — ▼ Red label on quarters where GM% < PY same quarter (compression) |
| | — Quantify: "+1.2 pp" or "-0.8 pp" delta |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |

---

### ROW 2: Category Margin Leaderboard + Ranking Over Time

| Cell | Spec |
|------|------|
| **Category Margin Leaderboard** | Ranked Table with Conditional Formatting |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product |
| | Columns: |
| | — Rank (by GM%) |
| | — Category Name |
| | — Revenue |
| | — COGS |
| | — Gross Profit |
| | — GM% |
| | — GM% PY |
| | — GM% Change (pp) |
| | — Rank Change (vs PY: ▲+2, ▼-1, ─ same) |
| | Sorted by: GM% descending |
| | Conditional formatting: GM% column (green/yellow/red gradient) |
| | Expandable rows: Click category → show subcategories within |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Toggle – View by Category / Subcategory |

| Cell | Spec |
|------|------|
| **Category Margin Ranking Over Time** | Bump Chart (Rank Position) or Small Multiples |
| | Timeframe: Full Range |
| | Measurement Range: Quarterly |
| | Source: fct_sale + dim_product + dim_date |
| | **Option A — Bump Chart**: |
| | X-axis: Quarter (Q1'11 → Q4'14) |
| | Y-axis: Rank position (1 = top) inverted |
| | Lines: One per product_category_name, colored distinctly |
| | Highlight: Rank changes ≥ 2 positions (circle marker) |
| | **Option B — Small Multiples GM% Lines**: |
| | One mini-chart per category showing GM% over time |
| | Reference line at overall average GM% |
| | 🟧 Toggle – Chart type (Bump / Small Multiples) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |

---

### ROW 3: Discount vs Margin Scatter + Margin by Channel

| Cell | Spec |
|------|------|
| **Discount vs Margin Scatter Plot** | Scatter Plot with Quadrant Lines |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Per Product (or per Subcategory) |
| | Source: fct_sale + dim_product |
| | X-axis: `Avg_Discount_% = AVG(unit_price_discount) × 100` per product/subcategory |
| | Y-axis: `GM% = (SUM(line_total) − SUM(standard_cost × order_qty)) / SUM(line_total) × 100` |
| | Bubble size: `Revenue = SUM(line_total)` |
| | Bubble color: Product Category |
| | Quadrant lines: |
| | — Vertical: Average Discount % across all products |
| | — Horizontal: Average GM% across all products |
| | Quadrants: |
| | — Q1 (top-left): Low Discount + High Margin → ✅ "Stars" |
| | — Q2 (top-right): High Discount + High Margin → ⚠️ "Watch — discount may not be needed" |
| | — Q3 (bottom-left): Low Discount + Low Margin → ⚠️ "Cost issue — not discount driven" |
| | — Q4 (bottom-right): High Discount + Low Margin → 🚨 "Danger — margin erosion" |
| | Tooltip: Product/Subcategory name, Revenue, GM%, Avg Discount%, Order Count |
| | 🟧 Toggle – Granularity (Product / Subcategory / Category) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Margin by Channel (Internet vs Reseller)** | Side-by-Side Comparison + Monthly Trend |
| | Timeframe: YTD + Monthly trend |
| | Measurement Range: Cumulative (KPIs) + Monthly (trend) |
| | Source: fct_sale + dim_product + dim_date |
| | **Top Section — KPI Comparison Table**: |
| | Columns: Metric | Internet | Reseller | Delta |
| | Rows: Revenue, COGS, GP, GM%, Avg Discount %, Discount Penetration %, Order Count |
| | **Bottom Section — Monthly GM% Trend by Channel**: |
| | Lines: ── Internet GM% ── Reseller GM% |
| | Dashed: ┈┈ Overall GM% (reference) |
| | Annotation: highlight months where gap between channels widens > 5 pp |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |

---

### ROW 4: Margin Distribution Histogram + Profitability Detail Table

| Cell | Spec |
|------|------|
| **Margin Distribution Histogram** | Histogram + Reference Lines |
| | Timeframe: YTD |
| | Measurement Range: Per Product |
| | Source: fct_sale + dim_product |
| | X-axis: GM% bands (< 0%, 0-10%, 10-20%, 20-30%, 30-40%, 40-50%, 50%+) |
| | Y-axis: Count of distinct products |
| | Bars colored by category (stacked) or solid with reference lines |
| | Reference lines: |
| | — Overall average GM% (vertical dashed) |
| | — "Danger threshold" at 10% GM% (vertical red) |
| | KPI annotations above chart: |
| | — Products with GM% < 10%: XX (XX% of total) |
| | — Products with negative margin: XX |
| | — Median GM%: XX% |
| | 🟧 Toggle – Sales Channel |
| | 🟧 Toggle – Granularity (Product / Subcategory) |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Profitability Detail Table** | Full Detail Table; Sortable; Exportable |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per time grain |
| | Source: fct_sale + dim_product + dim_date |
| | **Time-grain view** (default: Monthly): |
| | Columns: Year-Month | Revenue | COGS | GP | GM% | Avg Discount % | Discount Amount | Disc Penetration % | PY GM% | GM% Change (pp) |
| | **Product view** (toggle): |
| | Columns: Category | Subcategory | Revenue | COGS | GP | GM% | Avg Discount % | Revenue Rank | Margin Rank | Gap (Rev Rank − Margin Rank) |
| | Features: |
| | — Sortable by any column |
| | — Conditional formatting: GM% gradient, Discount % threshold |
| | — Flag: products where Rev Rank ≤ 10 AND Margin Rank > 25 → "High-rev, low-margin alert" |
| | — Subtotal rows per Quarter (time view) or per Category (product view) |
| | 🟧 Toggle – View (Time / Product) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |
| | Export: CSV / Excel |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Quarterly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Sales Channel            │
  (e.g., category margin, product scatter)                │  Product Category         │
                                                          │  Territory Group          │
  Drill-through to Product Portfolio (#7)                 └──────────────────────────┘
  for product-level pricing corrections

  Legend:                                                      
  🟧 Filters for "Crawl"                                       
  🟥 Filters for "Walk/Run"                                     

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: MARGIN TREND                                                                     Q1        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Margin KPI Cards                         │  │  Quarterly Gross Margin Trend (Multi-Year)       │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────────────────────────────┐     │  │  ██ Gross Profit ($)   ── GM%   ┈┈ PY GM%       │ │
│  │  │  Gross Profit     $18.1M       │     │  │                                                  │ │
│  │  │                   +8.2% YoY    │     │  │ $6M ┌──────────────────────────────────┐  50%   │ │
│  │  │                   ~~~~~~       │     │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │        │ │
│  │  └─────────────────────────────────┘     │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │  45%   │ │
│  │  ┌─────────────────────────────────┐     │  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │        │ │
│  │  │  Gross Margin %   40.0%        │     │  │     │──●──●──●──●──●──●──●──●──●──── │  40%   │ │
│  │  │                   +1.2 pp YoY  │     │  │     │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈  │        │ │
│  │  │  ▲ EXPANSION      ~~~~~~       │     │  │ $0  └──────────────────────────────────┘  35%   │ │
│  │  └─────────────────────────────────┘     │  │     Q1   Q2   Q3   Q4   Q1   Q2   Q3   Q4      │ │
│  │  ┌─────────────────────────────────┐     │  │     '13  '13  '13  '13  '14  '14  '14  '14     │ │
│  │  │  GP Growth YoY    +8.2%        │     │  │                                                  │ │
│  │  │                   ▲            │     │  │     ▲+1.2pp  ▲+0.8pp  ▼-0.3pp  ▲+1.5pp         │ │
│  │  │                   ~~~~~~       │     │  │     (expansion / compression labels)              │ │
│  │  └─────────────────────────────────┘     │  │                                                  │ │
│  │                                          │  │                                                  │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Product Category | Territory Group      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: PRODUCT MARGIN LEADERS vs LAGGARDS                                               Q2        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Category Margin Leaderboard              │  │ Category Margin Ranking Over Time                │ │
│  │                                          │  │                                                  │ │
│  │  Rank│ Category   │ Revenue │ GP    │GM% │  │  Bump Chart: Rank by GM% per Quarter             │ │
│  │      │            │         │       │    │  │  (lower = better; rank 1 = top)                  │ │
│  │  ────┼────────────┼─────────┼───────┼────│  │                                                  │ │
│  │  1 ▲ │ Clothing   │ $5.4M   │$3.8M  │70% │  │  Rank                                           │ │
│  │  2 ─ │ Accessories│ $3.2M   │$1.9M  │59% │  │  1 ┌──────────────────────────────────────────┐ │ │
│  │  3 ▼ │ Components │$12.8M   │$4.6M  │36% │  │    │  ── Clothing  ── Accessories               │ │ │
│  │  4 ▲ │ Bikes      │$23.8M   │$7.8M  │33% │  │  2 │  ── Components  ── Bikes                   │ │ │
│  │      │            │         │       │    │  │    │  ●───────────●────●───────────●             │ │ │
│  │  GM% Change  │ Rank Chg │ PY GM%       │  │  3 │        ●────●     ●────●                    │ │ │
│  │  +2.1 pp     │ ▲ +1     │ 67.9%        │  │    │  ○─────────────────────○───────○             │ │ │
│  │  +0.3 pp     │ ─  0     │ 58.7%        │  │  4 │  ○──○──○──○──○──○──○──○──○──○               │ │ │
│  │  -1.5 pp     │ ▼ -1     │ 37.5%        │  │    └──────────────────────────────────────────┘ │ │
│  │  +0.8 pp     │ ▲ +1     │ 32.2%        │  │     Q1'11  Q1'12  Q1'13  Q1'14                    │ │
│  │                                          │  │                                                  │ │
│  │  ► Click category to expand subcats      │  │  🟧 Toggle – Bump Chart / Small Multiples        │ │
│  │                                          │  │                                                  │ │
│  │  🟧 Toggle – Channel                     │  │                                                  │ │
│  │  🟥 Toggle – Category / Subcategory      │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Territory Group                         │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: DISCOUNT IMPACT & CHANNEL PROFITABILITY                                          Q3        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Discount vs Margin Scatter Plot          │  │ Margin by Channel (Internet vs Reseller)         │ │
│  │                                          │  │                                                  │ │
│  │  ● = Product (size = revenue)            │  │  ┌─ KPI Comparison ─────────────────────────┐   │ │
│  │  Color = Category                        │  │  │  Metric       │ Internet│ Reseller│ Delta │   │ │
│  │                                          │  │  │  Revenue      │ $27.1M  │ $18.1M  │ +$9M  │   │ │
│  │  ✅ Stars    │ ⚠️ Watch                   │  │  │  GM%          │  43.9%  │  34.3%  │+9.6pp │   │ │
│  │  (Low disc   │ (High disc                │  │  │  Avg Disc %   │   3.2%  │   6.8%  │-3.6pp │   │ │
│  │   High marg) │  High marg)               │  │  │  Disc Penet.  │  18.5%  │  42.1%  │-23.6pp│   │ │
│  │ 60% ┌────────┼──────────────────┐        │  │  └───────────────────────────────────────────┘   │ │
│  │     │   ●    │  ●               │        │  │                                                  │ │
│  │ GM% │  ● ●   │    ●  ●          │        │  │  Monthly GM% Trend by Channel                    │ │
│  │ 40% │────────┼──────────────────│        │  │                                                  │ │
│  │     │        │   ●     ●        │        │  │  ── Internet  ── Reseller  ┈┈ Overall            │ │
│  │     │  ⚠️Cost│  🚨 Danger       │        │  │                                                  │ │
│  │ 20% │  issue │  zone            │        │  │ 50% ┌──────────────────────────────────┐        │ │
│  │     │        │     ●            │        │  │     │  ●───●───●───●───●───●───●───●  │        │ │
│  │  0% └────────┴──────────────────┘        │  │ 40% │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈  │        │ │
│  │     0%    5%    10%   15%   20%          │  │     │  ○───○───○───○───○───○───○───○  │        │ │
│  │              Avg Discount %               │  │ 30% └──────────────────────────────────┘        │ │
│  │                                          │  │     Jan  Feb  Mar  Apr  May  Jun  Jul  Aug       │ │
│  │  🟧 Toggle – Product / Subcat / Cat      │  │                                                  │ │
│  │  🟧 Toggle – Channel                     │  │  ⚠ Gap widened to 12pp in Jun (investigate)     │ │
│  │  🟥 Filter – Product Category             │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟥 Filter – Product Category | Territory Group      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: MARGIN DISTRIBUTION & DETAIL TABLE                                               Q1-Q3     │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Margin Distribution Histogram            │  │ Profitability Detail Table                       │ │
│  │                                          │  │                                                  │ │
│  │  Products w/ GM% < 10%: 12 (4.8%)       │  │  🟧 Toggle – Time View / Product View            │ │
│  │  Negative margin: 3 │ Median GM%: 38%   │  │                                                  │ │
│  │                                          │  │  ─── Time View (Monthly) ──────────────────────  │ │
│  │  Count                                   │  │  Year-Mth│Rev  │COGS │ GP  │GM% │Disc%│PY GM%│Δ │ │
│  │  80 ┌──────────────────────────────────┐ │  │  ────────┼─────┼─────┼─────┼────┼─────┼──────┼──│ │
│  │     │                    ████          │ │  │  2014-Jan│$3.8M│$2.3M│$1.5M│39.5│ 4.8%│38.2% │+1│ │
│  │  60 │               ████████          │ │  │  2014-Feb│$3.6M│$2.1M│$1.5M│41.7│ 4.2%│39.8% │+2│ │
│  │     │          ████████████████       │ │  │  ...     │...  │...  │...  │... │...  │...   │..│ │
│  │  40 │     ████████████████████████    │ │  │                                                  │ │
│  │     │████████████████████████████████ │ │  │  ─── Product View ──────────────────────────────  │ │
│  │  20 │████████████████████████████████ │ │  │  Cat │ Subcat │Rev  │COGS │GP  │GM%│RevRk│MrgRk│ │
│  │     │████████████████████████████████ │ │  │  ─────┼────────┼─────┼─────┼────┼───┼─────┼─────│ │
│  │   0 └────────────────────────────────┘ │  │  Bikes│Mountain│$12M │$8.4M│$3.6│30%│  1  │  4  │ │
│  │     <0% 0-10 10-20 20-30 30-40 40-50 50+│  │  Bikes│Road    │$8.2M│$5.3M│$2.9│35%│  2  │  3  │ │
│  │              GM% Band                    │  │  🚨 High-rev + low-margin alert flagged          │ │
│  │                                          │  │                                                  │ │
│  │  ── Avg GM% (38%)  ── Danger (10%)       │  │  Sortable │ Subtotals │ Conditional formatting   │ │
│  │                                          │  │  → Export: CSV / Excel                           │ │
│  │  🟧 Toggle – Channel                     │  │                                                  │ │
│  │  🟧 Toggle – Product / Subcategory       │  │  🟧 Toggle – Channel                             │ │
│  │  🟥 Filter – Product Category            │  │  🟥 Filter – Product Category | Territory       │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact — grain: order line item. Revenue (`line_total`), quantity, unit price, discount |
| `dim_product` | Standard cost (for COGS), list price, category hierarchy (category → subcategory → product) |
| `dim_date` | Calendar year, quarter, month — for time-series margin analysis |
| `dim_sales_territory` | Territory group — filter only |
| `dim_customer` | Customer type — Internet/Reseller (derived via `sales_channel` in fct_sale) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `fct_sale.line_total` (after discount) |
| COGS | `dim_product.standard_cost × fct_sale.order_qty` |
| Gross Profit | `line_total − (standard_cost × order_qty)` |
| Gross Margin % | `GP / Revenue × 100` |
| Discount Rate | `fct_sale.unit_price_discount` (0.00 to 1.00) |
| Discount Amount | `fct_sale.unit_price × fct_sale.unit_price_discount × fct_sale.order_qty` |
| List Price | `dim_product.list_price` |
| Actual Selling Price | `fct_sale.unit_price` |
| Channel | `fct_sale.sales_channel` (Internet / Reseller) |
| Product Hierarchy | `dim_product.product_category_name` → `product_subcategory_name` → `product_name` |
| Product Attributes | `dim_product.product_line_code`, `dim_product.class_code` |

### **Key Calculations**
```sql
-- =====================================================
-- ROW 1: Margin Trend — KPI Cards & Quarterly Trend
-- =====================================================

-- Gross Profit & Margin
Revenue       = SUM(fs.line_total)
COGS          = SUM(dp.standard_cost * fs.order_qty)
Gross_Profit  = Revenue - COGS
GM_Pct        = Gross_Profit / NULLIF(Revenue, 0) * 100

-- YoY Change (percentage points)
GM_Pct_PY     = GM_Pct calculated for prior year same period
GM_Delta_pp   = GM_Pct - GM_Pct_PY    -- positive = expansion, negative = compression

-- Quarterly Trend
SELECT
    d.calendar_year,
    d.calendar_quarter,
    SUM(fs.line_total)                                       AS revenue,
    SUM(dp.standard_cost * fs.order_qty)                     AS cogs,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty) AS gross_profit,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                AS gm_pct
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
GROUP BY d.calendar_year, d.calendar_quarter

-- Compression/Expansion Detection
-- Compression: GM% decreased AND Revenue increased vs PY same quarter
-- Expansion: GM% increased vs PY same quarter


-- =====================================================
-- ROW 2: Category Margin Leaders vs Laggards
-- =====================================================

-- Category Leaderboard
SELECT
    dp.product_category_name,
    SUM(fs.line_total)                                         AS revenue,
    SUM(dp.standard_cost * fs.order_qty)                       AS cogs,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS gross_profit,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct,
    RANK() OVER (ORDER BY 
        (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) DESC)                  AS margin_rank
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
WHERE d.calendar_year = 2014   -- current year
GROUP BY dp.product_category_name

-- Ranking Over Time (Bump Chart data)
-- Same query but GROUP BY calendar_year, calendar_quarter, product_category_name
-- Then RANK() OVER (PARTITION BY year, quarter ORDER BY gm_pct DESC)

-- Subcategory Drill-down
-- Replace product_category_name with product_subcategory_name
-- Add WHERE product_category_name = <selected>


-- =====================================================
-- ROW 3: Discount vs Margin & Channel Profitability
-- =====================================================

-- Scatter Plot Data (per product or subcategory)
SELECT
    dp.product_subcategory_name,
    dp.product_category_name,
    SUM(fs.line_total)                                         AS revenue,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct,
    AVG(fs.unit_price_discount) * 100                           AS avg_discount_pct,
    COUNT(DISTINCT fs.sales_order_id)                           AS order_count
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
GROUP BY dp.product_subcategory_name, dp.product_category_name

-- Quadrant Reference Lines
Avg_Discount_All = AVG(unit_price_discount) * 100  -- across all products
Avg_GM_All       = overall GM%

-- Channel Comparison
SELECT
    fs.sales_channel,
    SUM(fs.line_total)                                         AS revenue,
    SUM(dp.standard_cost * fs.order_qty)                       AS cogs,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct,
    AVG(fs.unit_price_discount) * 100                           AS avg_discount_pct,
    COUNT(DISTINCT CASE WHEN fs.unit_price_discount > 0 
          THEN fs.sales_order_id END) * 100.0
        / COUNT(DISTINCT fs.sales_order_id)                     AS discount_penetration_pct
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
GROUP BY fs.sales_channel

-- Monthly GM% by Channel
SELECT
    d.year_month,
    fs.sales_channel,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100 AS gm_pct
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
GROUP BY d.year_month, fs.sales_channel


-- =====================================================
-- ROW 4: Distribution & Detail Table
-- =====================================================

-- Margin Distribution Histogram (per product)
WITH product_margin AS (
    SELECT
        dp.product_name,
        dp.product_category_name,
        (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
            / NULLIF(SUM(fs.line_total), 0) * 100 AS gm_pct
    FROM fct_sale fs
    JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
    GROUP BY dp.product_name, dp.product_category_name
)
SELECT
    CASE
        WHEN gm_pct < 0  THEN '< 0%'
        WHEN gm_pct < 10 THEN '0-10%'
        WHEN gm_pct < 20 THEN '10-20%'
        WHEN gm_pct < 30 THEN '20-30%'
        WHEN gm_pct < 40 THEN '30-40%'
        WHEN gm_pct < 50 THEN '40-50%'
        ELSE '50%+'
    END AS gm_band,
    COUNT(*) AS product_count
FROM product_margin
GROUP BY gm_band

-- Danger Zone Products (high revenue + low margin)
SELECT *
FROM product_margin
WHERE gm_pct < 10
ORDER BY revenue DESC

-- Detail Table — Time View
SELECT
    d.year_month,
    SUM(fs.line_total) AS revenue,
    SUM(dp.standard_cost * fs.order_qty) AS cogs,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty) AS gross_profit,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100 AS gm_pct,
    AVG(fs.unit_price_discount) * 100 AS avg_discount_pct,
    SUM(fs.unit_price * fs.unit_price_discount * fs.order_qty) AS discount_amount
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
GROUP BY d.year_month
ORDER BY d.year_month
```

### **Cross-Dashboard Navigation**
| From This Dashboard | Drill To | Purpose |
|---------------------|----------|---------|
| Category Leaderboard row | Product Portfolio (#7) | Product-level pricing gap and margin correction |
| Scatter "Danger Zone" point | Product Portfolio (#7) | Specific product pricing intervention |
| Channel GM% trend | Territory & Channel (#5) | See which territories drive channel margin gap |
| Margin compression quarter | Cost Structure (#3) | Investigate if COGS increase caused compression |
| Overall GM% KPI | Financial Overview (#1) | Full P&L context for margin changes |

### **Key Insight: Margin Compression Detection**
```
Compression = (GM%_current < GM%_prior) AND (Revenue_current > Revenue_prior)
→ Revenue is growing but profit margin is shrinking
→ Root causes to investigate:
   1. Discount escalation (check scatter plot, Q4 quadrant)
   2. Product mix shift toward low-margin categories (check leaderboard ranking shift)
   3. COGS increase (drill to Cost Structure #3)
```
