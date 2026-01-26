# Power BI Visualization

## Mục tiêu Business Intelligence

### Primary Objectives
1. **Sales Performance Monitoring** - Theo dõi hiệu suất bán hàng real-time
2. **Customer Insights** - Phân tích hành vi và phân khúc khách hàng
3. **Product Analytics** - Đánh giá hiệu quả sản phẩm và inventory
4. **Territory Management** - Tối ưu hóa phân bổ vùng bán hàng
5. **Promotion Effectiveness** - Đo lường ROI của các chương trình khuyến mãi
6. **Salesperson Performance** - Quản lý và đánh giá đội ngũ sales

---

## KPIs & Metrics Definitions

> All of the suggestions below are for reference only and may not be 100% accurate.

### 1. Sales Performance Metrics

| Metric | Formula (DAX) | Business Purpose |
|--------|--------------|------------------|
| **Total Sales** | `SUM(fact_sales[total_due])` | Tổng doanh thu bao gồm tax & freight |
| **Gross Revenue** | `SUM(fact_sales[sub_total])` | Doanh thu trước thuế và phí vận chuyển |
| **Total Orders** | `DISTINCTCOUNT(fact_sales[sales_order_id])` | Số lượng đơn hàng |
| **Average Order Value (AOV)** | `DIVIDE([Total Sales], [Total Orders], 0)` | Giá trị trung bình mỗi đơn |
| **Total Quantity** | `SUM(fact_sales[order_qty])` | Tổng số lượng sản phẩm bán ra |
| **Total Tax** | `SUM(fact_sales[tax_amt])` | Tổng thuế thu được |
| **Total Freight** | `SUM(fact_sales[freight])` | Chi phí vận chuyển |
| **Total Discount** | `SUMX(fact_sales, fact_sales[order_qty] * fact_sales[unit_price_discount])` | Tổng giá trị giảm giá |

**DAX Implementation:**
```dax
// Total Sales Revenue
Total Sales = SUM(fact_sales[total_due])

// Total Orders
Total Orders = DISTINCTCOUNT(fact_sales[sales_order_id])

// Average Order Value
AOV = DIVIDE([Total Sales], [Total Orders], 0)

// Total Quantity Sold
Total Quantity = SUM(fact_sales[order_qty])

// Gross Revenue
Gross Revenue = SUM(fact_sales[sub_total])

// Tax Amount
Total Tax = SUM(fact_sales[tax_amt])

// Freight Cost
Total Freight = SUM(fact_sales[freight])

// Discount Amount
Total Discount = 
SUMX(
    fact_sales, 
    fact_sales[order_qty] * fact_sales[unit_price_discount]
)

// Net Revenue (after discount, before tax)
Net Revenue = [Gross Revenue] - [Total Discount]

// Profit Margin Estimate
Estimated Margin % = 
DIVIDE(
    [Gross Revenue] - SUM(fact_sales[order_qty] * RELATED(dim_product[standard_cost])),
    [Gross Revenue],
    0
)
```

### 2. Time Intelligence Metrics

**DAX Implementation:**
```dax
// Sales Year-to-Date
Sales YTD = 
TOTALYTD(
    [Total Sales],
    dim_date[full_date]
)

// Sales Previous Year
Sales PY = 
CALCULATE(
    [Total Sales],
    SAMEPERIODLASTYEAR(dim_date[full_date])
)

// Year-over-Year Growth
YoY Growth % = 
DIVIDE(
    [Total Sales] - [Sales PY],
    [Sales PY],
    0
)

// Year-over-Year Growth Amount
YoY Growth Amount = [Total Sales] - [Sales PY]

// Month-over-Month Growth
MoM Growth % = 
VAR CurrentMonth = [Total Sales]
VAR PreviousMonth = 
    CALCULATE(
        [Total Sales],
        DATEADD(dim_date[full_date], -1, MONTH)
    )
RETURN
    DIVIDE(CurrentMonth - PreviousMonth, PreviousMonth, 0)

// Sales Quarter-to-Date
Sales QTD = 
TOTALQTD(
    [Total Sales],
    dim_date[full_date]
)

// Sales Month-to-Date
Sales MTD = 
TOTALMTD(
    [Total Sales],
    dim_date[full_date]
)

// Rolling 12 Months Sales
Sales R12M = 
CALCULATE(
    [Total Sales],
    DATESINPERIOD(
        dim_date[full_date],
        LASTDATE(dim_date[full_date]),
        -12,
        MONTH
    )
)

// Same Period Last Year MTD
Sales PY MTD = 
CALCULATE(
    [Sales MTD],
    SAMEPERIODLASTYEAR(dim_date[full_date])
)
```

