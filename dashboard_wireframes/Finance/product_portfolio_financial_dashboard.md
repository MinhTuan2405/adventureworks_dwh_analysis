# Product Portfolio Financial Analysis — Dashboard Wireframe

> **Dashboard #7** trong Finance Dashboard Funnel (Level 3C — Dimensional Cuts)  
> **Audience**: CFO, Product Manager, Category Manager  
> **Tần suất xem**: Monthly / Quarterly  
> **Lenses**: Product Category, Subcategory, Product Line, Class

---

## Business Questions Addressed

| # | Business Question |
|---|---|
| Q1 | What is the revenue and profit contribution of each product category — which categories are "cash cows" vs "question marks"? |
| Q2 | How does product pricing (list price vs actual selling price) vary across categories, and where is the largest price gap? |
| Q3 | Which individual products have the highest margin and revenue, and which high-revenue products have dangerously low margins that need pricing correction? |

---

## V1 — CRAWL (Grid Layout)

| | Col 1 (50%) | Col 2 (50%) |
|---|---|---|
| **Row 1** — Category P&L Contribution | KPI Cards: Total Revenue, Total GP, Avg GM%, #Categories | BCG-Proxy Bubble Chart (X: Revenue Share %, Y: Revenue Growth %, Bubble = GP) |
| **Row 2** — Pricing Analysis | Grouped Bar Chart: List Price vs Actual Price by Category (with Price Gap annotation) | Price Realization Heatmap: Category × Subcategory (color = realization %) |
| **Row 3** — Product Margin Landscape | Scatter Plot: Revenue (X) vs GM% (Y) per product (color = category, size = qty sold) | Top 10 / Bottom 10 Margin Leaderboard (dual-list) |
| **Row 4** — Portfolio Summary | Category Waterfall: Revenue → COGS → GP stacked by category | Detail Table: Product-level with Revenue, COGS, GP, GM%, Price Realization %, Qty |

---

## V2 — DETAIL (Cell-level Specifications)

### Row 1 — Category P&L Contribution (→ Q1)

#### Cell 1.1 — KPI Cards (4 cards horizontal)

| KPI | Formula | Format | Comparison |
|---|---|---|---|
| **Total Revenue** | `SUM(fct_sale.line_total)` | $##.#M | vs Prior Period (▲▼ %) |
| **Total Gross Profit** | `SUM(line_total) − SUM(standard_cost × order_qty)` | $##.#M | vs Prior Period (▲▼ %) |
| **Avg Gross Margin %** | `Total GP / Total Revenue × 100` | ##.#% | vs Prior Period (▲▼ pp) |
| **# Active Categories** | `COUNT(DISTINCT product_category_name) WHERE line_total > 0` | # | static |

**Filters**: Year / Quarter picker, Sales Channel toggle (All / Internet / Reseller)

#### Cell 1.2 — BCG-Proxy Bubble Chart

```
Concept: Modified BCG matrix using revenue data as proxy
- X-axis: Revenue Share % (category revenue / total revenue × 100)
- Y-axis: Revenue Growth % (YoY or period-over-period)
- Bubble size: Absolute Gross Profit ($)
- Bubble color: GM% gradient (red < 30% < yellow < 50% < green)

Quadrant Labels (crosshair at median):
┌─────────────────────┬─────────────────────┐
│   ❓ QUESTION MARKS  │      ⭐ STARS        │
│  High Growth,        │  High Growth,        │
│  Low Share           │  High Share          │
├─────────────────────┼─────────────────────┤
│      🐕 DOGS         │   🐄 CASH COWS      │
│  Low Growth,         │  Low Growth,         │
│  Low Share           │  High Share          │
└─────────────────────┴─────────────────────┘

Each bubble = 1 product_category_name (4 categories: Bikes, Components, Clothing, Accessories)
Tooltip: Category | Revenue | GP | GM% | Growth% | Share%
```

