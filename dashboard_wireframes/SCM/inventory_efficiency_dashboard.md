# Inventory Efficiency Dashboard

**Overall Objective:** Evaluate inventory health against safety-stock thresholds, identify dead/slow-moving stock risk by category, and assess fulfillment readiness — to optimize capital allocation, reduce waste, and prevent stockouts.

---

## VERSION 1: CRAWL

```
┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                   Inventory Efficiency Dashboard                                     │
│                                                                                                      │
│  Detailed cost breakdowns and historical trends                                                      │
│  incorporated in separate SCM Cost Deep Dive dashboard                                               │
├──────────┬──────────────────┬──────────────────────────────────────┬──────────────────────────────────┤
│          │                  │                                      │      Summary / Intended Use      │
├──────────┼──────────────────┼──────────────────────────────────────┼──────────────────────────────────┤
│          │ Total Inventory  │ Stock Level Distribution &           │                                  │
│          │ Value & Safety   │ Capital Tied Up by Category          │  • High-level summary of         │
│ Stock    │ Stock Coverage   │   Low / Mid / High vs Safety Stock   │    current inventory position    │
│ Level    ├──────────────────┼──────────────────────────────────────┤    against safety-stock policy   │
│ &        │ Items Below      │ Excess Inventory Value by            │  • Use to quickly assess how     │
│ Capital  │ Safety Stock &   │ Product Category                     │    much capital is tied up in     │
│          │ Reorder Point    │   Capital at risk in overstock       │    excess vs undestocked items   │
│          ├──────────────────┼────────────────────┬─────────────────┤  • Enable visibility into stock  │
│          │ Stock Level      │ Qty vs Safety Stock│ Inventory Value │    level policy adherence         │
│          │ Status Summary   │ Scatter (by SKU)   │ Trend (Snapshot)│                                  │
│          │ ( Intermediate ) │                    │                 │                                  │
├──────────┼──────────────────┼────────────────────┴─────────────────┤                                  │
│          │ Dead Stock &     │                                      │  • Summarizes stock aging and     │
│ Turnover │ Slow Moving      │ Stock Health Breakdown by Category   │    dead stock risk across         │
│ & Dead   │ SKU Count        │ (Active / Slow Moving / Dead Stock)  │    product categories             │
│ Stock    ├──────────────────┼──────────────────────────────────────┤  • Leverage to plan markdowns,   │
│          │ Days Since Last  │ Inventory Turnover by Category       │    liquidation, or portfolio      │
│          │ Sale / Receipt   │ & Turnover Trend                     │    exits on aging inventory       │
│          │ ( Intermediate ) │                                      │                                  │
├──────────┼──────────────────┼────────────────────┬─────────────────┤                                  │
│          │ Stockout Risk    │ Fulfillment        │ Stock Coverage  │  • Detail on current ability      │
│ Fulfill- │ Summary          │ Readiness by       │ Days by         │    to fulfill orders without      │
│ ment     │ (Items at/below  │ Category           │ Category        │    running out of stock           │
│ Readi-   │ reorder point)   │                    │                 │  • Use alongside procurement      │
│ ness     │                  │                    │                 │    data to trigger reorders        │
└──────────┴──────────────────┴────────────────────┴─────────────────┴──────────────────────────────────┘
```

**Legend:**
- ☐ Crawl metrics (available from fct_inventory + fct_inventory_daily_snapshot + fct_transaction)
- ◻ Intermediate metric (derived, not headline)

---

## VERSION 2: DETAIL

### **Default Timeframe / Granularity: Current Snapshot + Daily Trend**

**"Global Filters"** govern the data that feeds into the dashboard (i.e., limiting all views to just the selections) — default set to current snapshot view.

```
Global Filters:     │ Snapshot Date (or Range)     │
                    │ Product Category             │
                    │ Stock Health Status           │
                    │ Stock Level Status            │
                    │ Location (Work Center)        │
```