### 3. Product Metrics

**DAX Implementation:**
```dax
// Total Products Sold
Products Sold = DISTINCTCOUNT(fact_sales[product_id])

// Average Unit Price
Avg Unit Price = AVERAGE(fact_sales[unit_price])

// Revenue per Product
Revenue per Product = DIVIDE([Total Sales], [Products Sold], 0)

// Product Revenue Rank
Product Rank = 
RANKX(
    ALL(dim_product[product_name]),
    [Total Sales],
    ,
    DESC,
    DENSE
)

// Top 10 Products Revenue
Top 10 Products = 
CALCULATE(
    [Total Sales],
    TOPN(10, ALL(dim_product[product_name]), [Total Sales], DESC)
)

// Product Contribution %
Product Contribution % = 
DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], ALL(dim_product)),
    0
)

// Average Discount per Product
Avg Discount % = 
DIVIDE(
    SUM(fact_sales[unit_price_discount]),
    AVERAGE(fact_sales[unit_price]),
    0
)

// Product Velocity (Units per Day)
Product Velocity = 
DIVIDE(
    [Total Quantity],
    DISTINCTCOUNT(fact_sales[order_date]),
    0
)

// Stock Days (simulated - if had inventory data)
// Stock Days = DIVIDE([Current Inventory], [Product Velocity], 0)
```

### 4. Customer Metrics

**DAX Implementation:**
```dax
// Total Customers
Total Customers = DISTINCTCOUNT(fact_sales[customer_id])

// Revenue per Customer
Revenue per Customer = DIVIDE([Total Sales], [Total Customers], 0)

// New Customers (First-time buyers in period)
New Customers = 
CALCULATE(
    DISTINCTCOUNT(fact_sales[customer_id]),
    FILTER(
        ALL(dim_date),
        dim_date[full_date] >= 
            CALCULATE(
                MIN(fact_sales[order_date]),
                ALL(dim_date)
            )
    )
)

// Returning Customers
Returning Customers = 
VAR FirstPurchase = 
    ADDCOLUMNS(
        SUMMARIZE(fact_sales, fact_sales[customer_id]),
        "FirstDate", 
        CALCULATE(MIN(fact_sales[order_date]))
    )
RETURN
    COUNTROWS(
        FILTER(
            FirstPurchase,
            [FirstDate] < MIN(dim_date[full_date])
        )
    )

// Customer Lifetime Value (simplified)
Customer LTV = 
AVERAGEX(
    VALUES(fact_sales[customer_id]),
    CALCULATE([Total Sales])
)

// Average Orders per Customer
Avg Orders per Customer = 
DIVIDE([Total Orders], [Total Customers], 0)

// Customer Retention Rate
Retention Rate % = 
DIVIDE([Returning Customers], [Total Customers], 0)

// Customer Type Split
Store Sales = 
CALCULATE(
    [Total Sales],
    NOT(ISBLANK(dim_customer[store_id]))
)

Individual Sales = 
CALCULATE(
    [Total Sales],
    ISBLANK(dim_customer[store_id])
)
```

### 5. Territory & Geography Metrics