**SQL — Revenue Share & Growth by Category:**
```sql
WITH current_period AS (
    SELECT
        p.product_category_name,
        SUM(s.line_total)                                       AS revenue,
        SUM(s.line_total) - SUM(p.standard_cost * s.order_qty)  AS gross_profit,
        (SUM(s.line_total) - SUM(p.standard_cost * s.order_qty))
            / NULLIF(SUM(s.line_total), 0) * 100                AS gm_pct
    FROM fct_sale s
    JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
    JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
    WHERE d.calendar_year = :current_year
    GROUP BY p.product_category_name
),
prior_period AS (
    SELECT
        p.product_category_name,
        SUM(s.line_total) AS revenue
    FROM fct_sale s
    JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
    JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
    WHERE d.calendar_year = :current_year - 1
    GROUP BY p.product_category_name
),
total AS (
    SELECT SUM(revenue) AS total_revenue FROM current_period
)
SELECT
    c.product_category_name,
    c.revenue,
    c.gross_profit,
    c.gm_pct,
    c.revenue / NULLIF(t.total_revenue, 0) * 100               AS revenue_share_pct,
    (c.revenue - COALESCE(pp.revenue, 0))
        / NULLIF(pp.revenue, 0) * 100                          AS revenue_growth_pct
FROM current_period c
CROSS JOIN total t
LEFT JOIN prior_period pp ON c.product_category_name = pp.product_category_name
ORDER BY c.revenue DESC;
```

---

### Row 2 — Pricing Analysis (→ Q2)

#### Cell 2.1 — List Price vs Actual Price Grouped Bar Chart

```
Layout: Grouped vertical bars per category
- Bar 1 (light blue): Avg List Price = AVG(dim_product.list_price) weighted by qty sold
- Bar 2 (dark blue): Avg Actual Selling Price = AVG(fct_sale.unit_price) weighted by qty
- Annotation line: Price Gap $ = List − Actual (shown as red text above each pair)
- Secondary annotation: Price Gap % = (List − Actual) / List × 100

X-axis: product_category_name (4 categories)
Y-axis: Average Price ($)

Sorting: By Price Gap $ descending (category with largest gap on the left)

Drill-down: Click category → expand to subcategory bars
```

**SQL — Weighted Average Prices by Category:**
```sql
SELECT
    p.product_category_name,
    p.product_subcategory_name,
    SUM(p.list_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS wtd_avg_list_price,
    SUM(s.unit_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS wtd_avg_actual_price,
    SUM(p.list_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)
      - SUM(s.unit_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS price_gap_dollar,
    (1 - SUM(s.unit_price * s.order_qty)
        / NULLIF(SUM(p.list_price * s.order_qty), 0)) * 100        AS price_gap_pct,
    SUM(s.order_qty)                                                 AS total_qty_sold
FROM fct_sale s
JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
WHERE d.calendar_year = :selected_year
GROUP BY p.product_category_name, p.product_subcategory_name
ORDER BY price_gap_dollar DESC;
```

#### Cell 2.2 — Price Realization Heatmap

```
Layout: Matrix heatmap
- Rows: product_category_name (4)
- Columns: product_subcategory_name (within each category)
- Cell value: Price Realization % = Avg Actual Price / Avg List Price × 100
- Color scale:
    🟥 < 85%  (Heavy discounting — pricing concern)
    🟧 85-92% (Moderate gap)
    🟨 92-97% (Acceptable)
    🟩 > 97%  (Near list price — strong pricing power)

Cell tooltip: Category | Subcategory | Avg List | Avg Actual | Realization % | Qty Sold | Discount Rate

Annotation: Circle size in each cell = total revenue (larger = more material)
```

**SQL — Price Realization by Category × Subcategory:**
```sql
SELECT
    p.product_category_name,
    p.product_subcategory_name,
    AVG(p.list_price)                                               AS avg_list_price,
    SUM(s.unit_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS avg_actual_price,
    SUM(s.unit_price * s.order_qty)
        / NULLIF(SUM(p.list_price * s.order_qty), 0) * 100         AS price_realization_pct,
    SUM(s.line_total)                                               AS total_revenue,
    SUM(s.order_qty)                                                AS total_qty,
    AVG(s.unit_price_discount) * 100                                AS avg_discount_pct
FROM fct_sale s
JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
WHERE d.calendar_year = :selected_year
  AND p.product_subcategory_name IS NOT NULL
GROUP BY p.product_category_name, p.product_subcategory_name
ORDER BY p.product_category_name, price_realization_pct ASC;
```

