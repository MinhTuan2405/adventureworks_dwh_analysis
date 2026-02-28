# Sales Performance & Profitability Dashboard

**Overall Objective:** Deep dive into revenue growth, sales targets, and gross margins to evaluate end-to-end business value — across regions, sales channels, and customer segments.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              Sales Performance & Profitability Dashboard                              │
│                                                                                                      │
│  Detailed customer & territory breakdowns                                                            │
│  incorporated in separate SCM Cost Deep Dive dashboard                                               │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Total Sales     │ Revenue & Gross Margin by Channel    │                                   │
│          │ Revenue and     │   Breakout by Internet / Reseller    │  • High-level summary of sales    │
│          │ Gross Margin    │                                      │    results, with additional        │
│  Sales   ├─────────────────┼──────────────────────────────────────┤    channel and territory detail   │
│  Perf.   │ Revenue by      │ Transaction Volume & Average Order   │  • Use to quickly assess current  │
│          │ Territory       │ Value (AOV)                          │    overall performance             │
│          │                 │   Breakout by Territory Group        │    e.g., tracking YTD revenue     │
│          ├─────────────────┼────────────────────┬─────────────────┤    against prior year             │
│          │ Revenue by      │ Revenue Growth by  │ Revenue Growth  │  • Enable deep insights with      │
│          │ Channel         │ Territory          │ by Channel      │    associated KPIs                 │
│          │( Intermediate ) │                    │                 │                                   │
├──────────┼─────────────────┼────────────────────┴─────────────────┤                                   │
│          │ Monthly Revenue │                                      │  • Summarizes ability to track     │
│  Revenue │ Trend           │ Monthly Revenue Variance & AOV Trend │    revenue momentum and            │
│  Trends  │                 │                                      │    identify inflection points      │
│          │                 │                                      │  • Leverage to understand how      │
│          │                 │                                      │    MoM changes impact financial    │
│          │                 │                                      │    outcomes                        │
├──────────┼─────────────────┼──────────────────────────────────────┤                                   │
│          │ Revenue by      │                                      │  • Detail on current customer      │
│ Customer │ Customer        │ Customer Segment Contribution &      │    mix, value distribution,        │
│  Value   │ Segment         │ Pareto Analysis                      │    and concentration risk          │
│          │                 │                                      │  • Use alongside channel data      │
│          │                 │                                      │    to optimize customer             │
│          │                 │                                      │    acquisition / retention          │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_sale + dimensions)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY    │
                    │ Territory Group       │
                    │ Country               │
                    │ Sales Channel         │
                    │ Customer Segment      │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total Sales Revenue and Gross Margin

| Cell | Spec |
|------|------|
| **Total Sales Revenue and Gross Margin** | Headline Number + Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_date |
| | `SUM(line_total)`, `SUM(line_total) - SUM(standard_cost * order_qty)` |