**DAX Implementation:**
```dax
// Sales by Territory
Territory Sales = 
CALCULATE(
    [Total Sales],
    USERELATIONSHIP(fact_sales[territory_id], dim_terriory[business_key_territory_id])
)

// Territory Contribution %
Territory Contribution % = 
DIVIDE(
    [Total Sales],
    CALCULATE([Total Sales], ALL(dim_terriory)),
    0
)

// Territory Growth YoY
Territory YoY Growth % = 
VAR CurrentYear = [Territory Sales]
VAR PreviousYear = 
    CALCULATE(
        [Territory Sales],
        SAMEPERIODLASTYEAR(dim_date[full_date])
    )
RETURN
    DIVIDE(CurrentYear - PreviousYear, PreviousYear, 0)

// Territory YTD vs Target
Territory vs Target = 
DIVIDE(
    SUM(dim_terriory[sales_ytd]),
    SUM(dim_terriory[sales_last_year]) * 1.1, // Assuming 10% growth target
    0
)

// Territory Cost Efficiency
Territory Cost Ratio = 
DIVIDE(
    SUM(dim_terriory[cost_ytd]),
    SUM(dim_terriory[sales_ytd]),
    0
)
```

### 6. Salesperson Metrics

**DAX Implementation:**
```dax
// Total Commission
Total Commission = 
SUMX(
    dim_salesperson,
    [Total Sales] * dim_salesperson[commission_pct]
)

// Quota Achievement %
Quota Achievement % = 
DIVIDE(
    SUM(dim_salesperson[sales_ytd]),
    SUM(dim_salesperson[sales_quota]),
    0
)

// Average Deal Size per Salesperson
Avg Deal Size = 
AVERAGEX(
    VALUES(dim_salesperson[sales_person_name]),
    CALCULATE([AOV])
)

// Salesperson Rank
Salesperson Rank = 
RANKX(
    ALL(dim_salesperson[sales_person_name]),
    [Total Sales],
    ,
    DESC,
    DENSE
)

// Commission per Sale
Commission Rate = 
DIVIDE([Total Commission], [Total Sales], 0)

// Salesperson Efficiency (Sales per Commission)
Sales Efficiency = 
DIVIDE([Total Sales], [Total Commission], 0)

// Bonus Eligibility (Exceeds quota by 10%)
Bonus Eligible = 
IF([Quota Achievement %] >= 1.1, "Yes", "No")
```

### 7. Promotion Metrics

**DAX Implementation:**
```dax
// Sales with Promotion
Sales with Promotion = 
CALCULATE(
    [Total Sales],
    fact_sales[special_offer_id] > 1 // 1 = No Discount
)

// Sales without Promotion
Sales without Promotion = 
CALCULATE(
    [Total Sales],
    fact_sales[special_offer_id] = 1
)

// Promotion Impact
Promotion Impact = [Sales with Promotion] - [Sales without Promotion]

// Promotion ROI
Promotion ROI % = 
DIVIDE(
    [Sales with Promotion],
    [Total Discount],
    0
) - 1

// Average Discount %
Avg Promotion Discount = 
AVERAGE(dim_promotion[discount_pct])

// Orders with Promotion %
Promotion Adoption % = 
DIVIDE(
    CALCULATE([Total Orders], fact_sales[special_offer_id] > 1),
    [Total Orders],
    0
)

// Promotion Revenue per Customer
Promotion Revenue per Customer = 
DIVIDE([Sales with Promotion], [Total Customers], 0)
```

---

## Dashboard Requirements

