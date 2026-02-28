# Financial Overview Dashboard

**Overall Objective:** Provide a comprehensive P&L (Profit & Loss) snapshot for executive leadership — covering Revenue, COGS, Gross Profit, key operational charges (manufacturing cost, freight, tax), KPI trends, and channel-level financial performance split.

---

## BUSINESS QUESTIONS ADDRESSED

1. What is the overall financial performance (Revenue, COGS, Gross Profit, and key operational charges including manufacturing cost, freight, and tax) compared to prior-period benchmarks?
2. What are the key financial KPIs (Gross Margin %, AOV, Revenue per Unit, Cost-to-Revenue Ratio) trending over time, and are there any concerning inflection points?
3. How does the financial performance split between Internet and Reseller channels at a high level?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Financial Overview Dashboard                                       │
│                                                                                                      │
│  Executive-level P&L snapshot; drill-through to                                                      │
│  Revenue, Cost, and Profitability dashboards for detail                                              │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ P&L KPI Cards   │ P&L Waterfall                        │                                   │
│          │  Revenue        │   Revenue → COGS → Gross Profit      │  • CFO / CEO glanceable P&L      │
│   P&L    │  COGS           │   → Freight → Tax → Net Proxy        │    in < 30 seconds                │
│ Summary  │  Gross Profit   │                                      │  • Prior-period benchmarks        │
│          │  Net Proxy      │                                      │    (YoY, QoQ) on every KPI card   │
│          │  + Prior Period │                                      │  • Waterfall shows value flow     │
│          │    Comparisons  │                                      │    from Revenue to Net Proxy       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Monthly         │ Monthly Gross Margin % &             │                                   │
│  P&L     │ Revenue &       │ Cost-to-Revenue Ratio Trend          │  • Track P&L momentum monthly     │
│  Trends  │ Gross Profit    │                                      │  • Identify inflection points     │
│          │ Trend           │   + Prior Year Overlay               │    in margin or cost ratio         │
│          │                 │                                      │  • Spot margin compression or      │
│          │                 │                                      │    expansion early                 │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ AOV &           │ Operational Charges Breakdown         │                                   │
│   KPI    │ Revenue per     │   Manufacturing Cost                 │  • KPI health check — are AOV     │
│  Health  │ Unit Trend      │   Sales Freight                      │    and Rev/Unit improving?         │
│          │                 │   Sales Tax                          │  • Operational charges pie/donut   │
│          │                 │   Scrap Loss                         │    shows where money goes after    │
│          │                 │   Procurement Freight                │    gross profit                    │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Channel         │ Revenue & Gross Margin by Channel    │                                   │
│ Channel  │ Financial       │   Internet vs Reseller               │  • Quick comparison of financial   │
│  Split   │ Summary         │   Stacked bar (Revenue) +            │    health between two channels     │
│          │ Table           │   Line (GM%)                         │  • Identify which channel drives   │
│          │                 │                                      │    more profit, not just revenue    │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_sale + dim_product + dim_date)
- ◻ Intermediate metric (derived from multiple fact tables)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

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

### ROW 1: P&L KPI Cards + P&L Waterfall

| Cell | Spec |
|------|------|
| **P&L KPI Cards** | 4 Headline Cards with Prior-Period Comparison |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | **Card 1 — Revenue**: `SUM(line_total)` + YoY% + QoQ% |
| | **Card 2 — COGS**: `SUM(standard_cost × order_qty)` + YoY% |
| | **Card 3 — Gross Profit**: Revenue − COGS + YoY% |
| | **Card 4 — Net Proxy**: Gross Profit − Freight − Tax − Scrap Loss + YoY% |
| | Each card: Sparkline showing last 12 months trend |

| Cell | Spec |
|------|------|
| **P&L Waterfall Chart** | Waterfall; Vertical |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product + fct_workorder |
| | Bars: Revenue (green+) → COGS (red−) → **Gross Profit** (subtotal) → Mfg Cost (red−) → Sales Freight (red−) → Sales Tax (red−) → Scrap Loss (red−) → **Net Proxy** (subtotal) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Product Category |

---

### ROW 2: Monthly Revenue & Gross Profit Trend + Margin & Cost Ratio Trend