**Legend:**
- 🟧 Filters for "Crawl"
- 🟥 Filters for "Walk/Run"

---

### ROW 1: Total Inventory Value & Safety Stock Coverage

| Cell | Spec |
|------|------|
| **Total Inventory Value & Safety Stock Coverage** | Headline Number + Trends |
| | Timeframe: Point-in-Time (Current Snapshot) |
| | Measurement Range: Current |
| | Source: fct_inventory + dim_product |
| | `Total_Value = SUM(total_actual_value)` (qty × list_price) |
| | `Total_Cost_Value = SUM(total_manufacture_value)` (qty × standard_cost) |
| | `Total_SKUs = COUNT(DISTINCT product_id)` |
| | `Total_Qty = SUM(quantity)` |
| | `Avg_Safety_Coverage = AVG(quantity / NULLIF(safety_stock_level, 0))` |
| | `Items_Below_Safety = COUNT(CASE WHEN stock_level_status = 'Low' THEN 1 END)` |

| Cell | Spec |
|------|------|
| **Stock Level Distribution & Capital by Category** | Stacked Bar (Qty by Level) + Table (Capital) |
| | Timeframe: Current Snapshot |
| | Measurement Range: Current |
| | Source: fct_inventory + dim_product |
| | `Qty_by_Level = SUM(quantity) GROUP BY stock_level_status, product_category_name` |
| | `Capital = SUM(total_manufacture_value) GROUP BY product_category_name` |
| | Stacks: Low (🔴), Mid (🟡), High (🟢) |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Location |
| | 🟥 Filter – Stock Health Status |

---

### ROW 2: Safety Stock Alerts & Excess Inventory

| Cell | Spec |
|------|------|
| **Items Below Safety Stock & Reorder Point** | Table with Conditional Formatting |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | Columns: Product, Qty, Safety Stock, Reorder Point, Gap, Value at Risk |
| | `Safety_Gap = safety_stock_level - quantity` (where quantity < safety_stock) |
| | `Reorder_Gap = reorder_point - quantity` (where quantity < reorder_point) |
| | `Value_at_Risk = Safety_Gap × standard_cost` |
| | 🔴 Below Safety & Reorder / 🟡 Below Safety only / 🟢 Above both |
| | 🟧 Toggle – Below Safety / Below Reorder / All |
| | 🟥 Filter – Product Category |

| Cell | Spec |
|------|------|
| **Excess Inventory Value by Product Category** | Horizontal Bar (sorted by excess value) |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | `Excess_Qty = quantity - (safety_stock_level * 3)` WHERE stock_level_status = 'High' |
| | `Excess_Value = Excess_Qty × standard_cost` |
| | `% of Total Capital = Excess_Value / Total_Cost_Value * 100` |
| | 🟧 Toggle – Category vs Subcategory |
| | 🟥 Filter – Location |

---

### ROW 3: SKU-level Scatter & Inventory Value Trend

| Cell | Spec |
|------|------|
| **Stock Level Status Summary** | KPI Cards |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory |
| | `Low_Count = COUNT(stock_level_status = 'Low')` |
| | `Mid_Count = COUNT(stock_level_status = 'Mid')` |
| | `High_Count = COUNT(stock_level_status = 'High')` |
| | `Low_% = Low_Count / Total_SKUs * 100` |
| | `Avg_Qty_Per_SKU = SUM(quantity) / COUNT(DISTINCT product_id)` |

| Cell | Spec |
|------|------|
| **Quantity vs Safety Stock (Scatter by SKU)** | Scatter Plot |
| | X-axis: Safety Stock Level |
| | Y-axis: Current Quantity |
| | Color: stock_level_status (Low 🔴 / Mid 🟡 / High 🟢) |
| | Size: total_manufacture_value |
| | Reference Line: y = x (perfect coverage) |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | Above line = overstock, Below line = understock |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Stock Health Status |