### Dashboard 1: Executive Summary
#### Layout Structure
```
┌─────────────────────────────────────────────────┐
│  EXECUTIVE DASHBOARD - AdventureWorks          │
├──────────┬──────────┬──────────┬───────────────┤
│ Total    │ Total    │ AOV      │ YoY Growth    │
│ Sales    │ Orders   │          │               │
│ $XXX M   │ XX,XXX   │ $X,XXX   │ +XX%          │
├──────────┴──────────┴──────────┴───────────────┤
│                                                 │
│  Sales Trend (Line Chart - Monthly)            │
│  - Current Year vs Previous Year                │
│  - With forecast trend line                     │
│                                                 │
├────────────────────────┬────────────────────────┤
│  Sales by Territory    │  Top 10 Products      │
│  (Clustered Column)    │  (Bar Chart)          │
│                        │                        │
├────────────────────────┼────────────────────────┤
│  Revenue Breakdown     │  Quota Achievement    │
│  (Donut Chart)         │  (Gauge Chart)        │
│  - By Product Line     │  - Salesperson avg    │
└────────────────────────┴────────────────────────┘
```

#### Visualizations

| # | Visual Type | Data | Purpose | Interactivity |
|---|------------|------|---------|---------------|
| 1 | **KPI Cards (4)** | Total Sales, Total Orders, AOV, YoY Growth % | Quick metrics overview | Click to drill to details |
| 2 | **Line Chart** | Sales by Month (Current vs Previous Year) | Trend analysis | Hover for values, drill to day |
| 3 | **Clustered Column** | Sales by Territory | Geographic comparison | Click to filter dashboard |
| 4 | **Donut Chart** | Revenue by Product Line | Category contribution | Slice selection filters |
| 5 | **Bar Chart** | Top 10 Products by Revenue | Best performers | Drill-through to product page |
| 6 | **Gauge Chart** | Quota Achievement % | Target tracking | Color coding: Red<90%, Yellow 90-100%, Green>100% |

#### Filters & Slicers
- Date Range (Calendar)
- Year (Dropdown)
- Territory (Multi-select)
- Product Line (Multi-select)

---

### Dashboard 2: Sales Deep Dive

#### Visualizations

| # | Visual Type | Data | Purpose |
|---|------------|------|---------|
| 1 | **Matrix Table** | Sales by Year > Quarter > Month > Week | Hierarchical drill-down |
| 2 | **Waterfall Chart** | Sales Composition (Gross → Discount → Net → Tax → Freight → Total) | Revenue breakdown |
| 3 | **Area Chart** | Sales YTD vs Sales PY YTD | YTD comparison |
| 4 | **Treemap** | Sales by Product Line > Class | Hierarchical view |
| 5 | **Scatter Plot** | Unit Price (X) vs Quantity (Y), Size = Revenue | Price-volume analysis |
| 6 | **Ribbon Chart** | Top 10 Products Ranking over Time | Ranking changes |
| 7 | **Line + Column** | Revenue (Column) & Order Count (Line) by Month | Volume vs Value |
| 8 | **Decomposition Tree** | Sales breakdown by multiple dimensions | Root cause analysis |

#### Advanced Features
- **Drill-through:** Click any product → Product Detail Page
- **Bookmarks:** Saved views for different scenarios
- **What-if Parameters:** Price sensitivity analysis
- **Dynamic Titles:** Show selected filter context

---

### Dashboard 3: Customer Intelligence

#### Visualizations

| # | Visual Type | Data | Purpose |
|---|------------|------|---------|
| 1 | **KPI Cards (5)** | Total Customers, New Customers, Revenue per Customer, Retention %, LTV | Customer health metrics |
| 2 | **Bar Chart** | Top 20 Customers by Revenue | VIP customer identification |
| 3 | **Funnel Chart** | Customer Segmentation by Revenue Tier | Distribution analysis |
| 4 | **Clustered Column** | Store vs Individual Customer Sales | Channel comparison |
| 5 | **Map Visual** | Sales by Territory (Geographic) | Location-based insights |
| 6 | **Line Chart** | New vs Returning Customers Trend | Acquisition vs Retention |
| 7 | **Matrix** | Customer Cohort Analysis | Retention over time |
| 8 | **Scatter Plot** | Customer Frequency (X) vs Recency (Y) | RFM analysis |