| Cell | Spec |
|------|------|
| **Monthly Revenue & Gross Profit Trend** | Combo Chart: Revenue (Bar) + Gross Profit (Bar) + Prior Year Revenue (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_product + dim_date |
| | `Revenue = SUM(line_total) GROUP BY year_month` |
| | `Gross_Profit = Revenue - SUM(standard_cost × order_qty) GROUP BY year_month` |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |

| Cell | Spec |
|------|------|
| **Monthly Gross Margin % & Cost-to-Revenue Ratio Trend** | Dual-Axis Line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_sale + dim_product + dim_date |
| | Left axis: `GM% = (Revenue - COGS) / Revenue × 100` |
| | Right axis: `Cost_Ratio = COGS / Revenue × 100` |
| | + Prior Year overlay (dashed lines) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

---

### ROW 3: AOV & Revenue per Unit Trend + Operational Charges Breakdown

| Cell | Spec |
|------|------|
| **AOV & Revenue per Unit Trend** | Dual-Axis Line Chart |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_sale + dim_date |
| | Left axis: `AOV = SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| | Right axis: `Rev_Per_Unit = SUM(line_total) / SUM(order_qty)` |
| | + Prior Year overlay (dashed lines) |
| | Annotation: highlight months with > 5% MoM drop |
| | 🟧 Toggle – Sales Channel |

| Cell | Spec |
|------|------|
| **Operational Charges Breakdown** | Donut Chart + Summary Table |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_sale + fct_purchase + fct_workorder + dim_product |
| | Segments: |
| | — Manufacturing Cost: `SUM(fct_workorder.total_actual_cost)` |
| | — Sales Freight: `SUM(fct_sale.order_freight_amount)` (dedup by order) |
| | — Sales Tax: `SUM(fct_sale.order_tax_amount)` (dedup by order) |
| | — Scrap Loss: `SUM(fct_workorder.scrapped_qty × dim_product.standard_cost)` |
| | — Procurement Freight: `SUM(fct_purchase.order_freight_amount)` (dedup by order) |
| | Center label: Total Charges + % of Revenue |
| | Table below: Component | Amount | % of Total | YoY Change |

---

### ROW 4: Channel Financial Summary + Revenue & GM by Channel

| Cell | Spec |
|------|------|
| **Channel Financial Summary** | Table; Headline Numbers + Comparison |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | Columns: Channel | Revenue | COGS | Gross Profit | GM% | AOV | Order Count | Prior Year Rev | YoY% |
| | Rows: Internet, Reseller, **Total** |
| | Conditional formatting: GM% (green > 40%, yellow 30-40%, red < 30%) |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Revenue & Gross Margin by Channel (Monthly)** | Combo Chart: Stacked Bar (Revenue by Channel) + Lines (GM% per Channel) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total (Revenue) and Monthly % (GM) |
| | Source: fct_sale + dim_product + dim_date |
| | Stacked bars: ██ Internet ██ Reseller |
| | Lines: ── Internet GM% ── Reseller GM% |
| | 🟧 Drop-Down Filter – Territory Group |
| | 🟥 Filter – Product Category |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Sales Channel            │
  (e.g., P&L component, channel, period)                  │  Territory Group          │
                                                          │  Product Category         │
  Align Dashboard permissions with existing               └──────────────────────────┘
  reporting (some users can't see margin details)

  Legend:                                                      
  🟧 Filters for "Crawl"                                       
  🟥 Filters for "Walk/Run"                                     

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: P&L SUMMARY                                                                                │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ P&L KPI Cards                            │  │  P&L Waterfall                                   │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────┐ ┌─────────┐                │  │  Revenue                                         │ │
│  │  │ Revenue │ │  COGS   │                │  │  ████████████████████████████████  $45.2M         │ │
│  │  │ $45.2M  │ │ $27.1M  │                │  │            COGS                                  │ │
│  │  │ +7% YoY │ │ +5% YoY │                │  │            ████████████████████  -$27.1M         │ │
│  │  │ ~~~~~~  │ │ ~~~~~~  │                │  │                    Gross Profit                   │ │
│  │  └─────────┘ └─────────┘                │  │                    ████████████  =$18.1M         │ │
│  │  ┌─────────┐ ┌─────────┐                │  │                       Mfg Cost                   │ │
│  │  │ Gross   │ │  Net    │                │  │                       ██████  -$4.2M             │ │
│  │  │ Profit  │ │  Proxy  │                │  │                         Freight                   │ │
│  │  │ $18.1M  │ │ $11.8M  │                │  │                         ████  -$1.3M             │ │
│  │  │ +8% YoY │ │ +6% YoY │                │  │                           Tax                    │ │
│  │  │ ~~~~~~  │ │ ~~~~~~  │                │  │                           ███  -$0.6M            │ │
│  │  └─────────┘ └─────────┘                │  │                            Scrap                  │ │
│  │                                          │  │                            ██  -$0.2M            │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │                             Net Proxy             │ │
│  │                                          │  │                             ███████  =$11.8M     │ │
│  │                                          │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟧 Toggle – Sales Channel                           │
│                                                 🟥 Filter – Product Category                        │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: P&L TRENDS                                                                                  │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Monthly Revenue & Gross Profit Trend     │  │ Gross Margin % & Cost-to-Revenue Ratio           │ │
│  │                                          │  │                                                  │ │
│  │  ██ Revenue  ██ Gross Profit  ── PY Rev  │  │  ── GM%   ── Cost Ratio   ┈┈ PY GM%             │ │
│  │                                          │  │                                                  │ │
│  │ $6M ┌──────────────────────────────────┐ │  │ 45% ┌──────────────────────────────────┐  65%  │ │
│  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │ │  │     │                                  │       │ │
│  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │ │  │     │  ●───●───●──●───●───●───●───●   │  60%  │ │
│  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │ │  │ 40% │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈   │       │ │
│  │     │ ██  ██  ██  ██  ██  ██  ██  ██  │ │  │     │                                  │  55%  │ │
│  │     │ ──●──●──●──●──●──●──●──●──●──── │ │  │ 35% │  ○───○───○──○───○───○───○───○   │       │ │
│  │ $0  │────────────────────────────────  │ │  │     │                                  │  50%  │ │
│  │     Jan Feb Mar Apr May Jun Jul Aug    │ │  │ 30% └──────────────────────────────────┘       │ │
│  │                                          │  │     Jan Feb Mar Apr May Jun Jul Aug              │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│  🟧 Toggle – Sales Channel                     🟧 Toggle – Sales Channel                           │
│  🟥 Filter – Territory Group                    🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: KPI HEALTH & OPERATIONAL CHARGES                                                            │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ AOV & Revenue per Unit Trend             │  │ Operational Charges Breakdown                    │ │
│  │                                          │  │                                                  │ │
│  │  ── AOV ($)   ── Rev/Unit ($)            │  │         ┌─────────────┐                          │ │
│  │  ┈┈ PY AOV    ┈┈ PY Rev/Unit             │  │     ┌───┤  Mfg Cost   ├───┐    Total Charges    │ │
│  │                                          │  │     │   │   66.7%     │   │    $6.3M            │ │
│  │ $4K ┌──────────────────────────┐ $200   │  │     │   └─────────────┘   │    = 13.9% of Rev   │ │
│  │     │                          │         │  │  ┌──┤                     ├──┐                   │ │
│  │     │  ●───●───●──●───●───●   │ $180   │  │  │  │  ┌───────────┐     │  │                   │ │
│  │ $3K │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈   │         │  │  │  └──┤ Freight   ├─────┘  │                   │ │
│  │     │                          │ $160   │  │  │     │  20.6%    │        │                   │ │
│  │     │  ○───○───○──○───○───○   │         │  │  │     └───────────┘        │                   │ │
│  │ $2K │  ┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈   │ $140   │  │  │  ┌──────┐ ┌──────┐      │                   │ │
│  │     │                          │         │  │  └──┤ Tax  ├─┤Scrap ├──────┘                   │ │
│  │     Jan Mar May Jul Sep Nov    │         │  │     │ 9.5% │ │ 3.2% │                          │ │
│  └──────────────────────────────────────────┘  │     └──────┘ └──────┘                          │ │
│                                                  │                                                  │ │
│  🟧 Toggle – Sales Channel                     │  Component   │ Amount │ % Total │ YoY Chg       │ │
│                                                  │  Mfg Cost    │ $4.2M  │  66.7%  │  +3%         │ │
│                                                  │  Freight     │ $1.3M  │  20.6%  │  +8%  ▲     │ │
│                                                  │  Tax         │ $0.6M  │   9.5%  │  +2%         │ │
│                                                  │  Scrap Loss  │ $0.2M  │   3.2%  │  -5%  ▼     │ │
│                                                  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: CHANNEL FINANCIAL SPLIT                                                                      │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Channel Financial Summary                │  │ Revenue & Gross Margin by Channel (Monthly)      │ │
│  │                                          │  │                                                  │ │
│  │           Revenue   COGS    GP     GM%   │  │  ██ Internet  ██ Reseller  ── Int GM%  ── Res GM%│ │
│  │           PY Rev    YoY%   AOV    Count  │  │                                                  │ │
│  │  ─────────────────────────────────────── │  │ $6M ┌──────────────────────────────────┐  50%   │ │
│  │  Internet │$27.1M │$15.2M│$11.9M│ 43.9% │  │     │ ████████████████████████████████ │        │ │
│  │           │$25.3M │+7.1% │$412  │ 6.5K  │  │     │ ████  ████  ████  ████  ████    │  40%   │ │
│  │  ─────────────────────────────────────── │  │     │ ████  ████  ████  ████  ████    │        │ │
│  │  Reseller │$18.1M │$11.9M│$6.2M │ 34.3% │  │     │ ████  ████  ████  ████  ████    │  30%   │ │
│  │           │$17.2M │+5.2% │$3.8K │ 4.8K  │  │     │──●──●──●──●──●──●──●──●──●──── │        │ │
│  │  ─────────────────────────────────────── │  │     │──○──○──○──○──○──○──○──○──○──── │  20%   │ │
│  │  TOTAL    │$45.2M │$27.1M│$18.1M│ 40.0% │  │ $0  └──────────────────────────────────┘        │ │
│  │           │$42.5M │+6.4% │$1.2K │11.3K  │  │     Jan Feb Mar Apr May Jun Jul Aug              │ │
│  │                                          │  │                                                  │ │
│  │  🟥 Filter – Territory Group             │  │  🟧 Drop-Down Filter – Territory Group           │ │
│  │  🟥 Filter – Product Category            │  │  🟥 Filter – Product Category                    │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact – grain: order line item. Revenue, discount, tax, freight |
| `fct_workorder` | Fact – manufacturing actual cost, scrap qty |
| `fct_purchase` | Fact – procurement freight (order-level) |
| `dim_product` | Standard cost, list price, category hierarchy |
| `dim_date` | Date dimension (order_date_key) |
| `dim_sales_territory` | Territory group, country (filter only) |
| `dim_customer` | Customer type — Internet/Reseller (derived via sales_channel) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `fct_sale.line_total`, `fct_sale.order_sub_total`, `fct_sale.order_total_due` |
| COGS | `dim_product.standard_cost` × `fct_sale.order_qty` |
| Gross Profit | Revenue − COGS |
| Gross Margin % | Gross Profit / Revenue × 100 |
| Manufacturing Cost | `fct_workorder.total_actual_cost` |
| Scrap Loss | `fct_workorder.scrapped_qty` × `dim_product.standard_cost` |
| Sales Freight | `fct_sale.order_freight_amount` (dedup by sales_order_id) |
| Sales Tax | `fct_sale.order_tax_amount` (dedup by sales_order_id) |
| Procurement Freight | `fct_purchase.order_freight_amount` (dedup by purchase_order_id) |
| Channel | `fct_sale.sales_channel` (Internet / Reseller) |
| AOV | `SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| Revenue per Unit | `SUM(line_total) / SUM(order_qty)` |
| Cost-to-Revenue | COGS / Revenue × 100 |

### **Key Calculations**
```sql
-- P&L Components
Revenue          = SUM(line_total)
COGS             = SUM(standard_cost * order_qty)
Gross_Profit     = Revenue - COGS
Gross_Margin_%   = Gross_Profit / Revenue * 100

-- Operational Charges (need dedup for order-level fields)
Sales_Freight    = SUM(order_freight_amount) -- per distinct sales_order_id
Sales_Tax        = SUM(order_tax_amount)     -- per distinct sales_order_id
Mfg_Cost         = SUM(total_actual_cost)    -- from fct_workorder
Scrap_Loss       = SUM(scrapped_qty * standard_cost)
Proc_Freight     = SUM(order_freight_amount) -- from fct_purchase per distinct PO

-- Net Proxy (NOT true net income — no SGA/payroll)
Net_Proxy        = Gross_Profit - Sales_Freight - Sales_Tax - Scrap_Loss

-- KPI Metrics
AOV              = SUM(order_total_due) / COUNT(DISTINCT sales_order_id)
Rev_Per_Unit     = SUM(line_total) / SUM(order_qty)
Cost_Ratio       = COGS / Revenue * 100

-- Prior-Period Comparisons
YoY_%            = (Current_YTD - Prior_YTD) / Prior_YTD * 100
QoQ_%            = (Current_Qtr - Prior_Qtr) / Prior_Qtr * 100
MoM_%            = (Current_Month - Prior_Month) / Prior_Month * 100

-- Order-Level Deduplication (for tax/freight at line-item grain)
-- Option A: Use DISTINCT sales_order_id aggregation
-- Option B: Allocate proportionally: line_freight = order_freight * (line_total / order_sub_total)
```

### **Deduplication Note**
`order_tax_amount`, `order_freight_amount`, and `order_total_due` are **order-level** measures stored on every line item row in `fct_sale`. When aggregating:
- For **order-level totals**: use `SUM(DISTINCT sales_order_id-level)` or pre-aggregate per order
- For **line-level allocation**: prorate as `line_share = line_total / order_sub_total`

This is critical to avoid double-counting tax and freight in P&L waterfall and KPI cards.