| Cell | Spec |
|------|------|
| **Inventory Value Trend (Daily Snapshot)** | Area Chart |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Daily / Weekly aggregate |
| | Source: fct_inventory_daily_snapshot + dim_product |
| | `Daily_Value = SUM(quantity_on_hand × standard_cost)` |
| | 🟧 Drop-Down Filter – Product Category |
| | 🟥 Filter – Specific Products |

---

### ROW 4: Dead Stock & Stock Health Breakdown

| Cell | Spec |
|------|------|
| **Dead Stock & Slow Moving SKU Count** | Headline Number + Trends |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory |
| | `Dead_Stock_SKUs = COUNT(stock_health_status = 'Dead Stock')` |
| | `Slow_Moving_SKUs = COUNT(stock_health_status = 'Slow Moving')` |
| | `Active_SKUs = COUNT(stock_health_status = 'Active')` |
| | `Dead_Stock_Value = SUM(total_manufacture_value) WHERE stock_health_status = 'Dead Stock'` |
| | `Slow_Moving_Value = SUM(total_manufacture_value) WHERE stock_health_status = 'Slow Moving'` |
| | `At_Risk_Capital = Dead_Stock_Value + Slow_Moving_Value` |

| Cell | Spec |
|------|------|
| **Stock Health Breakdown by Category** | Stacked Bar: Active / Slow Moving / Dead Stock |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | `SKU_Count by stock_health_status GROUP BY product_category_name` |
| | Stacks: Active (🟢), Slow Moving (🟡), Dead Stock (🔴) |
| | Dual view: SKU Count vs Capital Value |
| | 🟧 Toggle – SKU Count vs Capital Value |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Location |

---

### ROW 5: Aging Analysis & Turnover

| Cell | Spec |
|------|------|
| **Days Since Last Sale / Receipt** | Table with Conditional Formatting |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | Columns: Product, Days Since Sale, Days Since Receipt, Qty, Value, Health Status |
| | 🔴 > 365 days (Dead) / 🟡 180–365 days (Slow) / 🟢 < 180 days (Active) |
| | Sorted by days_since_last_sale DESC |
| | 🟧 Toggle – Top Aging / All |
| | 🟥 Filter – Product Category |
| | 🟥 Filter – Stock Health Status |

| Cell | Spec |
|------|------|
| **Inventory Turnover by Category & Trend** | Bar (Turnover Ratio) + Line (Trend) |
| | Timeframe: Trailing 12 Months |
| | Measurement Range: Monthly |
| | Source: fct_transaction + fct_inventory_daily_snapshot + dim_product |
| | `COGS_Proxy = SUM(actual_cost) WHERE movement_type = 'Outflow'` |
| | `Avg_Inventory = AVG(quantity_on_hand × standard_cost)` over period |
| | `Turnover_Ratio = COGS_Proxy / Avg_Inventory` |
| | `Days_Inventory_Outstanding = 365 / Turnover_Ratio` |
| | 🟧 Toggle – Category vs Subcategory |
| | 🟥 Filter – Stock Health Status |

---

### ROW 6: Fulfillment Readiness & Stockout Risk

| Cell | Spec |
|------|------|
| **Stockout Risk Summary** | KPI Cards + Alert Table |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | `At_Reorder = COUNT(quantity <= reorder_point)` |
| | `At_Safety = COUNT(quantity <= safety_stock_level)` |
| | `Zero_Stock = COUNT(quantity = 0)` |
| | `Stockout_Risk_%  = At_Reorder / Total_SKUs * 100` |
| | Alert Table: Products at/below reorder point, sorted by gap |
| | 🔴 Below Safety / 🟡 Below Reorder / 🟢 Above Reorder |