---

### Row 3 — Product Margin Landscape (→ Q3)

#### Cell 3.1 — Revenue vs Margin Scatter Plot (Product-level)

```
Layout: Scatter plot with 4-quadrant analysis
- X-axis: Product Revenue = SUM(line_total) per product (log scale recommended for wide range)
- Y-axis: Gross Margin % per product
- Point color: product_category_name (4 colors)
- Point size: order_qty (volume sold)

Quadrant Logic (crosshair at X=median revenue, Y=30% GM threshold):
┌──────────────────────────┬──────────────────────────┐
│   🔬 NICHE GEMS          │   💎 PORTFOLIO STARS      │
│   Low Revenue, High Margin│   High Revenue, High Margin│
│   Action: Grow volume     │   Action: Protect & expand │
├──────────────────────────┼──────────────────────────┤
│   ❌ EVALUATE / EXIT      │   🚨 MARGIN ALERT         │
│   Low Revenue, Low Margin │   High Revenue, Low Margin │
│   Action: Discontinue?    │   Action: PRICE CORRECTION │
└──────────────────────────┴──────────────────────────┘

⚠ Bottom-right (🚨 MARGIN ALERT) is the critical zone — these are high-revenue
  products with dangerously low margins. These need immediate pricing review.

Interactive: Click point → show product detail card
Highlight mode: Toggle to highlight only "Margin Alert" products (top-20% revenue AND GM% < 30%)
```

**SQL — Product-level Revenue & Margin:**
```sql
SELECT
    p.product_name,
    p.product_category_name,
    p.product_subcategory_name,
    p.list_price,
    p.standard_cost,
    SUM(s.line_total)                                               AS revenue,
    SUM(s.order_qty)                                                AS qty_sold,
    SUM(s.line_total) - SUM(p.standard_cost * s.order_qty)          AS gross_profit,
    (SUM(s.line_total) - SUM(p.standard_cost * s.order_qty))
        / NULLIF(SUM(s.line_total), 0) * 100                       AS gm_pct,
    SUM(s.unit_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS avg_selling_price,
    SUM(s.unit_price * s.order_qty)
        / NULLIF(SUM(p.list_price * s.order_qty), 0) * 100         AS price_realization_pct
FROM fct_sale s
JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
WHERE d.calendar_year = :selected_year
GROUP BY p.product_name, p.product_category_name, p.product_subcategory_name,
         p.list_price, p.standard_cost
HAVING SUM(s.line_total) > 0
ORDER BY revenue DESC;
```

**SQL — Margin Alert Flag (high-revenue + low-margin products):**
```sql
WITH product_metrics AS (
    SELECT
        p.product_name,
        p.product_category_name,
        SUM(s.line_total)                                       AS revenue,
        (SUM(s.line_total) - SUM(p.standard_cost * s.order_qty))
            / NULLIF(SUM(s.line_total), 0) * 100               AS gm_pct,
        PERCENT_RANK() OVER (ORDER BY SUM(s.line_total))        AS revenue_percentile
    FROM fct_sale s
    JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
    JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
    WHERE d.calendar_year = :selected_year
    GROUP BY p.product_name, p.product_category_name
)
SELECT *,
    CASE
        WHEN revenue_percentile >= 0.80 AND gm_pct < 30 THEN '🚨 MARGIN ALERT'
        WHEN revenue_percentile >= 0.80 AND gm_pct >= 30 THEN '💎 PORTFOLIO STAR'
        WHEN revenue_percentile < 0.80 AND gm_pct >= 30  THEN '🔬 NICHE GEM'
        ELSE '❌ EVALUATE'
    END AS portfolio_quadrant
FROM product_metrics
ORDER BY
    CASE WHEN revenue_percentile >= 0.80 AND gm_pct < 30 THEN 0 ELSE 1 END,
    revenue DESC;
```