#### Customer Segmentation DAX
```dax
Customer Segment = 
VAR CustomerRevenue = [Revenue per Customer]
RETURN
    SWITCH(
        TRUE(),
        CustomerRevenue >= 10000, "Platinum",
        CustomerRevenue >= 5000, "Gold",
        CustomerRevenue >= 2000, "Silver",
        "Bronze"
    )

// RFM Score
Recency Score = 
VAR LastPurchase = MAX(fact_sales[order_date])
VAR DaysSince = DATEDIFF(LastPurchase, TODAY(), DAY)
RETURN
    SWITCH(
        TRUE(),
        DaysSince <= 30, 5,
        DaysSince <= 60, 4,
        DaysSince <= 90, 3,
        DaysSince <= 180, 2,
        1
    )

Frequency Score = 
VAR OrderCount = [Total Orders]
RETURN
    SWITCH(
        TRUE(),
        OrderCount >= 20, 5,
        OrderCount >= 10, 4,
        OrderCount >= 5, 3,
        OrderCount >= 2, 2,
        1
    )

Monetary Score = 
VAR Revenue = [Total Sales]
RETURN
    SWITCH(
        TRUE(),
        Revenue >= 50000, 5,
        Revenue >= 20000, 4,
        Revenue >= 10000, 3,
        Revenue >= 5000, 2,
        1
    )

RFM Score = [Recency Score] & [Frequency Score] & [Monetary Score]
```

---

### Dashboard 4: Product Performance

#### Visualizations

| # | Visual Type | Data | Purpose |
|---|------------|------|---------|
| 1 | **Bar Chart** | Top 20 Products by Revenue | Best sellers |
| 2 | **Bar Chart** | Bottom 20 Products by Revenue | Slow movers |
| 3 | **Line Chart** | Product Sales Trend (Top 5 Products) | Trend comparison |
| 4 | **Clustered Column** | Sales by Color, Size, Product Line | Attribute analysis |
| 5 | **Matrix Heatmap** | Product Cross-sell Analysis | Basket analysis |
| 6 | **Scatter Plot** | List Price vs Standard Cost (Margin analysis) | Profitability |
| 7 | **Table** | Product Detail with Sparklines | Comprehensive view |
| 8 | **Slicer Panel** | Product filters (Category, Color, Size, Price Range) | Interactive filtering |

#### Product Analysis DAX
```dax
// Product Margin %
Product Margin % = 
DIVIDE(
    AVERAGE(dim_product[list_price]) - AVERAGE(dim_product[standard_cost]),
    AVERAGE(dim_product[list_price]),
    0
)

// Inventory Turnover (simulated)
Product Turnover = 
DIVIDE(
    [Total Quantity],
    DATEDIFF(MIN(fact_sales[order_date]), MAX(fact_sales[order_date]), DAY),
    0
)

// ABC Classification
Product ABC Class = 
VAR CumulativeRevenue = 
    CALCULATE(
        [Total Sales],
        FILTER(
            ALL(dim_product),
            [Total Sales] >= EARLIER([Total Sales])
        )
    )
VAR TotalRevenue = CALCULATE([Total Sales], ALL(dim_product))
VAR CumulativePct = DIVIDE(CumulativeRevenue, TotalRevenue, 0)
RETURN
    SWITCH(
        TRUE(),
        CumulativePct <= 0.8, "A - High Value",
        CumulativePct <= 0.95, "B - Medium Value",
        "C - Low Value"
    )

// Days Since Last Sale
Days Since Last Sale = 
DATEDIFF(
    MAX(fact_sales[order_date]),
    TODAY(),
    DAY
)

// Active Product Flag
Is Active = 
IF(
    ISBLANK(dim_product[discontinued_date]) && 
    [Days Since Last Sale] <= 90,
    "Active",
    "Inactive"
)
```

---

### Dashboard 5: Territory & Salesperson Performance

#### Visualizations