| Cell | Spec |
|------|------|
| **Fulfillment Readiness by Category** | Horizontal Stacked Bar |
| | Timeframe: Current Snapshot |
| | Source: fct_inventory + dim_product |
| | `Ready = COUNT(stock_level_status IN ('Mid', 'High'))` per category |
| | `At_Risk = COUNT(stock_level_status = 'Low')` per category |
| | `Readiness_% = Ready / Total * 100` per category |
| | Stacks: Ready (🟢), At Risk (🔴) |
| | 🟧 Toggle – Product Category |
| | 🟥 Filter – Location |

| Cell | Spec |
|------|------|
| **Stock Coverage Days by Category** | Bar Chart |
| | Timeframe: Current Snapshot + Trailing 12 Month Sales |
| | Source: fct_inventory + fct_transaction + dim_product |
| | `Avg_Daily_Sales = SUM(abs_quantity WHERE transaction_type = 'S') / 365` per product |
| | `Coverage_Days = SUM(quantity) / Avg_Daily_Sales` per category |
| | Reference Line: 30-day minimum coverage |
| | 🔴 < 15 days / 🟡 15–30 days / 🟢 > 30 days |
| | 🟧 Toggle – Category vs Subcategory |
| | 🟥 Filter – Stock Health Status |

---

## VERSION 3: WIREFRAME

### **Default Timeframe/Granularity: Current Snapshot + Daily Trend**