#### Cell 3.2 — Top 10 / Bottom 10 Margin Leaderboard

```
Layout: Dual-column leaderboard (side-by-side)

LEFT — 🏆 Top 10 GM% Products           RIGHT — ⚠️ Bottom 10 GM% Products
(minimum qty filter: > 10 units sold)    (minimum qty filter: > 10 units sold)

Columns for each:
| Rank | Product Name | Category | Revenue | GM% | Trend |
|------|-------------|----------|---------|-----|-------|
| 1    | Product A   | Bikes    | $1.2M   | 62% | ▲ +3pp|
| 2    | Product B   | Compon.  | $340K   | 58% | ─     |
| ...  | ...         | ...      | ...     | ... | ...   |

GM% bar: Inline horizontal bar colored by category
Trend: vs prior period (▲ improving / ▼ declining / ─ stable within ±2pp)

Conditional formatting:
- Bottom 10 list: Highlight in RED any product with revenue > $500K (= margin alert candidate)
- Top 10 list: Highlight in GOLD the #1 margin leader

Click row → navigate to product detail (filtered scatter plot)
```

**SQL — Top/Bottom Margin Products:**
```sql
WITH product_gm AS (
    SELECT
        p.product_name,
        p.product_category_name,
        SUM(s.line_total)                                       AS revenue,
        SUM(s.order_qty)                                        AS qty_sold,
        (SUM(s.line_total) - SUM(p.standard_cost * s.order_qty))
            / NULLIF(SUM(s.line_total), 0) * 100               AS gm_pct
    FROM fct_sale s
    JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
    JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
    WHERE d.calendar_year = :selected_year
    GROUP BY p.product_name, p.product_category_name
    HAVING SUM(s.order_qty) > 10
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (ORDER BY gm_pct DESC)  AS rank_top,
        ROW_NUMBER() OVER (ORDER BY gm_pct ASC)   AS rank_bottom
    FROM product_gm
)
-- Top 10
SELECT 'TOP' AS list, rank_top AS rank, product_name, product_category_name,
       revenue, qty_sold, gm_pct
FROM ranked WHERE rank_top <= 10
UNION ALL
-- Bottom 10
SELECT 'BOTTOM', rank_bottom, product_name, product_category_name,
       revenue, qty_sold, gm_pct
FROM ranked WHERE rank_bottom <= 10
ORDER BY list DESC, rank;
```

---

### Row 4 — Portfolio Summary (→ All Questions)

#### Cell 4.1 — Category Waterfall Chart

```
Layout: Waterfall chart showing P&L decomposition by category

Flow:
 Total Revenue ──▶ [−Bikes COGS] ──▶ [−Components COGS] ──▶ [−Clothing COGS]
                ──▶ [−Accessories COGS] ──▶ Total Gross Profit

   $109.8M                                                    $40.5M
   ┃█████████████████████████████████████████████████████████████████┃
   ┃                                                                 ┃
   ┃ Revenue    -$52.3M    -$11.2M    -$3.8M    -$2.0M     GP       ┃
   ┃ $109.8M    Bikes      Components Clothing  Access.    $40.5M    ┃
   ┃            COGS       COGS       COGS      COGS                 ┃

Color: Revenue bar (green), COGS bars (shades of red per category), GP bar (blue)
Each COGS bar shows: absolute $ and % of total COGS

Alternative view toggle: Stacked bar by category showing Revenue | COGS | GP side by side
```

#### Cell 4.2 — Detail Table (Product-level)

