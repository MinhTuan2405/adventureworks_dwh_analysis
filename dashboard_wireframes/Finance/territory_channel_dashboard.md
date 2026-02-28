# Territory & Channel Financial Performance Dashboard

**Overall Objective:** Compare financial performance — revenue, COGS, gross profit, and margin — across sales territories and between Internet vs Reseller channels. Identify which geographies and channels are most profitable, detect shifts in channel mix by region, and spotlight territories with the strongest growth momentum or decline to guide expansion/consolidation decisions.

---

## BUSINESS QUESTIONS ADDRESSED

1. Which territories and territory groups generate the highest revenue, profit, and margin — and how do they rank against each other?
2. How does the Internet vs Reseller channel mix differ across territories, and which channel is more profitable in each region?
3. Which territories show the strongest revenue growth momentum, and which are declining — signaling expansion or consolidation opportunities?

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                        Territory & Channel Financial Performance Dashboard                            │
│                                                                                                      │
│  Drill-down from Financial Overview (#1);                                                            │
│  feeds into Profitability Analysis (#4) for margin-by-channel deep dive                              │
├──────────┬─────────────────┬──────────────────────────────────────┬───────────────────────────────────┤
│          │                 │                                      │      Summary / Intended Use       │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Territory KPI   │ Territory Ranking Map / Bar Chart    │                                   │
│          │ Cards           │                                      │  • Headline: total revenue, GP,   │
│ Territory│                 │   Geo Bubble Map (size = revenue,    │    GM% across all territories     │
│ Ranking  │  Total Revenue  │   color = GM%) or Horizontal Bar     │  • Map/bar: visual comparison     │
│  &       │  Total GP       │   (sorted by revenue, with GM%      │    of revenue magnitude + margin  │
│ Overview │  Avg GM%        │    as color gradient)                │    quality across territories     │
│          │  # Territories  │                                      │  • Identify "big but thin" vs     │
│          │  + Sparklines   │   + Rank badges (#1, #2, #3...)     │    "small but rich" territories   │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Channel Mix     │ Channel Profitability by Territory   │                                   │
│ Channel  │ by Territory    │                                      │  • Stacked bar: revenue split per │
│  Mix &   │ Group           │   Grouped Bar: Internet GM% vs      │    territory to see channel mix   │
│ Profit-  │                 │   Reseller GM% per territory         │  • Grouped bar: which channel is  │
│ ability  │  100% Stacked   │   + Overall avg GM% reference line  │    more profitable in each region │
│          │  Bar (Revenue)  │   + Highlight: territories where     │  • Detect regions with unhealthy  │
│          │  per Territory  │     Reseller > Internet margin       │    channel imbalance or surprise  │
│          │  Group          │     (or vice versa)                  │    outperformance                 │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Territory Growth│ Growth Scatter Plot                  │                                   │
│ Growth   │ Leaderboard     │                                      │  • Leaderboard: who's growing     │
│ Momentum │                 │   X = Revenue (size/maturity)        │    fastest, who's shrinking        │
│  &       │  Table: sorted  │   Y = Growth % (YoY)                │  • Scatter: combines size with    │
│ Trends   │  by growth %    │   Color = Territory Group            │    growth — quadrant logic:        │
│          │  with arrows    │   Quadrant: high/low revenue ×      │    expand vs consolidate signals  │
│          │  (▲ expand      │   high/low growth                   │  • Trend lines for top-N          │
│          │   ▼ decline)    │                                      │    territories                    │
├──────────┼─────────────────┼──────────────────────────────────────┼───────────────────────────────────┤
│          │ Territory Group │ Territory Detail Table                │                                   │
│  Detail  │ Summary Cards   │                                      │  • Group-level summary cards for  │
│  Break-  │                 │   Territory | Country | Group |      │    quick executive comparison      │
│  down    │  Per Group:     │   Revenue | COGS | GP | GM% |        │  • Full detail table: every        │
│          │  Revenue, GP,   │   Channel Mix % | Growth % |         │    territory with all financial    │
│          │  GM%, Growth %  │   PY Revenue | Rank                  │    metrics + export                │
└──────────┴─────────────────┴──────────────────────────────────────┴───────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (from fct_sale + dim_sales_territory + dim_product + dim_date)
- ◻ Intermediate metric (derived from multiple fields)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: YTD / Territory**

**"Global Filters"** govern the data that feeds into the dashboard — default shows YTD, all territories, all channels.

```
Global Filters:     │ Timeframe: XX - YY             │
                    │ Territory Group                  │
                    │ Sales Channel                    │
                    │ Product Category (optional)      │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Territory KPI Cards + Territory Ranking Map / Bar

| Cell | Spec |
|------|------|
| **Territory KPI Cards** | 4 Headline Cards + Sparklines |
| | Timeframe: Point-in-Time |
| | Measurement Range: Cumulative YTD |
| | Source: fct_sale + dim_product + dim_sales_territory |
| | **Card 1 — Total Revenue**: `SUM(line_total)` across all territories + YoY% |
| | **Card 2 — Total Gross Profit**: `SUM(line_total) − SUM(standard_cost × order_qty)` + YoY% |
| | **Card 3 — Average Gross Margin %**: `GP / Revenue × 100` (weighted average) + YoY delta (pp) + Sparkline (12M) |
| | **Card 4 — Active Territories**: `COUNT(DISTINCT territory_name)` with revenue > 0 |
| | Sub-metric on Card 3: Best territory GM% / Worst territory GM% |

| Cell | Spec |
|------|------|
| **Territory Ranking Map / Horizontal Bar** | Geo Bubble Map or Horizontal Bar Chart |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Territory |
| | Source: fct_sale + dim_product + dim_sales_territory |
| | **Option A — Geo Bubble Map**: |
| | Bubble location: territory geographical position |
| | Bubble size: `Revenue = SUM(line_total)` |
| | Bubble color: `GM% gradient` (red < 30%, yellow 30-40%, green > 40%) |
| | **Option B — Horizontal Bar Chart** (recommended default): |
| | Bars: Revenue per territory, sorted descending |
| | Color fill: GM% gradient (same thresholds) |
| | Rank badge labels: #1, #2, #3 on top 3 bars |
| | Secondary axis or inline label: GP amount |
| | Tooltip: Territory, Group, Country, Revenue, COGS, GP, GM%, Rank |
| | 🟧 Toggle – Map / Bar view |
| | 🟧 Toggle – Metric (Revenue / GP / GM%) |
| | 🟥 Filter – Sales Channel |
| | 🟥 Filter – Product Category |

---

### ROW 2: Channel Mix by Territory Group + Channel Profitability by Territory

| Cell | Spec |
|------|------|
| **Channel Mix by Territory Group** | 100% Stacked Bar Chart |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Territory Group |
| | Source: fct_sale + dim_sales_territory |
| | X-axis: Territory Group (North America, Europe, Pacific) |
| | Segments: Internet Revenue % (blue) + Reseller Revenue % (orange) |
| | Label on each segment: Revenue $ + % |
| | Sorted by: Total Revenue descending |
| | 🟧 Toggle – Group by Group / Country / Territory |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Channel Profitability by Territory** | Grouped Bar Chart + Reference Line |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative per Territory |
| | Source: fct_sale + dim_product + dim_sales_territory |
| | X-axis: Territory name (sorted by total revenue) |
| | Bars (grouped): Internet GM% (blue) + Reseller GM% (orange) |
| | Reference line: Overall weighted GM% (dashed) |
| | Annotations: |
| | — ⚠ Flag territories where Reseller GM% > Internet GM% (unusual) |
| | — ⚠ Flag territories where either channel GM% < 25% (low margin alert) |
| | **Comparison Table below chart**: |
| | Columns: Territory │ Internet Rev │ Internet GM% │ Reseller Rev │ Reseller GM% │ Δ GM% (I−R) │ Dominant Channel |
| | Dominant Channel = whichever has higher GM% |
| | 🟧 Toggle – Group by Group / Country / Territory |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Territory Group |

---

### ROW 3: Territory Growth Leaderboard + Growth Scatter Plot

| Cell | Spec |
|------|------|
| **Territory Growth Leaderboard** | Ranked Table with Direction Arrows |
| | Timeframe: YTD vs Prior Year (or selected periods) |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product + dim_sales_territory + dim_date |
| | Columns: |
| | — Rank (by Growth %) |
| | — Direction Arrow (▲ growing / ▼ declining / ─ flat) |
| | — Territory Name |
| | — Territory Group |
| | — Revenue YTD |
| | — Revenue PY |
| | — Revenue Growth $ |
| | — Revenue Growth % |
| | — GP Growth % |
| | — GM% Change (pp) |
| | Sorted by: Revenue Growth % descending |
| | Conditional formatting: |
| | — Growth % > 15%: green + ▲▲ (strong expand signal) |
| | — Growth % 0-15%: light green + ▲ (moderate) |
| | — Growth % -10% to 0%: yellow + ▼ (watch) |
| | — Growth % < -10%: red + ▼▼ (consolidation signal) |
| | 🟧 Toggle – Sales Channel |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Growth Scatter Plot** | Scatter / Bubble Chart with Quadrants |
| | Timeframe: YTD vs PY |
| | Measurement Range: Per Territory |
| | Source: fct_sale + dim_product + dim_sales_territory + dim_date |
| | X-axis: `Revenue = SUM(line_total)` (size/maturity) |
| | Y-axis: `Revenue Growth % = (Rev_YTD − Rev_PY) / Rev_PY × 100` |
| | Bubble size: `Gross Profit = SUM(line_total) − SUM(standard_cost × order_qty)` |
| | Bubble color: Territory Group |
| | Quadrant lines: |
| | — Vertical: Median Revenue across territories |
| | — Horizontal: 0% growth line |
| | Quadrants: |
| | — Q1 (top-right): High Revenue + Growing → ✅ **"Stars — defend & invest"** |
| | — Q2 (top-left): Low Revenue + Growing → 🚀 **"Rising — expand aggressively"** |
| | — Q3 (bottom-left): Low Revenue + Declining → 🚨 **"Dogs — consolidate or exit"** |
| | — Q4 (bottom-right): High Revenue + Declining → ⚠️ **"Cash Cows at risk — investigate"** |
| | Tooltip: Territory, Group, Revenue, Growth %, GP, GM% |
| | 🟧 Toggle – Sales Channel |
| | 🟧 Toggle – Growth metric (Revenue Growth / GP Growth / GM% Change) |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |

---

### ROW 4: Territory Group Summary Cards + Territory Detail Table

| Cell | Spec |
|------|------|
| **Territory Group Summary Cards** | 3 Group Cards (North America / Europe / Pacific) |
| | Timeframe: YTD |
| | Measurement Range: Cumulative per Group |
| | Source: fct_sale + dim_product + dim_sales_territory |
| | **Per Card**: |
| | — Group Name (header) |
| | — Revenue ($ + % of total) |
| | — Gross Profit ($ + % of total) |
| | — GM% (+ delta vs overall) |
| | — Revenue Growth % (YoY) |
| | — Internet : Reseller mix ratio (e.g., "62% : 38%") |
| | — Top territory in group (by revenue) |
| | — Bottom territory in group (by GM%) |
| | Cards arranged side-by-side, color-coded by group |
| | Conditional: GM% green > 40%, yellow 30-40%, red < 30% |

| Cell | Spec |
|------|------|
| **Territory Detail Table** | Full Detail Table; Sortable; Exportable |
| | Timeframe: YTD (or selected period) |
| | Measurement Range: Cumulative |
| | Source: fct_sale + dim_product + dim_sales_territory + dim_date |
| | Columns: |
| | — Territory Group |
| | — Country |
| | — Territory Name |
| | — Revenue |
| | — COGS |
| | — Gross Profit |
| | — GM% |
| | — Internet Rev % (channel mix) |
| | — Reseller Rev % |
| | — Internet GM% |
| | — Reseller GM% |
| | — Revenue Growth % (YoY) |
| | — GP Growth % (YoY) |
| | — Revenue Rank |
| | — GM% Rank |
| | — PY Revenue |
| | — PY GM% |
| | Features: |
| | — Sortable by any column |
| | — Group-level subtotal rows (collapse/expand) |
| | — Conditional formatting: GM% gradient, Growth % color scale |
| | — Flag: territories with Revenue Rank ≤ 3 AND GM% Rank > 7 → "High-rev, low-margin region alert" |
| | — Flag: territories with Growth % < -10% → "Decline alert" |
| | 🟧 Toggle – Sales Channel breakdown (show/hide Internet & Reseller columns) |
| | 🟥 Filter – Territory Group |
| | 🟥 Filter – Product Category |
| | Export: CSV / Excel |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: YTD / Territory**

```
                                                          ┌──────────────────────────────┐
  "Hover-over" capability required to                     │  Timeframe: XX - YY          │
  highlight territory and channel detail                  │  Territory Group              │
  (e.g., revenue, margin, channel mix)                    │  Sales Channel                │
                                                          │  Product Category (optional)  │
  Drill-through to Profitability (#4)                     └──────────────────────────────┘
  for margin deep-dive by channel

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROW 1: TERRITORY RANKING & OVERVIEW                                                     Q1        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Territory KPI Cards                      │  │  Territory Ranking (Horizontal Bar)               │ │
│  │                                          │  │                                                  │ │
│  │  ┌─────────────────────────────────┐     │  │  Sorted by Revenue ↓   Color = GM% gradient     │ │
│  │  │  Total Revenue    $45.2M       │     │  │                                                  │ │
│  │  │                   +12.3% YoY   │     │  │  #1 ██████████████████████████████ $15.2M  38%   │ │
│  │  │                   ~~~~~~       │     │  │     Northwest                                    │ │
│  │  └─────────────────────────────────┘     │  │  #2 █████████████████████████████  $13.8M  41%   │ │
│  │  ┌─────────────────────────────────┐     │  │     Southwest                                   │ │
│  │  │  Total GP         $18.1M       │     │  │  #3 ███████████████████           $8.4M   36%   │ │
│  │  │                   +9.8% YoY    │     │  │     United Kingdom                               │ │
│  │  │                   ~~~~~~       │     │  │  #4 ███████████████                $6.1M   44%   │ │
│  │  └─────────────────────────────────┘     │  │     France                                      │ │
│  │  ┌─────────────────────────────────┐     │  │  #5 ████████████                  $4.8M   42%   │ │
│  │  │  Avg GM%          40.0%        │     │  │     Canada                                      │ │
│  │  │                   +0.8 pp YoY  │     │  │  #6 ██████████                    $3.9M   35%   │ │
│  │  │  Best: France 44% │Worst: NW 38│     │  │     Germany                                     │ │
│  │  │                   ~~~~~~       │     │  │  #7 █████████                     $2.8M   39%   │ │
│  │  └─────────────────────────────────┘     │  │     Australia                                   │ │
│  │  ┌─────────────────────────────────┐     │  │  #8 ████                          $1.2M   37%   │ │
│  │  │  # Territories    10           │     │  │     Central                                     │ │
│  │  └─────────────────────────────────┘     │  │  ...                                            │ │
│  │                                          │  │                                                  │ │
│  │  ~~~~~~ = Sparkline (last 12 months)     │  │  🟧 Toggle – Map / Bar  🟧 Toggle – Rev/GP/GM%  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟥 Filter – Sales Channel | Product Category        │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 2: CHANNEL MIX & CHANNEL PROFITABILITY BY TERRITORY                                 Q2        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Channel Mix by Territory Group           │  │ Channel Profitability by Territory               │ │
│  │                                          │  │                                                  │ │
│  │  100% Stacked Bar (Revenue)              │  │  Grouped Bar: Internet GM% vs Reseller GM%       │ │
│  │                                          │  │  ┈┈ Dashed: Overall avg GM%                      │ │
│  │  ■ Internet   □ Reseller                 │  │                                                  │ │
│  │                                          │  │  ■ Internet GM%   □ Reseller GM%                 │ │
│  │  North America │████████████░░░░░░░░│    │  │                                                  │ │
│  │    $29.0M      │  65%  ■   │ 35%  □ │    │  │      NW   SW   UK   FR   CA   DE   AU   CE      │ │
│  │                                          │  │     ┌────────────────────────────────────────┐   │ │
│  │  Europe        │██████░░░░░░░░░░░░░░│    │  │     │ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░│   │ │
│  │    $18.4M      │  38%  ■   │ 62%  □ │    │  │     │ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░│   │ │
│  │                                          │  │     │ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░│   │ │
│  │  Pacific       │██████████████░░░░░░│    │  │     │──┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈──│   │ │
│  │    $2.8M       │  72%  ■   │ 28%  □ │    │  │     │ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░ ██ ░░│   │ │
│  │                                          │  │     └────────────────────────────────────────┘   │ │
│  │  Insight: Europe is Reseller-heavy       │  │     ⚠ Germany: Reseller 38% > Internet 35%       │ │
│  │  Pacific is Internet-dominant            │  │                                                  │ │
│  │                                          │  │  ┌─ Comparison Table ───────────────────────┐   │ │
│  │  🟧 Toggle – Group / Country / Territory  │  │  │ Territory│INet Rev│INet GM%│Res Rev│Res GM%│  │ │
│  │                                          │  │  │ NW       │$9.9M   │ 41%    │$5.3M  │ 34%  │  │ │
│  │                                          │  │  │ SW       │$8.2M   │ 43%    │$5.6M  │ 38%  │  │ │
│  │                                          │  │  │ ...      │...     │ ...    │...    │ ...  │  │ │
│  │                                          │  │  └──────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                 🟥 Filter – Territory Group | Product Category      │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 3: GROWTH MOMENTUM                                                                  Q3        │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Territory Growth Leaderboard             │  │ Growth Scatter Plot                              │ │
│  │                                          │  │                                                  │ │
│  │  Rank│ Dir│ Territory  │ Rev YTD │Grw% │  │  ● = Territory (size = GP)                       │ │
│  │  ────┼────┼────────────┼─────────┼──── │  │  Color = Territory Group                          │ │
│  │  1   │ ▲▲ │ Southwest  │ $13.8M  │+22% │  │                                                  │ │
│  │  2   │ ▲▲ │ France     │  $6.1M  │+18% │  │  🚀 Rising     │ ✅ Stars                        │ │
│  │  3   │ ▲  │ Canada     │  $4.8M  │+11% │  │  (expand)      │ (defend & invest)               │ │
│  │  4   │ ▲  │ Australia  │  $2.8M  │ +8% │  │                │                                  │ │
│  │  5   │ ─  │ UK         │  $8.4M  │ +2% │  │ +30% ┌────────┼──────────────────────┐           │ │
│  │  6   │ ─  │ Northwest  │ $15.2M  │ +1% │  │      │  ●FR   │              ●SW     │           │ │
│  │  7   │ ▼  │ Germany    │  $3.9M  │ -5% │  │ Grw% │  ●CA   │                      │           │ │
│  │  8   │ ▼▼ │ Central    │  $1.2M  │-14% │  │      │  ●AU   │     ●UK    ●NW       │           │ │
│  │      │    │            │         │     │  │  0%  ─┼────────┼──────────────────────┤           │ │
│  │  Growth %  │ GP Grw % │ GM% Chg (pp)  │  │      │        │             ●DE      │           │ │
│  │  +22.0%    │ +19.5%   │ +0.8          │  │      │  ●CE   │                      │           │ │
│  │  +18.0%    │ +21.2%   │ +1.5          │  │ -20% └────────┴──────────────────────┘           │ │
│  │  ...       │ ...      │ ...           │  │      $0         Median         $15M               │ │
│  │                                          │  │               Revenue                            │ │
│  │  Color: ▲▲ green │ ▲ lt-green          │  │                                                  │ │
│  │         ─  gray  │ ▼ yellow │ ▼▼ red    │  │  🟧 Toggle – Rev Growth / GP Growth / GM% Chg    │ │
│  │                                          │  │                                                  │ │
│  │  🟧 Toggle – Sales Channel               │  │  🟧 Toggle – Sales Channel                      │ │
│  │  🟥 Filter – Territory Group              │  │  🟥 Filter – Territory Group | Product Category  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROW 4: GROUP SUMMARY & DETAIL TABLE                                                     Q1-Q3     │
│                                                                                                     │
│  ┌──────────────────────────────────────────┐  ┌──────────────────────────────────────────────────┐ │
│  │ Territory Group Summary Cards            │  │ Territory Detail Table                           │ │
│  │                                          │  │                                                  │ │
│  │  ┌───────────────────┐                   │  │  Group    │ Country │Terri.│Rev   │GP   │GM% │  │ │
│  │  │ 🟦 North America  │                   │  │  ─────────┼─────────┼──────┼──────┼─────┼────│  │ │
│  │  │ Revenue  $29.0M   │                   │  │  NAm      │ US      │NW    │$15.2M│$5.8M│38% │  │ │
│  │  │ GP       $11.3M   │                   │  │  NAm      │ US      │SW    │$13.8M│$5.7M│41% │  │ │
│  │  │ GM%      39.0%    │                   │  │  NAm      │ CA      │Cana. │$4.8M │$2.0M│42% │  │ │
│  │  │ Growth   +8.2%    │                   │  │  ── NAm Subtotal ──────── │$33.8M│$13.5│40% │  │ │
│  │  │ Mix: 65% I / 35% R│                   │  │  Europe   │ UK      │UK    │$8.4M │$3.0M│36% │  │ │
│  │  │ Top: NW ($15.2M)  │                   │  │  Europe   │ FR      │Fran. │$6.1M │$2.7M│44% │  │ │
│  │  │ Low GM: NW (38%)  │                   │  │  Europe   │ DE      │Germ. │$3.9M │$1.4M│35% │  │ │
│  │  └───────────────────┘                   │  │  ── EUR Subtotal ──────── │$18.4M│$7.1M│39% │  │ │
│  │  ┌───────────────────┐                   │  │  Pacific  │ AU      │Austr.│$2.8M │$1.1M│39% │  │ │
│  │  │ 🟧 Europe         │                   │  │  ── PAC Subtotal ──────── │$2.8M │$1.1M│39% │  │ │
│  │  │ Revenue  $18.4M   │                   │  │                                                  │ │
│  │  │ GP        $7.1M   │                   │  │  + Internet Rev% │ Reseller Rev% │ INet GM%     │ │
│  │  │ GM%      38.6%    │                   │  │  + Reseller GM%  │ Growth %      │ PY Revenue   │ │
│  │  │ Growth   +5.1%    │                   │  │  + Revenue Rank  │ GM% Rank                     │ │
│  │  │ Mix: 38% I / 62% R│                   │  │                                                  │ │
│  │  │ Top: UK ($8.4M)   │                   │  │  ⚠ NW: Rev Rank #1 but GM% Rank #7              │ │
│  │  │ Low GM: DE (35%)  │                   │  │    → "High-rev, low-margin region alert"         │ │
│  │  └───────────────────┘                   │  │                                                  │ │
│  │  ┌───────────────────┐                   │  │  ⚠ Central: Growth -14% → "Decline alert"       │ │
│  │  │ 🟩 Pacific        │                   │  │                                                  │ │
│  │  │ Revenue   $2.8M   │                   │  │  Sortable │ Subtotals │ Conditional formatting   │ │
│  │  │ GP        $1.1M   │                   │  │  🟧 Toggle – Channel breakdown columns           │ │
│  │  │ GM%      39.3%    │                   │  │  🟥 Filter – Territory Group | Product Category  │ │
│  │  │ Growth   +8.0%    │                   │  │  → Export: CSV / Excel                           │ │
│  │  │ Mix: 72% I / 28% R│                   │  │                                                  │ │
│  │  │ Top: AU ($2.8M)   │                   │  │                                                  │ │
│  │  └───────────────────┘                   │  │                                                  │ │
│  └──────────────────────────────────────────┘  └──────────────────────────────────────────────────┘ │
│                                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_sale` | Fact — grain: order line item. Revenue (`line_total`), quantity, unit price, discount, `sales_channel`, `dim_sales_territory_sk` |
| `dim_sales_territory` | Territory hierarchy: `territory_name`, `territory_group` (North America / Europe / Pacific), `country_name`. Also: `sales_ytd`, `sales_last_year`, `cost_ytd`, `cost_last_year`, `sales_growth`, `cost_growth` |
| `dim_product` | `standard_cost` (for COGS/GP), `product_category_name` (optional filter) |
| `dim_date` | Calendar year, quarter, month — for YoY growth calculations |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Revenue | `fct_sale.line_total` |
| COGS | `dim_product.standard_cost × fct_sale.order_qty` |
| Gross Profit | `line_total − (standard_cost × order_qty)` |
| Gross Margin % | `GP / Revenue × 100` |
| Channel | `fct_sale.sales_channel` (Internet / Reseller) |
| Territory Name | `dim_sales_territory.territory_name` |
| Territory Group | `dim_sales_territory.territory_group` (North America, Europe, Pacific) |
| Country | `dim_sales_territory.country_name` |
| Snapshot Metrics | `dim_sales_territory.sales_ytd`, `sales_last_year`, `cost_ytd`, `cost_last_year`, `sales_growth` |

### **Key Calculations**
```sql
-- =====================================================
-- ROW 1: Territory Ranking & Overview
-- =====================================================

-- Territory Financial Summary
SELECT
    dst.territory_group,
    dst.country_name,
    dst.territory_name,
    SUM(fs.line_total)                                         AS revenue,
    SUM(dp.standard_cost * fs.order_qty)                       AS cogs,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS gross_profit,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct,
    RANK() OVER (ORDER BY SUM(fs.line_total) DESC)              AS revenue_rank,
    RANK() OVER (ORDER BY 
        (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) DESC)                  AS margin_rank
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_sales_territory dst ON fs.dim_sales_territory_sk = dst.dim_sales_territory_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
WHERE d.calendar_year = 2014   -- current year
GROUP BY dst.territory_group, dst.country_name, dst.territory_name
ORDER BY revenue DESC


-- =====================================================
-- ROW 2: Channel Mix & Channel Profitability
-- =====================================================

-- Channel Mix by Territory / Territory Group
SELECT
    dst.territory_group,
    dst.territory_name,
    fs.sales_channel,
    SUM(fs.line_total)                                         AS channel_revenue,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS channel_gp,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS channel_gm_pct
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_sales_territory dst ON fs.dim_sales_territory_sk = dst.dim_sales_territory_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dst.territory_group, dst.territory_name, fs.sales_channel
ORDER BY dst.territory_group, dst.territory_name, fs.sales_channel

-- Channel Mix % (pivot)
-- Internet_Rev_Pct = Internet_Revenue / Total_Revenue * 100
-- Reseller_Rev_Pct = Reseller_Revenue / Total_Revenue * 100
-- Dominant_Channel = CASE WHEN Internet_GM% > Reseller_GM% THEN 'Internet' ELSE 'Reseller' END


-- =====================================================
-- ROW 3: Growth Momentum
-- =====================================================

-- Territory Growth (YTD vs PY)
WITH current_year AS (
    SELECT
        dst.territory_name,
        dst.territory_group,
        SUM(fs.line_total)                                         AS rev_ytd,
        SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS gp_ytd,
        (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
            / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct_ytd
    FROM fct_sale fs
    JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
    JOIN dim_sales_territory dst ON fs.dim_sales_territory_sk = dst.dim_sales_territory_sk
    JOIN dim_date d ON fs.order_date_key = d.date_key
    WHERE d.calendar_year = 2014
    GROUP BY dst.territory_name, dst.territory_group
),
prior_year AS (
    SELECT
        dst.territory_name,
        SUM(fs.line_total)                                         AS rev_py,
        SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS gp_py,
        (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
            / NULLIF(SUM(fs.line_total), 0) * 100                  AS gm_pct_py
    FROM fct_sale fs
    JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
    JOIN dim_sales_territory dst ON fs.dim_sales_territory_sk = dst.dim_sales_territory_sk
    JOIN dim_date d ON fs.order_date_key = d.date_key
    WHERE d.calendar_year = 2013
    GROUP BY dst.territory_name
)
SELECT
    cy.territory_name,
    cy.territory_group,
    cy.rev_ytd,
    py.rev_py,
    cy.rev_ytd - py.rev_py                                  AS rev_growth_abs,
    (cy.rev_ytd - py.rev_py) / NULLIF(py.rev_py, 0) * 100  AS rev_growth_pct,
    (cy.gp_ytd - py.gp_py) / NULLIF(py.gp_py, 0) * 100    AS gp_growth_pct,
    cy.gm_pct_ytd - py.gm_pct_py                            AS gm_change_pp,
    cy.gp_ytd                                                AS gp_ytd
FROM current_year cy
LEFT JOIN prior_year py ON cy.territory_name = py.territory_name
ORDER BY rev_growth_pct DESC

-- Growth Scatter Quadrant Lines
Median_Revenue = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rev_ytd)
Growth_Zero    = 0  -- horizontal reference at 0% growth

-- Growth Classification
CASE
    WHEN rev_growth_pct > 15   THEN '▲▲ Strong Expand'
    WHEN rev_growth_pct > 0    THEN '▲ Moderate'
    WHEN rev_growth_pct > -10  THEN '▼ Watch'
    ELSE                            '▼▼ Consolidation Signal'
END AS growth_signal


-- =====================================================
-- ROW 4: Group Summary & Detail Table
-- =====================================================

-- Territory Group Summary
SELECT
    dst.territory_group,
    SUM(fs.line_total)                                         AS group_revenue,
    SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty)  AS group_gp,
    (SUM(fs.line_total) - SUM(dp.standard_cost * fs.order_qty))
        / NULLIF(SUM(fs.line_total), 0) * 100                  AS group_gm_pct,
    SUM(fs.line_total) * 100.0 / SUM(SUM(fs.line_total)) OVER() AS pct_of_total_rev,
    -- Internet Mix
    SUM(CASE WHEN fs.sales_channel = 'Internet' THEN fs.line_total ELSE 0 END)
        * 100.0 / NULLIF(SUM(fs.line_total), 0)                AS internet_mix_pct,
    -- Top territory by revenue within group
    -- (use window function or subquery)
FROM fct_sale fs
JOIN dim_product dp ON fs.dim_product_sk = dp.dim_product_sk
JOIN dim_sales_territory dst ON fs.dim_sales_territory_sk = dst.dim_sales_territory_sk
JOIN dim_date d ON fs.order_date_key = d.date_key
WHERE d.calendar_year = 2014
GROUP BY dst.territory_group

-- Detail Table — Territory Level (full export)
-- Combines all metrics from ROW 1 + ROW 2 + ROW 3 into one flat table
-- Add: Internet_Rev_Pct, Reseller_Rev_Pct, Internet_GM%, Reseller_GM%,
--      Growth %, PY Revenue, Revenue Rank, GM% Rank
-- Group subtotals via GROUPING SETS or application-layer rollup
```

### **Alternative Data Source: Snapshot Metrics**
`dim_sales_territory` includes pre-aggregated snapshot fields that can be used for quick comparisons without joining to `fct_sale`:

| Field | Use |
|-------|-----|
| `sales_ytd` | Quick territory revenue check |
| `sales_last_year` | Prior year benchmark |
| `cost_ytd` | Territory cost snapshot |
| `cost_last_year` | Prior year cost benchmark |
| `sales_growth` | `sales_ytd − sales_last_year` (pre-calculated) |
| `cost_growth` | `cost_ytd − cost_last_year` (pre-calculated) |

> **Note**: These snapshot fields are static (point-in-time from source system), not dynamic. For time-series analysis (monthly/quarterly trends), always use `fct_sale` joined to `dim_date`. Use snapshot metrics only for quick KPI cards or validation.

### **Cross-Dashboard Navigation**
| From This Dashboard | Drill To | Purpose |
|---------------------|----------|---------|
| Territory with low GM% | Profitability Analysis (#4) | Deep-dive into which products/discounts cause low margin in that territory |
| Territory with high revenue but declining growth | Revenue Deep Dive (#2) | Investigate revenue trend and seasonal patterns for that territory |
| Territory with high cost-to-revenue | Cost Structure (#3) | Investigate which cost components are elevated in that region |
| Territory Group summary card | Financial Overview (#1) | Full P&L context |
| High-discount territory + channel | Profitability (#4) Scatter Plot | Check if discount-margin erosion is territory-specific |
| Top territory detail row | Product Portfolio (#7) | Investigate product mix driving territory performance |

### **Key Insight: Channel-Territory Matrix**
```
Channel-Territory Profitability Matrix:
┌───────────────┬────────────┬────────────┬──────────────┐
│ Territory     │ Internet   │ Reseller   │ Insight      │
│               │ GM%        │ GM%        │              │
├───────────────┼────────────┼────────────┼──────────────┤
│ Northwest     │ 41%        │ 34%        │ Normal gap   │
│ Germany       │ 35%        │ 38%        │ ⚠ Reseller   │
│               │            │            │   outperforms│
│ France        │ 48%        │ 40%        │ Internet     │
│               │            │            │   strong     │
└───────────────┴────────────┴────────────┴──────────────┘

Action triggers:
• Reseller GM% > Internet GM% in a territory → investigate Internet pricing/discount policy
• Either channel GM% < 25% → margin crisis, escalate
• Channel mix > 80% one channel → concentration risk
```