```
                                                          ┌──────────────────────────┐
  "Hover-over" capability required to                     │  Snapshot Date (or Range) │
  highlight individual data points & detail               │  Product Category        │
  (e.g., SKU-level stock vs safety threshold)             │  Stock Health Status     │
                                                          │  Stock Level Status      │
  Align Dashboard permissions with existing               │  Location (Work Center)  │
  reporting (some users can't see cost/value)             └──────────────────────────┘

  Legend:
  🟧 Filters for "Crawl"
  🟥 Filters for "Walk/Run"

┌─────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Total Inventory Value     │  │  Stock Level Distribution & Capital by Category  │  Filter       │
│  │ & Safety Stock Coverage   │  │                                                  │               │
│  │                           │  │   ██ Low   ██ Mid   ██ High                      │  🟧 Toggle -  │
│  │  $8.4M        $5.2M      │  │                                                  │  Product Cat  │
│  │  List Value   Cost Value  │  │  ┌──────────────────────────────────┐             │               │
│  │                           │  │  │ Bikes     ████████████████████  │             │  🟥 Filter -  │
│  │  238 SKUs     1.8x       │  │  │ Comp.     ██████████████        │             │  Location     │
│  │  Total        Avg Safety  │  │  │ Cloth.    ██████████            │             │               │
│  │               Coverage    │  │  │ Access.   ██████                │             │  🟥 Filter -  │
│  │                           │  │  └──────────────────────────────────┘             │  Stock Health │
│  │  42 SKUs below safety ⚠️  │  │  Category   Capital    Low   Mid   High          │               │
│  │                           │  │  Bikes      $2.8M      8%   62%   30%           │               │
│  └───────────────────────────┘  │  Comp.      $1.5M     12%   68%   20%           │               │
│                                  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Items Below Safety Stock  │  │  Excess Inventory Value by Product Category      │  Filter       │
│  │ & Reorder Point           │  │                                                  │               │
│  │                           │  │  Bikes      ████████████████████  $420K  (52%)   │  🟧 Toggle -  │
│  │  Product     Qty  Safety  │  │  Comp.      ████████████          $240K  (30%)   │  Cat / SubCat │
│  │              Gap   Value  │  │  Cloth.     ██████                $105K  (13%)   │               │
│  │  HL Road     12   -38 🔴 │  │  Access.    ███                    $42K   (5%)   │  🟥 Filter -  │
│  │  ML Mtn      25   -15 🟡 │  │                                                  │  Location     │
│  │  HL Tour     18    -8 🟡 │  │  Total Excess Capital: $807K (15.5% of total)    │               │
│  │  Touring P   45    +5 🟢 │  │                                                  │               │
│  │  ...                     │  │                                                  │               │
│  │                          │  │                                                  │               │
│  │  🔴 Below Safety+Reorder │  │                                                  │               │
│  │  🟡 Below Safety only    │  │                                                  │               │
│  │  🟢 Above both           │  │                                                  │               │
│  │                          │  │                                                  │               │
│  │  🟧 Toggle - Safety/All  │  │                                                  │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Stock Level Status        │  │  Qty vs Safety Stock        │  │ Inventory Value Trend          │ │
│  │ Summary                   │  │  (Scatter by SKU)           │  │ (Daily Snapshot)               │ │
│  │                           │  │                              │  │                                │ │
│  │  🔴 Low:   42 SKUs (18%) │  │  Qty                         │  │  ── Inventory Value ($)        │ │
│  │  🟡 Mid:  148 SKUs (62%) │  │  500│ 🟢        🟢           │  │                                │ │
│  │  🟢 High:  48 SKUs (20%) │  │     │    🟡  🟡              │  │  $6M ┌──────────────────────┐ │ │
│  │                           │  │  300│  🟡  🟡   🟢          │  │      │  ──────────────────  │ │ │
│  │  Avg Qty/SKU: 164        │  │     │ 🔴 🔴                  │  │  $5M │──────              ─ │ │ │
│  │                           │  │  100│──────────── y=x        │  │      │       ──────────    │ │ │
│  │                           │  │     └───────────────────>    │  │  $4M └──────────────────────┘ │ │
│  │                           │  │     100   300   500          │  │      J  F  M  A  M  J  J  A  │ │
│  │                           │  │     Safety Stock Level       │  │                                │ │
│  │                           │  │  🟧 Toggle - Prod Category   │  │  🟧 Drop-Down - Prod Cat      │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌──────────────────────────────────────────────────┐  Drop-Down    │
│  │ Dead Stock & Slow Moving  │  │  Stock Health Breakdown by Category              │  Filter       │
│  │                           │  │                                                  │               │
│  │  18 SKUs      $285K      │  │   ██ Active  ██ Slow Moving  ██ Dead Stock       │  🟧 Toggle -  │
│  │  Dead Stock   Dead Value  │  │                                                  │  Count / $    │
│  │                           │  │  ┌──────────────────────────────────┐             │               │
│  │  35 SKUs      $520K      │  │  │ Bikes     ██████████████ ███ ██  │             │  🟧 Toggle -  │
│  │  Slow Moving  Slow Value  │  │  │ Comp.     ████████████ ██  █    │             │  Product Cat  │
│  │                           │  │  │ Cloth.    ██████████ ██         │             │               │
│  │  $805K                    │  │  │ Access.   ████████ ██ █         │             │  🟥 Filter -  │
│  │  Total At-Risk Capital    │  │  └──────────────────────────────────┘             │  Location     │
│  │  (15.5% of inv. value)   │  │                                                  │               │
│  │                           │  │  Category  Active  Slow   Dead   At-Risk $       │               │
│  │  185 SKUs     78%        │  │  Bikes     85%     10%    5%     $380K           │               │
│  │  Active       of Total   │  │  Comp.     80%     14%    6%     $210K           │               │
│  └───────────────────────────┘  └──────────────────────────────────────────────────┘               │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Days Since Last Sale / Receipt (Aging Table)                                               │   │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────────┐    │   │
│  │  │ Product          │ Days Since │ Days Since  │  Qty  │  Value  │ Health Status       │    │   │
│  │  │                  │ Last Sale  │ Last Receipt│       │         │                     │    │   │
│  │  ├─────────────────────────────────────────────────────────────────────────────────────┤    │   │
│  │  │ HL Road Frame    │ 542d  🔴   │  380d       │   12  │  $4.8K  │ Dead Stock          │    │   │
│  │  │ ML Mountain      │ 410d  🔴   │  320d       │   25  │  $8.2K  │ Dead Stock          │    │   │
│  │  │ HL Touring Fr.   │ 220d  🟡   │  180d       │   18  │  $5.1K  │ Slow Moving         │    │   │
│  │  │ Road Tire Tube   │  45d  🟢   │   30d       │  150  │  $1.2K  │ Active              │    │   │
│  │  │ ...              │            │             │       │         │                     │    │   │
│  │  └─────────────────────────────────────────────────────────────────────────────────────┘    │   │
│  │  🔴 > 365d (Dead)   🟡 180–365d (Slow)   🟢 < 180d (Active)                               │   │
│  │  🟧 Toggle - Top Aging / All                                                               │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │  Inventory Turnover by Category & Trend                                                     │   │
│  │  ┌────────────────────────────────────────────────────────────────────────────────────┐     │   │
│  │  │   ██ Turnover Ratio    ── DIO (Days Inv. Outstanding)    ── Prior Year             │     │   │
│  │  │  12x ┌──────────────────────────────────────────────────────────────┐  120d        │     │   │
│  │  │      │ ████                                                        │              │     │   │
│  │  │   8x │ ████  ████                                                  │   90d        │     │   │
│  │  │      │ ████  ████  ████                                            │              │     │   │
│  │  │   4x │ ████  ████  ████  ████                                      │   60d        │     │   │
│  │  │      │ Bikes  Comp  Cloth Access   ●───●───●───●───●               │              │     │   │
│  │  │   0  └──────────────────────────────────────────────────────────────┘   30d        │     │   │
│  │  └────────────────────────────────────────────────────────────────────────────────────┘     │   │
│  │  🟧 Toggle – Category / Subcategory                                                        │   │
│  │  🟥 Filter – Stock Health Status                                                            │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                     │
│  ┌───────────────────────────┐  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ Stockout Risk Summary     │  │  Fulfillment Readiness      │  │ Stock Coverage Days            │ │
│  │                           │  │  by Category                │  │ by Category                    │ │
│  │  42 SKUs      18%        │  │                              │  │                                │ │
│  │  At Reorder   of Total   │  │   ██ Ready  ██ At Risk       │  │  ── Coverage (days)            │ │
│  │                           │  │                              │  │  ── 30d minimum                │ │
│  │  28 SKUs      12%        │  │  Bikes    ████████████ ██   │  │                                │ │
│  │  At Safety    of Total   │  │  Comp.    ██████████ ████   │  │  Bikes     ████████████ 62d    │ │
│  │                           │  │  Cloth.   ████████████████  │  │  Comp.     ██████████   48d    │ │
│  │  5 SKUs       2%         │  │  Access.  ████████ ████████ │  │  Cloth.    ██████        32d    │ │
│  │  Zero Stock   of Total   │  │                              │  │  Access.   ████      🟡  22d   │ │
│  │                           │  │  Bikes     92% Ready        │  │  ...                           │ │
│  │  ⚠️ Top Risk:             │  │  Comp.     78% Ready        │  │                                │ │
│  │  HL Road, ML Mtn         │  │  Cloth.    95% Ready        │  │  🔴 < 15d  🟡 15-30d  🟢 > 30d│ │
│  │  (below safety stock)    │  │  Access.   65% Ready        │  │                                │ │
│  │                           │  │                              │  │  🟧 Toggle - Cat / SubCat     │ │
│  │  🔴 Below Safety          │  │  🟧 Toggle - Prod Category  │  │  🟥 Filter - Health Status    │ │
│  │  🟡 Below Reorder         │  │  🟥 Filter - Location       │  │                                │ │
│  │  🟢 Above Reorder         │  │                              │  │                                │ │
│  └───────────────────────────┘  └────────────────────────────┘  └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Data Model Mapping

### **Primary Tables**
| Table | Role |
|-------|------|
| `fct_inventory` | Fact – grain: product × location. Current stock snapshot with health/level classification |
| `fct_inventory_daily_snapshot` | Fact – grain: product × date. Historical daily stock on hand |
| `fct_transaction` | Fact – grain: transaction. In/outflow quantities for turnover calculation |
| `dim_product` | Product name, category, subcategory, standard_cost, list_price, safety_stock_level, reorder_point |
| `dim_workcenter` | Location name (used as warehouse/storage location) |
| `dim_date` | Date dimension (for snapshot trending) |

### **Key Fields**
| Domain | Fields |
|--------|--------|
| Stock Qty | `quantity` (fct_inventory), `quantity_on_hand` (snapshot) |
| Value | `total_manufacture_value` (qty × standard_cost), `total_actual_value` (qty × list_price) |
| Thresholds | `safety_stock_level`, `reorder_point` (from dim_product via stg_inventory) |
| Health | `stock_health_status` (Dead Stock / Slow Moving / Active) |
| Level | `stock_level_status` (Low / Mid / High) |
| Aging | `days_since_last_sale`, `days_since_last_receipt`, `last_sale_date`, `last_receipt_date` |
| Transactions | `net_quantity`, `actual_cost`, `movement_type` (Inflow / Outflow), `transaction_type` (P/W/S) |
| Snapshot | `daily_change`, `quantity_on_hand` |
| Location | `shelf`, `bin`, `location_name` (dim_workcenter) |

### **Key Calculations**
```sql
-- Safety Stock Coverage
Safety_Coverage = quantity / NULLIF(safety_stock_level, 0)
Items_Below_Safety = COUNT(CASE WHEN quantity <= safety_stock_level THEN 1 END)
Items_Below_Reorder = COUNT(CASE WHEN quantity <= reorder_point THEN 1 END)