| # | Visual Type | Data | Purpose |
|---|------------|------|---------|
| 1 | **Map Visual** | Sales by Territory (Filled Map) | Geographic performance |
| 2 | **Bar Chart** | Top 10 Salespeople by Revenue | Leaderboard |
| 3 | **Bullet Chart** | Quota vs Actual (by Salesperson) | Target achievement |
| 4 | **Scatter Plot** | Commission % (X) vs Sales YTD (Y) | Efficiency analysis |
| 5 | **Clustered Column** | Sales by Territory & Quarter | Trend by region |
| 6 | **Matrix** | Salesperson Performance (Sales, Orders, AOV, Quota %) | Detailed metrics |
| 7 | **Line Chart** | Territory Cost vs Revenue Trend | Profitability |
| 8 | **Card Visuals** | Commission, Bonus, Quota Achievement | Summary metrics |

#### Salesperson Analysis DAX
```dax
// Performance Rating
Performance Rating = 
VAR QuotaAchieve = [Quota Achievement %]
RETURN
    SWITCH(
        TRUE(),
        QuotaAchieve >= 1.2, "⭐⭐⭐⭐⭐ Exceptional",
        QuotaAchieve >= 1.1, "⭐⭐⭐⭐ Excellent",
        QuotaAchieve >= 1.0, "⭐⭐⭐ Good",
        QuotaAchieve >= 0.9, "⭐⭐ Fair",
        "⭐ Needs Improvement"
    )

// Bonus Calculation
Bonus Amount = 
VAR QuotaExcess = [Total Sales] - SUM(dim_salesperson[sales_quota])
RETURN
    IF(
        QuotaExcess > 0,
        QuotaExcess * 0.05, // 5% bonus on excess
        0
    )

// Territory Rank
Territory Rank = 
RANKX(
    ALL(dim_terriory[territory_name]),
    [Territory Sales],
    ,
    DESC,
    DENSE
)

// Sales per Day (Productivity)
Sales per Day = 
DIVIDE(
    [Total Sales],
    DISTINCTCOUNT(fact_sales[order_date]),
    0
)
```

---

### Dashboard 6: Promotion Analytics

#### Visualizations

| # | Visual Type | Data | Purpose |
|---|------------|------|---------|
| 1 | **KPI Cards (3)** | Total Discount, Sales with Promotion, ROI % | Impact summary |
| 2 | **Stacked Bar** | Sales by Promotion Type | Contribution view |
| 3 | **Line Chart** | Promotion Impact over Time | Trend analysis |
| 4 | **Waterfall** | Sales: No Promo → With Promo → Net Impact | Incremental sales |
| 5 | **Matrix** | Promotion Detail (Name, Discount %, Revenue, ROI) | Detailed metrics |
| 6 | **Column Chart** | Promotion Adoption % by Product Category | Uptake analysis |
| 7 | **Scatter Plot** | Discount % (X) vs Revenue Lift (Y) | Optimization |

---

## Design Standards

### Color Palette
```
Primary Colors:
- Sales/Revenue: #0078D4 (Blue)
- Profit/Margin: #107C10 (Green)
- Cost/Discount: #D13438 (Red)
- Target/Goal: #FFB900 (Amber)

Secondary Colors:
- Territory 1: #8764B8 (Purple)
- Territory 2: #00B7C3 (Cyan)
- Territory 3: #CA5010 (Orange)

Conditional Formatting:
- Positive: #107C10 (Green)
- Negative: #D13438 (Red)
- Neutral: #605E5C (Gray)
- Warning: #FFB900 (Yellow)
```

### Typography
- **Titles:** Segoe UI, Bold, 16pt
- **Subtitles:** Segoe UI, Semibold, 12pt
- **Body:** Segoe UI, Regular, 10pt
- **KPI Numbers:** Segoe UI, Bold, 24pt

### Formatting Rules
- **Currency:** $#,##0 (no decimals for large numbers)
- **Percentages:** 0.0% (one decimal)
- **Large Numbers:** 1.2M, 345.6K (abbreviated)
- **Dates:** DD MMM YYYY (21 Jan 2026)

---
