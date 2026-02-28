# Product & Category Analysis Dashboard

**Overall Objective:** Deep-dive into product portfolio performance and gross margin health to optimize sales mix and profitability — identify star products, quantify discount impact, and flag underperforming categories for action.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                              Product & Category Analysis Dashboard                                    │
│                                                                                                      │
│  Detailed product-level drill-downs                                                                  │
│  incorporated in separate Product Detail view                                                        │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ Total Revenue    │ Revenue & Gross Margin by Category   │                                  │
│          │ and Gross Margin │   Breakout by Product Category       │  • High-level summary of product │
│ Product  │                  │                                      │    portfolio profitability        │
│ Margin   ├──────────────────┼──────────────────────────────────────┤  • Use to quickly identify which │
│ Perf.    │ Margin by        │ Product Portfolio Matrix              │    products / categories drive   │
│          │ Category         │   (BCG: Star/CashCow/Dog/?Mark)     │    margin and which are lagging  │
│          │                  │   Breakout by Category                │  • Enable prioritization of Star │
│          ├──────────────────┼────────────────────┬─────────────────┤    products for promotion         │
│          │ Top Products     │ Margin $ by        │ Margin % by     │                                  │
│          │ by Gross Margin  │ Category Trend     │ Subcategory     │                                  │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Avg Discount %   │                                      │  • Summarizes how discounting    │
│ Discount │ and Discount     │ Discount Impact: Volume vs Margin    │    affects the balance between   │
│ Impact   │ Volume           │ Trade-off by Discount Tier           │    sales volume and margin       │
│          │                  │                                      │    erosion                        │
│          ├──────────────────┼────────────────────┬─────────────────┤  • Leverage to understand if     │
│          │ Revenue Lift vs  │ Discount vs Volume │ Margin Erosion  │    discounts are net-positive    │
│          │ Margin Erosion   │ Correlation        │ by Category     │    or destroying value           │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Underperformer   │                                      │  • Flag categories / subcats     │
│ Category │ Scorecard        │ Category Lifecycle Trends &          │    with low margin + declining   │
│ Health   │                  │ Price Elasticity Analysis             │    growth for price adjustment   │
│          │                  │                                      │    or portfolio exit              │
│          │                  │                                      │  • Use to drive strategic         │
│          │                  │                                      │    portfolio decisions            │
└──────────┴──────────────────┴──────────────────────────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_sale + dim_product)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Monthly**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to Total YTD view.