-- Capital Tied Up
Total_Cost_Value = SUM(quantity * standard_cost)
Excess_Qty = CASE WHEN quantity > safety_stock_level * 3 THEN quantity - safety_stock_level * 3 ELSE 0 END
Excess_Value = Excess_Qty * standard_cost
At_Risk_Capital = SUM(total_manufacture_value) WHERE stock_health_status IN ('Dead Stock', 'Slow Moving')

-- Stock Health (pre-calculated in fct_inventory)
Dead Stock:   days_since_last_sale > 365
Slow Moving:  days_since_last_sale > 180 AND <= 365
Active:       days_since_last_sale <= 180

-- Stock Level (pre-calculated in fct_inventory)
Low:   quantity <= safety_stock_level
Mid:   quantity > safety_stock_level AND < safety_stock_level * 3
High:  quantity >= safety_stock_level * 3

-- Inventory Turnover
COGS_Proxy = SUM(actual_cost) WHERE movement_type = 'Outflow'  -- from fct_transaction
Avg_Inventory = AVG(quantity_on_hand * standard_cost)           -- from fct_inventory_daily_snapshot
Turnover_Ratio = COGS_Proxy / NULLIF(Avg_Inventory, 0)
Days_Inventory_Outstanding = 365 / NULLIF(Turnover_Ratio, 0)

-- Fulfillment Readiness
Ready_SKUs = COUNT(CASE WHEN stock_level_status IN ('Mid', 'High') THEN 1 END)
At_Risk_SKUs = COUNT(CASE WHEN stock_level_status = 'Low' THEN 1 END)
Readiness_% = Ready_SKUs / Total_SKUs * 100

-- Stock Coverage Days
Avg_Daily_Outflow = SUM(abs_quantity WHERE transaction_type = 'S') / 365  -- per product
Coverage_Days = SUM(quantity) / NULLIF(Avg_Daily_Outflow, 0)

-- Conditional Formatting
Health:   🔴 Dead Stock (>365d)  |  🟡 Slow Moving (180-365d)  |  🟢 Active (<180d)
Level:    🔴 Low (≤ safety)      |  🟡 Mid                      |  🟢 High (≥ 3× safety)
Coverage: 🔴 < 15 days           |  🟡 15-30 days               |  🟢 > 30 days
```