| Cell | Spec |
|------|------|
| **Revenue & Gross Margin by Channel** | Revenue (Stackbar) & Gross Margin % (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale (sales_channel) |
| | 🟧 Toggle – Sales Channel (Internet / Reseller) |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Specific Products |

---

### ROW 2: Revenue by Territory

| Cell | Spec |
|------|------|
| **Revenue & Margin by Territory** | Table; Headline # & Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_sales_territory |
| | Columns: Territory, Revenue, Margin, Prior Year, YoY |
| | 🟧 Toggle – Territory Group |
| | 🟥 Filter – Country |

| Cell | Spec |
|------|------|
| **Transaction Volume & AOV** | Transaction Volume (Stackbar) & AOV (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total (Vol.) and Average (AoV) |
| | Source: fct_sale |
| | `COUNT(DISTINCT sales_order_id)`, `SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| | 🟧 Toggle – Territory Group |
| | 🟥 Toggle – Internet vs. Reseller |
| | 🟥 Filter – Specific Products |

---

### ROW 3: Revenue by Channel

| Cell | Spec |
|------|------|
| **Revenue by Channel** | Table; Headline # & Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale |
| | Columns: Channel, Revenue, Prior Year, YoY |

| Cell | Spec |
|------|------|
| **Revenue Growth by Territory** | Average Growth %; Bar Chart by Territory Group (e.g., NA, EU) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_sale + dim_sales_territory |
| | `(sales_ytd - sales_last_year) / sales_last_year * 100` |

| Cell | Spec |
|------|------|
| **Revenue Growth by Channel** | Average Growth %; Line/Bar Chart by Channel |
| | Timeframe: YTD |
| | Measurement Range: Monthly Average |
| | Source: fct_sale |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Country |

---

### ROW 4: Monthly Revenue Trend & Variance

| Cell | Spec |
|------|------|
| **Monthly Revenue Trend** | Headline Number + Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_date |
| | `SUM(line_total) GROUP BY year_month` |

| Cell | Spec |
|------|------|
| **Monthly Revenue Variance & AOV Trend** | Revenue Variance (Stackbar) & AOV (Line Chart) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total (Variance) and Average (AoV) |
| | Source: fct_sale + dim_date |
| | `MoM_Variance = (Current_Month - Prior_Month) / Prior_Month * 100` |
| | `AOV = SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| | 🟧 Drop-Down Filter – Channel |
| | 🟥 Filter – Territory |
| | 🟥 Filter – Customer Segment |

---

### ROW 5: Customer Value & Segmentation

| Cell | Spec |
|------|------|
| **Revenue by Customer Segment** | Table; Headline # & Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_customer |
| | Segmentation: total_purchase_ytd (P25 / P75) |
| | Columns: Segment, Revenue, Count, Contribution %, AOV |

| Cell | Spec |
|------|------|
| **Customer Segment Contribution & Pareto** | Revenue by Segment (Stackbar) & Cumulative % (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_customer |
| | `Cumulative_% = Running_Sum(Revenue) / Total_Revenue * 100` |
| | 🟧 Toggle – Customer Type (Internet / Reseller) |
| | 🟥 Filter – Territory |
| | 🟥 Filter – Customer Segment |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Territory Group          │
  (e.g., performance by territory or channel)             │  Country                  │
                                                          │  Sales Channel            │
  Align Dashboard permissions with existing               │  Customer Segment         │
  reporting (some users can't see margin, just revenue)   └──────────────────────────┘

  Legend:                                                      
  🟧 Filters for "Crawl"                                       
  🟥 Filters for "Walk/Run"                                     

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total Sales Revenue       │  │  Revenue & Gross Margin by Channel               │  Filter       │
│  │ and Gross Margin          │  │                                                  │               │
│  │                           │  │   ██ Internet  ██ Reseller  ── Prior Yr  ── GM%  │  🟧 Toggle -  │
│  │  $45.2M        +7%   +3% │  │                                                  │  Channel      │
│  │  YTD Revenue   Over  YoY │  │  $10M ┌──────────────────────────────────┐  50%  │               │
│  │               Target      │  │       │ ████████████████████████████████ │       │  🟥 Filter -  │
│  │  $18.1M        +8%   +4% │  │       │ ████  ████  ████  ████  ████    │  40%  │  Territory    │
│  │  YTD Margin    Over  YoY │  │       │ ████  ████  ████  ████  ████    │       │  Group        │
│  │               Target      │  │  $0   │────────────────────────────────│  30%  │               │
│  │                           │  │       M1   M3   M5   M7   M9   M11     │       │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Rev. by Territory         │  │  Transaction Volume & Average Order Value        │  Filter       │
│  │         Revenue  Margin   │  │                                                  │               │
│  │          Prior           │  │   ██ NA   ██ EU   ── Prior Yr   ── Avg. AOV      │  🟧 Toggle -  │
│  │          Week     YoY    │  │                                                  │  Territory    │
│  │ NA     $15.2M  ▲   ▲    │  │  50K ┌──────────────────────────────────┐ $4,000 │               │
│  │ EU      $8.5M  ▼   ▲    │  │      │ ██  ██  ██  ██  ██  ██  ██  ██ │         │  🟥 Filter -  │
│  │ Pacific $4.3M  ▲   ▼    │  │      │ ██  ██  ██  ██  ██  ██  ██  ██ │ $3,000 │  Channel      │
│  │ ...                      │  │  0   │────────────────────────────────│ $2,000 │               │
│  │         Drop-Down Filter │  │       M1   M3   M5   M7   M9   M11    │         │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Revenue by Channel        │  │  Revenue Growth by          │  │ Revenue Growth by Channel      │ │
│  │          Revenue  Prior   │  │  Territory                  │  │                                │ │
│  │          Week     YoY    │  │                              │  │  ── Internet   ── Reseller     │ │
│  │ Internet  $27.1M  ▲  ▲  │  │  NA      ████████████ +12%  │  │                                │ │
│  │ Reseller  $18.1M  ▼  ▲  │  │  EU      ████████    +8%   │  │  +15%──●                       │ │
│  │ ...                      │  │  Pacific ██████      +5%   │  │        ●──●──●──●──● +8%      │ │
│  │                          │  │  ...                        │  │  Jan  Mar  May  Jul  Sep  Nov  │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
│                                                                                     Drop-Down      │
│                                                                                     🟥 Territory   │
│                                                                                     🟥 Country     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Monthly Revenue           │  │  Monthly Revenue Variance & AOV Trend                        │   │
│  │ Trend                     │  │                                                              │   │
│  │  $45.2M                   │  │   ▓▓ MoM Variance %    ── AOV Trend    ── Prior Yr AOV      │   │
│  │  Cumulative YTD           │  │                                                              │   │
│  │                           │  │  +10% ┌──────────────────────────────────────────┐   $4,000  │   │
│  │  +3%      -2%       +5%  │  │       │  ▓▓      ▓▓                ▓▓            │           │   │
│  │  Over     Prior     YoY  │  │   0%  │──▓▓──▓▓──▓▓──▓▓──▓▓──▓▓──▓▓──▓▓──▓▓──│   $3,000  │   │
│  │  Target   Month          │  │       │              ▓▓  ▓▓      ▓▓              │           │   │
│  │                           │  │  -10% │  ●───●───●───●───●───●───●───●───●───●──│   $2,000  │   │
│  │                           │  │       Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep│           │   │
│  │                           │  └──────────────────────────────────────────────────────────────┘   │
│  │                           │  🟧 Drop-Down Filter - Channel                                     │
│  └───────────────────────────┘  🟥 Filter - Territory | 🟥 Filter - Customer Segment              │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Revenue by Customer       │  │  Customer Segment Contribution & Pareto Analysis             │   │
│  │ Segment                   │  │                                                              │   │
│  │                           │  │   ██ High-Value  ██ Medium  ██ Low  ── Cumulative %          │   │
│  │  Segment   Revenue  Cont │  │                                                              │   │
│  │  High      $28.0M   62%  │  │  $30M ┌──────────────────────────────────────┐  100%         │   │
│  │  Medium    $12.7M   28%  │  │       │ ████████████████████████████████████ │               │   │
│  │  Low        $4.5M   10%  │  │       │ ████  ████  ████  ████              │   80%         │   │
│  │                           │  │       │ ████  ████  ████                    │               │   │
│  │  Count: 2.5K | 8.2K | 8K │  │       │ ████  ████                          │   60%         │   │
│  │  AOV: $4.2K| $2.8K|$1.1K │  │       │──────●────●────●──●──●──●──●──●──│               │   │
│  │                           │  │  $0   └──────────────────────────────────────┘   0%         │   │
│  │         Drop-Down Filter  │  │        Top 10%  20%  30%  40%  50%  ...  100%               │   │
│  │  🟧 Toggle - Cust. Type   │  │                                                              │   │
│  │  🟥 Filter - Territory    │  │  [Insight: Top 20% customers → 78% of Total Revenue]        │   │
│  └───────────────────────────┘  └──────────────────────────────────────────────────────────────┘   │
│                                  🟧 Toggle – Customer Type (Internet / Reseller)                   │
│                                  🟥 Filter – Territory | 🟥 Filter – Customer Segment              │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact – grain: order line item |
| `dim_customer` | Customer type, segment, purchase YTD |
| `dim_sales_territory` | Territory, country, territory group, YTD growth |
| `dim_geography` | City, state, country |
| `dim_date` | Date dimension (order_date_key) |
| `dim_product` | Product details (filter only) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `line_total`, `order_total_due`, `order_sub_total` |
| Cost | `standard_cost` (dim_product) × `order_qty` |
| Gross Margin | `line_total - (standard_cost × order_qty)` |
| Channel | `sales_channel` (Internet / Reseller) |
| Territory | `territory_name`, `country_name`, `territory_group` |
| Growth | `sales_ytd`, `sales_last_year` → calculated delta |
| Volume | `order_qty`, `COUNT(DISTINCT sales_order_id)` |
| AOV | `SUM(order_total_due) / COUNT(DISTINCT sales_order_id)` |
| Customer Value | `total_purchase_ytd` → Percentile segmentation |

### **Key Calculations**
```sql
-- Gross Margin
Gross_Margin     = SUM(line_total) - SUM(standard_cost * order_qty)
Gross_Margin_%   = Gross_Margin / SUM(line_total) * 100

-- AOV
AOV = SUM(order_total_due) / COUNT(DISTINCT sales_order_id)

-- MoM Variance
MoM_Var = (Current_Month_Revenue - Prior_Month_Revenue) / Prior_Month_Revenue * 100

-- Revenue Growth (Territory)
Growth = (sales_ytd - sales_last_year) / sales_last_year * 100

-- Customer Segmentation
High-Value:   total_purchase_ytd >= PERCENTILE(75)
Medium-Value: total_purchase_ytd >= PERCENTILE(25) AND < PERCENTILE(75)
Low-Value:    total_purchase_ytd <  PERCENTILE(25)

-- Pareto
Cumulative_% = SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING) 
               / SUM(revenue) OVER ()
```