```
Global Filters:     │ Timeframe: XX - YY          │
                    │ Product Category             │
                    │ Product Subcategory          │
                    │ Discount Tier                │
                    │ Product Status               │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total Revenue and Gross Margin

| Cell | Spec |
|------|------|
| **Total Revenue and Gross Margin** | Headline Number + Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | `Revenue = SUM(line_total)` |
| | `Cost = SUM(standard_cost * order_qty)` |
| | `GM$ = Revenue - Cost`, `GM% = GM$ / Revenue * 100` |

| Cell | Spec |
|------|------|
| **Revenue & Gross Margin by Category** | Revenue (Stackbar) & GM % (Line) |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_product (product_category_name) |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Subcategory |
| | 🟥 Filter – Product Status (Active / Discontinued) |

---

### ROW 2: Margin by Category & Portfolio Matrix

| Cell | Spec |
|------|------|
| **Margin by Category** | Table; Headline # & Target / Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | Columns: Category, Revenue, GM$, GM%, Prior Year, YoY |
| | 🟧 Toggle – Category vs Subcategory view |
| | 🟥 Filter – Discount Tier |

| Cell | Spec |
|------|------|
| **Product Portfolio Matrix (BCG)** | Scatter/Bubble Chart |
| | X-axis: Revenue Growth YoY % |
| | Y-axis: Gross Margin % |
| | Bubble Size: Revenue |
| | Color: Product Category |
| | Timeframe: YTD vs Prior Year |
| | Source: fct_sale + dim_product + dim_date |
| | `Growth = (CY_Revenue - PY_Revenue) / PY_Revenue * 100` |
| | `GM% = (Revenue - Cost) / Revenue * 100` |
| | Quadrants: Star (>15% growth, >40% GM) / Cash Cow / ?Mark / Dog |
| | 🟧 Toggle – Category vs Subcategory granularity |
| | 🟥 Filter – Product Category |

---

### ROW 3: Top Products & Category Trend

| Cell | Spec |
|------|------|
| **Top Products by Gross Margin** | Table; Top 10 by GM$ |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product |
| | Columns: Product, Revenue, GM$, GM%, Volume, BCG Class |

| Cell | Spec |
|------|------|
| **Margin $ by Category Trend** | Stacked Area or Line Chart by Category |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_product + dim_date |
| | 🟧 Drop-Down Filter – Category |

| Cell | Spec |
|------|------|
| **Margin % by Subcategory** | Horizontal Bar Chart |
| | Timeframe: YTD |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product |
| | 🟥 Filter – Category (parent) |
| | 🟥 Filter – Product Status |

---

### ROW 4: Discount Impact – Volume vs Margin

| Cell | Spec |
|------|------|
| **Avg Discount % and Discount Volume** | Headline Number + Trends |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale |
| | `AVG(unit_price_discount) * 100` |
| | `SUM(order_qty) WHERE unit_price_discount > 0` |

| Cell | Spec |
|------|------|
| **Discount Impact: Volume vs Margin Trade-off** | Grouped Column (Volume) & Line (GM%) by Discount Tier |
| | Timeframe: YTD |
| | Measurement Range: Monthly Total |
| | Source: fct_sale + dim_product |
| | Discount Tier: 0% / 1-10% / 11-20% / >20% |
| | `Tier = CASE WHEN discount=0 THEN '0%' WHEN <=0.10 THEN '1-10%'...END` |
| | 🟧 Toggle – Discount Tier |
| | 🟥 Filter – Category |
| | 🟥 Filter – Subcategory |

---

### ROW 5: Discount Effectiveness

| Cell | Spec |
|------|------|
| **Revenue Lift vs Margin Erosion** | KPI Cards + Waterfall Chart |
| | Timeframe: YTD |
| | Source: fct_sale + dim_product |
| | `Discounted_GM% vs Baseline_GM% (no discount)` |
| | `Net_Profit_Impact = Revenue_Lift_$ - Margin_Loss_$` |

| Cell | Spec |
|------|------|
| **Discount vs Volume Correlation** | Scatter Plot (Avg Discount % vs Volume per product) |
| | Timeframe: YTD |
| | Source: fct_sale |
| | `CORR(AVG(discount), SUM(order_qty)) per product` |
| | 🟥 Filter – Category |

| Cell | Spec |
|------|------|
| **Margin Erosion by Category** | Bar Chart; GM% drop per category (discounted vs non-discounted) |
| | Timeframe: YTD |
| | Source: fct_sale + dim_product |
| | `Erosion_bps = (Baseline_GM% - Discounted_GM%) * 100` |
| | 🟥 Filter – Discount Tier |

---

### ROW 6: Category Health & Underperformers

| Cell | Spec |
|------|------|
| **Underperformer Scorecard** | Table with Conditional Formatting |
| | Timeframe: YTD vs Prior Year |
| | Source: fct_sale + dim_product + dim_date |
| | Columns: Category, GM%, Growth YoY%, Contribution%, Severity Score, Action |
| | `Severity = (1-GM%)*0.4 + (1-Growth%)*0.3 + (1-Contrib%)*0.3` |
| | 🔴 Exit: Score > 0.7 / 🟡 Price Adjust: 0.4-0.7 / 🟢 Monitor: < 0.4 |

| Cell | Spec |
|------|------|
| **Category Lifecycle Trends & Price Elasticity** | Dual view: Line Chart (quarterly revenue trend) + Scatter (price elasticity) |
| | Timeframe: Last 4 Quarters |
| | Source: fct_sale + dim_product + dim_date |
| | Lifecycle: Growth (>20% trend) / Mature (-5%~20%) / Decline (<-5%) |
| | Elasticity = Volume_Change_% / Price_Change_% |
| | 🟧 Toggle – Lifecycle vs Elasticity view |
| | 🟥 Filter – Category |
| | 🟥 Filter – Subcategory |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Monthly**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY      │
  highlight individual data points & detail               │  Product Category        │
  (e.g., performance by product or subcategory)           │  Product Subcategory     │
                                                          │  Discount Tier           │
  Align Dashboard permissions with existing               │  Product Status          │
  reporting (some users can't see cost, just revenue)     └──────────────────────────┘

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total Revenue             │  │  Revenue & Gross Margin by Category              │  Filter       │
│  │ and Gross Margin          │  │                                                  │               │
│  │                           │  │  ██ Bikes ██ Components ██ Clothing ── GM%       │  🟧 Toggle -  │
│  │  $45.2M        +7%   +3% │  │                                                  │  Category     │
│  │  YTD Revenue   Over  YoY │  │  $5M ┌──────────────────────────────────┐  50%  │               │
│  │               Target      │  │      │ ████████████████████████████████ │       │  🟥 Filter -  │
│  │  $18.1M        +8%   +4% │  │      │ ████  ████  ████  ████  ████    │  40%  │  Subcategory  │
│  │  YTD GM$       Over  YoY │  │      │ ████  ████  ████  ████  ████    │       │               │
│  │               Target      │  │  $0  │────────────────────────────────│  30%  │  🟥 Filter -  │
│  │                           │  │      M1   M3   M5   M7   M9   M11     │       │  Status       │
│  │  GM%: 40.1%               │  └──────────────────────────────────────────────────┘               │
│  └───────────────────────────┘                                                                     │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Margin by Category        │  │  Product Portfolio Matrix (BCG)                  │  Filter       │
│  │          Revenue   GM%    │  │                                                  │               │
│  │           Prior          │  │  GM%                                              │  🟧 Toggle -  │
│  │           Year    YoY    │  │  60│  ●Mountain   ○Touring                       │  Cat/Subcat   │
│  │ Bikes    $28.5M   45% ▲  │  │  50│  ●Road       ○                              │               │
│  │ Comp.    $11.2M   38% ▲  │  │  40├─────────────────────────────                │  🟥 Filter -  │
│  │ Cloth.    $4.1M   28% ▼  │  │  30│  ▲Jerseys    △Gloves                       │  Category     │
│  │ Access.   $1.4M   25% ▼  │  │  20│  ▲Socks      △Caps                         │               │
│  │                          │  │    └───────────────────────────>                  │               │
│  │         Drop-Down Filter │  │     -10   0   +10  +20  +30   Growth %           │               │
│  └───────────────────────────┘  │     Bubble size = Revenue                        │               │
│                                  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Top Products by GM$       │  │  GM$ by Category Trend      │  │ GM% by Subcategory             │ │
│  │  Product    GM$     GM%   │  │                              │  │                                │ │
│  │  Mt-200   $2.5M    52%   │  │  ── Bikes   ── Components   │  │ Mountain  ████████████  52%    │ │
│  │  Road-350 $2.1M    48%   │  │  ── Clothing ── Accessories │  │ Road      ████████████  48%    │ │
│  │  Road-150 $1.9M    46%   │  │                              │  │ Touring   ██████        31%    │ │
│  │  Mt-100   $1.7M    44%   │  │   $3M──●                    │  │ Frames    ████          28%    │ │
│  │  Touring  $1.5M    31%   │  │       ●  ●──●──●            │  │ Jerseys   ████          26%    │ │
│  │  ...                     │  │  $1M──────────────>          │  │ Helmets   ███           24%    │ │
│  │                          │  │   M1  M3  M5  M7  M9  M11   │  │ ...                            │ │
│  └───────────────────────────┘  │  🟧 Drop-Down Filter - Cat  │  │ 🟥 Filter - Category           │ │
│                                  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Discount Overview         │  │  Discount Impact: Volume vs Margin Trade-off                 │   │
│  │                           │  │                                                              │   │
│  │  Avg Discount: 8.5%      │  │   ██ Volume (bars)  ── Gross Margin % (line)                 │   │
│  │  +2%      -1%       +3%  │  │                                                              │   │
│  │  Over     Prior     YoY  │  │  10K ┌──────────────────────────────────────────┐   50%      │   │
│  │  Target   Month          │  │      │  ███                                     │            │   │
│  │                           │  │   5K │  ███  ████████  ██████████  ████████    │ ──●  40%   │   │
│  │  Discounted Orders: 35%  │  │      │  ███  ████████  ██████████  ████████ ──● │   30%      │   │
│  │  of Total Volume         │  │   0  │  ███  ████████  ██████████  █████──●    │   20%      │   │
│  │                           │  │      0%     1-10%     11-20%      >20%         │            │   │
│  │                           │  └──────────────────────────────────────────────────────────────┘   │
│  │                           │  🟧 Toggle – Discount Tier                                         │
│  └───────────────────────────┘  🟥 Filter – Category | 🟥 Filter – Subcategory                    │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Revenue Lift vs           │  │  Discount vs Volume         │  │ Margin Erosion by Category     │ │
│  │ Margin Erosion            │  │  Correlation                │  │                                │ │
│  │                           │  │                              │  │  Bikes      ████████  -180bps │ │
│  │  ┌─────────┐             │  │  Vol                          │  │  Components ██████    -120bps │ │
│  │  │Rev Lift │ $2.1M       │  │   ^    ●  ●                  │  │  Clothing   ████      -80bps  │ │
│  │  └─────────┘             │  │   │  ●  ● ●  ●               │  │  Access.    ███       -50bps  │ │
│  │  ┌─────────┐             │  │   │ ●  ●  ●   ●              │  │                                │ │
│  │  │GM Loss  │ -$0.8M      │  │   └────────────────>         │  │  Avg Erosion: -107 bps        │ │
│  │  └─────────┘             │  │   0   Discount %              │  │                                │ │
│  │  Net Impact: +$1.3M ✓    │  │  Corr: +0.62                 │  │  🟥 Filter - Discount Tier     │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Underperformer Scorecard (Action Required)                                                 │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │   │
│  │  │ Category/Subcat │ Revenue  │ GM%     │ Growth% │ Contrib% │ Score │ Action          │    │   │
│  │  ├─────────────────────────────────────────────────────────────────────────────────────┤    │   │
│  │  │ Touring Bikes   │ $1.2M   │ 18% 🔴 │ -12% 🔴 │   4% 🔴  │ 0.85  │ EXIT            │    │   │
│  │  │ Road Frames     │ $2.8M   │ 25% 🟡 │  -8% 🔴 │   6% 🟡  │ 0.62  │ PRICE ↑         │    │   │
│  │  │ Jerseys         │ $1.5M   │ 29% 🟡 │  -3% 🟡 │   8% 🟢  │ 0.45  │ MONITOR         │    │   │
│  │  │ Gloves          │ $0.8M   │ 32% 🟢 │  +2% 🟢 │   5% 🟡  │ 0.38  │ OK              │    │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │   │
│  │  🔴 Score > 0.7: EXIT   🟡 Score 0.4-0.7: PRICE ADJUST   🟢 Score < 0.4: MONITOR         │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────┐   │
│  │ Category Lifecycle Trends                 │  │ Price Elasticity Analysis                    │   │
│  │                                            │  │                                              │   │
│  │  Revenue                                   │  │  Volume Change %                              │   │
│  │   ^   ──● Bikes (Growth)                  │  │   ^                                          │   │
│  │   │       ╱                                │  │   │  Elastic (E>1)                            │   │
│  │   │  ──────● Components (Mature)          │  │ +20│    ●  Road Bikes                         │   │
│  │   │          ╲                             │  │   │  ●  ●                                    │   │
│  │   │           ●── Touring (Decline)       │  │   0├────●──●──────────────>                  │   │
│  │   └──────────────────────────>            │  │   │      ● ● Inelastic (E<1)                │   │
│  │   Q1   Q2   Q3   Q4                      │  │ -20│       ● Accessories                      │   │
│  │                                            │  │    -20    0   +20                              │   │
│  │  Growth: Sustain / invest                  │  │       Price Change %                          │   │
│  │  Mature: Optimize margins                  │  │                                              │   │
│  │  Decline: Exit or reposition               │  │  Action: ⬆ Price if E < 0.5                 │   │
│  │                                            │  │          ⬇ Price if E > 1.5                 │   │
│  │  🟧 Toggle – Lifecycle / Elasticity        │  │  🟥 Filter – Category | 🟥 Filter – Subcat  │   │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact – grain: order line item |
| `dim_product` | Product name, cost, price, category hierarchy, status |
| `dim_date` | Date dimension (order_date_key) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `line_total` |
| Cost | `standard_cost` (dim_product) × `order_qty` |
| Gross Margin | `line_total - (standard_cost × order_qty)` |
| Pricing | `unit_price`, `list_price` |
| Discount | `unit_price_discount` (decimal) → `* 100` for % |
| Volume | `order_qty` |
| Category | `product_category_name`, `product_subcategory_name` |
| Product | `product_name`, `product_number`, `color`, `size` |
| Status | `is_finished_good`, `sell_end_date`, `discontinued_date` |

### **Key Calculations**
```sql
-- Gross Margin
GM_$ = SUM(line_total) - SUM(standard_cost * order_qty)
GM_% = GM_$ / SUM(line_total) * 100

-- Discount
Discount_Tier = CASE
    WHEN unit_price_discount = 0 THEN '0%'
    WHEN unit_price_discount <= 0.10 THEN '1-10%'
    WHEN unit_price_discount <= 0.20 THEN '11-20%'
    ELSE '>20%'
END
Margin_Erosion_bps = (Baseline_GM% - Discounted_GM%) * 100

-- Portfolio Classification (BCG)
Growth = (CY_Revenue - PY_Revenue) / PY_Revenue * 100
Star:          Growth > 15% AND GM% > 40%
Cash_Cow:      Growth <= 15% AND GM% > 40%
Question_Mark: Growth > 15% AND GM% <= 40%
Dog:           Growth <= 15% AND GM% <= 40%

-- Underperformer Score
Severity = (1 - GM%/100)*0.4 + (1 - Growth%/100)*0.3 + (1 - Contrib%/100)*0.3

-- Price Elasticity
Elasticity = Volume_Change_% / Price_Change_%
```