```
Columns:
| Product Name | Category | Subcategory | Product Line | Qty Sold | Revenue | COGS | Gross Profit | GM% | Avg Sell Price | List Price | Price Realized % | Discount Avg % |

Features:
- Sortable by any column (default: Revenue DESC)
- Category filter chips at top
- Search box for product name
- Conditional formatting:
    - GM% cell: 🟥 < 20%, 🟧 20-35%, 🟨 35-50%, 🟩 > 50%
    - Price Realized %: 🟥 < 85%, 🟩 > 97%
    - Revenue column: bar-in-cell proportional to max
- Pagination: 25 rows per page
- Export: CSV download button

Row-level alert icon: 🚨 on rows where Revenue top-20% AND GM% < 30%
```

**SQL — Detail Table:**
```sql
SELECT
    p.product_name,
    p.product_category_name                                         AS category,
    p.product_subcategory_name                                      AS subcategory,
    p.product_line_code                                             AS product_line,
    SUM(s.order_qty)                                                AS qty_sold,
    SUM(s.line_total)                                               AS revenue,
    SUM(p.standard_cost * s.order_qty)                              AS cogs,
    SUM(s.line_total) - SUM(p.standard_cost * s.order_qty)          AS gross_profit,
    (SUM(s.line_total) - SUM(p.standard_cost * s.order_qty))
        / NULLIF(SUM(s.line_total), 0) * 100                       AS gm_pct,
    SUM(s.unit_price * s.order_qty) / NULLIF(SUM(s.order_qty), 0)  AS avg_sell_price,
    p.list_price,
    SUM(s.unit_price * s.order_qty)
        / NULLIF(SUM(p.list_price * s.order_qty), 0) * 100         AS price_realization_pct,
    AVG(s.unit_price_discount) * 100                                AS avg_discount_pct
FROM fct_sale s
JOIN dim_product p ON s.dim_product_sk = p.dim_product_sk
JOIN dim_date d ON s.dim_date_sk = d.dim_date_sk
WHERE d.calendar_year = :selected_year
GROUP BY p.product_name, p.product_category_name, p.product_subcategory_name,
         p.product_line_code, p.list_price
HAVING SUM(s.order_qty) > 0
ORDER BY revenue DESC;
```

---

## V3 — WIREFRAME (ASCII Visual)

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│  PRODUCT PORTFOLIO FINANCIAL ANALYSIS              [Year ▾] [Quarter ▾] [Channel ▾]│
├────────────────────────────────┬────────────────────────────────────────────────────┤
│                                │                                                    │
│  ┌──────┐┌──────┐┌──────┐┌──┐ │         BCG-Proxy Bubble Chart                     │
│  │ Total ││ Total││ Avg  ││#C│ │                                                    │
│  │ Rev   ││ GP   ││ GM%  ││at│ │    ▲ Growth%                                       │
│  │$109.8M││$40.5M││36.9% ││ 4│ │    │                                               │
│  │▲ +8.2%││▲+6.1%││▼-0.5 ││  │ │    │  ❓Clothing    ⭐Bikes                        │
│  └──────┘└──────┘└──────┘└──┘ │    │    (3.2%)    ●●●●(68%)                       │
│                                │    │               ●●●●                            │
│  Category P&L Contribution     │    ├──────────────●───────────▶ Share%             │
│                                │    │  🐕Access.(2%)  🐄Components(27%)             │
│                                │    │    (0.8%)          (12%)                       │
│                                │    │                                               │
├────────────────────────────────┼────────────────────────────────────────────────────┤
│                                │                                                    │
│  List Price vs Actual Price    │     Price Realization Heatmap                      │
│                                │                                                    │
│    Bikes  Comp.  Cloth. Acces. │     Category    │Subcat A│Subcat B│Subcat C│...    │
│   ┌─┐┌─┐ ┌┐┌┐  ┌┐┌┐  ┌┐┌┐   │     ────────────┼────────┼────────┼────────┤       │
│   │L││A│ │││A│  │││A│  │││A│   │     Bikes       │ 🟩97% │ 🟨94% │ 🟧88% │       │
│   │i││c│ │L││c│  │L││c│  │L││c│   │     Components  │ 🟩98% │ 🟩96% │ 🟨93% │       │
│   │s││t│ │ ││ │  │ ││ │  │ ││ │   │     Clothing    │ 🟧87% │ 🟥82% │ 🟨91% │       │
│   │t││u│ │ ││ │  │ ││ │  │ ││ │   │     Accessories │ 🟩99% │ 🟩97% │ 🟩96% │       │
│   └─┘└─┘ └┘└┘  └┘└┘  └┘└┘   │                                                    │
│   gap:$120  $8    $3   $0.5   │   Color: 🟥<85% 🟧85-92% 🟨92-97% 🟩>97%         │
│                                │   Circle size = Revenue volume                     │
├────────────────────────────────┼────────────────────────────────────────────────────┤
│                                │                                                    │
│  Revenue vs Margin Scatter     │   Margin Leaderboard                              │
│                                │                                                    │
│  ▲ GM%                         │   🏆 TOP 10 GM%      │  ⚠️ BOTTOM 10 GM%          │
│  │ 🔬             💎           │   ─────────────────  │  ─────────────────          │
│  │  ·  ·    ○ ○  ●●           │   1. Prod_A  62% ▲  │  1. Prod_X  8% 🚨          │
│  │   ·    ○    ● ●●●          │   2. Prod_B  58%    │  2. Prod_Y  12%             │
│ 30├──────────────────          │   3. Prod_C  55% ▲  │  3. Prod_Z  15% 🚨          │
│  │  ·         ○  ●            │   4. Prod_D  53%    │  4. Prod_W  18%             │
│  │ ❌         🚨               │   5. ...            │  5. ...                     │
│  │  · ·    ○  ● ●●            │                      │                             │
│  └───────────────────▶ Rev($) │   🚨 = Revenue > $500K (margin alert)              │
│  ● Bikes ○ Comp · Cloth/Acc   │                                                    │
├────────────────────────────────┼────────────────────────────────────────────────────┤
│                                │                                                    │
│  Category P&L Waterfall        │   📊 Product Detail Table                         │
│                                │   ┌──────┬──────┬─────┬──────┬─────┬──────┬─────┐ │
│  $109.8M           $40.5M     │   │Prod  │Cat   │ Qty │Rev   │COGS │GM%   │Prc% │ │
│  ██                    ██     │   ├──────┼──────┼─────┼──────┼─────┼──────┼─────┤ │
│  ██ ▓▓▓▓ ▓▓ ▓ ▓       ██     │   │Road  │Bikes │2.1K│$1.2M │$640K│🟩47% │ 95% │ │
│  ██ Bikes Comp Cl Ac   ██     │   │Mount │Bikes │1.8K│$980K │$520K│🟩47% │ 93% │ │
│  Rev -52M -11M -4 -2  GP     │   │Chain │Comp  │ 890│$340K │$290K│🟧15% │🟥82%│ │
│                                │   │...   │...   │ ... │...   │...  │...   │...  │ │
│                                │   └──────┴──────┴─────┴──────┴─────┴──────┴─────┘ │
│                                │   [Search 🔍] [Export CSV] Page 1/12              │
└────────────────────────────────┴────────────────────────────────────────────────────┘
```

---

## DATA MODEL MAPPING

### Primary Tables

| Table | Role | Grain |
|---|---|---|
| `fct_sale` | Revenue & Sales transactions | 1 row = 1 sales order line item |
| `dim_product` | Product hierarchy, pricing, classification | 1 row = 1 product |
| `dim_date` | Calendar hierarchy (Year, Quarter, Month) | 1 row = 1 date |

### Key Fields Used

| Field | Table | Usage |
|---|---|---|
| `line_total` | fct_sale | Revenue per line item |
| `order_qty` | fct_sale | Quantity sold |
| `unit_price` | fct_sale | Actual selling price |
| `unit_price_discount` | fct_sale | Discount rate (0–1) |
| `sales_channel` | fct_sale | Internet / Reseller filter |
| `standard_cost` | dim_product | COGS basis per unit |
| `list_price` | dim_product | Catalog / sticker price |
| `product_name` | dim_product | Individual product identification |
| `product_category_name` | dim_product | Top-level category (Bikes, Components, Clothing, Accessories) |
| `product_subcategory_name` | dim_product | Subcategory drill-down |
| `product_line_code` | dim_product | Product line classification |
| `class_code` | dim_product | Product class classification |
| `calendar_year` / `calendar_quarter` | dim_date | Time period filtering |

### Key Calculations

| Metric | SQL Expression |
|---|---|
| **Revenue** | `SUM(s.line_total)` |
| **COGS** | `SUM(p.standard_cost * s.order_qty)` |
| **Gross Profit** | `Revenue − COGS` |
| **Gross Margin %** | `GP / Revenue × 100` |
| **Price Realization %** | `SUM(unit_price × order_qty) / SUM(list_price × order_qty) × 100` |
| **Price Gap $** | `Wtd Avg List Price − Wtd Avg Actual Price` |
| **Revenue Share %** | `Category Revenue / Total Revenue × 100` |
| **Revenue Growth %** | `(Current Period Revenue − Prior Period Revenue) / Prior Period Revenue × 100` |
| **Avg Selling Price** | `SUM(unit_price × order_qty) / SUM(order_qty)` |
| **Discount Rate** | `AVG(unit_price_discount) × 100` |

### Cross-Dashboard Navigation

| From This Dashboard | Navigate To | Trigger |
|---|---|---|
| BCG Bubble → Category | #4 Profitability Analysis | Click category bubble → margin trends for that category |
| Scatter → Product | #3 Cost Structure | Click product → see cost variance for that product in manufacturing |
| Price Gap chart | #2 Revenue Deep Dive | Click category → see revenue & discount deep dive by channel |
| Margin Alert products | #6 Procurement Finance | Click product → see vendor cost & procurement spend for raw materials |
| Detail Table → Category | #1 Financial Overview | Click category → see impact on overall P&L |

---

## DIFFERENTIATION: PRODUCT PORTFOLIO FINANCE vs SCM PRODUCT & CATEGORY

| Dimension | This Dashboard (Finance #7) | SCM #7 Product & Category |
|---|---|---|
| **Primary Lens** | Monetary profitability & pricing strategy | Operational volume & efficiency |
| **Core Question** | "Which products make us money and which destroy margin?" | "Which products sell the most and how efficiently do we produce them?" |
| **BCG Matrix Axes** | Revenue Share % × Revenue Growth % (profit colored) | Demand Volume × Growth Rate (operational) |
| **Pricing Focus** | List Price vs Actual Price, Price Realization %, Price Gap | Discount % vs Volume trade-off |
| **Margin View** | GM% with standard cost basis, margin alert flags | Cost variance (planned vs actual manufacturing cost) |
| **Actionable Output** | Pricing correction recommendations for high-revenue/low-margin products | Production optimization, make-vs-buy decisions |
| **KPI Units** | Dollars ($), Percentages (%), Growth rates | Units, Quantities, Days, Yield % |

> **Key Insight**: Finance #7 answers "**should we reprice or discontinue this product?**" while SCM #7 answers "**should we make more or less of this product?**" — they are complementary views of the same product hierarchy.

---

## KEY INSIGHTS THIS DASHBOARD ENABLES

1. **Portfolio Health Check** — BCG bubble chart instantly reveals which categories are driving growth vs. coasting, enabling strategic resource allocation (invest in Stars, harvest Cash Cows, fix or exit Dogs)

2. **Pricing Power Visibility** — Price Realization heatmap exposes categories/subcategories where actual selling prices deviate significantly from list prices, quantifying revenue leakage from discounting

3. **Margin Alert System** — The Revenue × Margin scatter plot with the 🚨 MARGIN ALERT quadrant directly flags high-revenue products that are eroding profitability — the most actionable finding for pricing teams

4. **Category P&L Transparency** — Waterfall chart makes it viscerally clear how each category's COGS consumes revenue to arrive at total GP, helping prioritize cost reduction efforts by material impact
