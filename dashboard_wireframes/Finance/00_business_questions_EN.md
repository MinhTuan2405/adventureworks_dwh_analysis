# Finance Dashboard — Business Questions (English)

> **Date**: 2026-03-01  
> **Dataset**: Enterprise DWH (DuckDB + dbt + S3/Parquet)

---

## FINANCE FUNNEL — 7 DASHBOARDS × 3 QUESTIONS = 21 BUSINESS QUESTIONS

---

### 1️⃣ Financial Overview

> Executive-level P&L snapshot — Revenue, COGS, Gross Profit, key operational charges, prior-period benchmarks.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the overall financial performance (Revenue, COGS, Gross Profit, and key operational charges including manufacturing cost, freight, and tax) compared to prior-period benchmarks? | ⚠️ Adjusted — no SGA/budget tables; use prior-period comparison |
| Q2 | What are the key financial KPIs (Gross Margin %, AOV, Revenue per Unit, Cost-to-Revenue Ratio) trending over time, and are there any concerning inflection points? | ✅ Fully feasible |
| Q3 | How does the financial performance split between Internet and Reseller channels at a high level? | ✅ Fully feasible |

---

### 2️⃣ Revenue Deep Dive & Growth

> Revenue trend analysis — growth rates, channel mix, discount impact, seasonality patterns.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the revenue trend over time (MoM, QoQ, YoY), and which periods show the strongest/weakest growth? | ✅ Fully feasible |
| Q2 | How is the revenue mix shifting between Internet and Reseller channels, and what is the discount impact on each channel's net revenue? | ✅ Fully feasible |
| Q3 | What are the revenue seasonality patterns, and which months/quarters consistently over- or under-perform? | ✅ Fully feasible |

---

### 3️⃣ Cost Structure & Control

> Enterprise cost breakdown — COGS, manufacturing, freight, tax, scrap loss. Cost variance and cost creep detection.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the total cost breakdown by major cost components (COGS, manufacturing, freight, tax, scrap loss), and how is each component trending over time? | ✅ Fully feasible |
| Q2 | Where are the largest cost variances occurring — which products, work centers, or vendors are driving costs above expected levels? | ✅ Fully feasible |
| Q3 | What is the cost-to-revenue ratio trend, and are production-related costs (COGS, manufacturing, freight) growing faster than revenue? | ⚠️ Adjusted — only production-related costs available, no full OpEx |

---

### 4️⃣ Profitability Analysis & Margin

> Gross margin analysis — margin trends, category ranking, discount-margin relationship, margin erosion detection.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the gross margin trend across time periods, and which quarters show margin compression or expansion? | ✅ Fully feasible |
| Q2 | Which product categories and subcategories are margin leaders vs. margin laggards, and how has this ranking changed over time? | ✅ Fully feasible |
| Q3 | How do discounts and pricing strategies affect margin by channel, and is there evidence of margin erosion from excessive discounting? | ✅ Fully feasible |

---

### 5️⃣ Territory & Channel Financial Performance

> Territory-level P&L — revenue, profit, margin by geography and channel. Growth momentum analysis.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | Which territories and territory groups generate the highest revenue, profit, and margin — and how do they rank against each other? | ✅ Fully feasible |
| Q2 | How does the Internet vs Reseller channel mix differ across territories, and which channel is more profitable in each region? | ✅ Fully feasible |
| Q3 | Which territories show the strongest revenue growth momentum, and which are declining — signaling expansion or consolidation opportunities? | ✅ Fully feasible |

---

### 6️⃣ Procurement Financial Analysis

> Procurement spend analysis — spend trends, vendor concentration, volume-price correlation, rejection cost impact.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the total procurement spend trend, and how does it correlate with revenue growth — are we spending proportionally to growth? | ✅ Fully feasible |
| Q2 | How concentrated is our procurement spend across vendors, and are we getting better pricing from high-volume vendors? | ✅ Fully feasible |
| Q3 | What is the financial impact of rejected materials — how much spend is wasted on defective receipts, and which vendors are responsible? | ✅ Fully feasible |

---

### 7️⃣ Product Portfolio Financial Analysis

> Product-level financial performance — revenue/profit contribution, pricing gap analysis, margin correction identification.

| # | Business Question | Feasibility |
|---|---|---|
| Q1 | What is the revenue and profit contribution of each product category — which categories are "cash cows" vs "question marks"? | ✅ Fully feasible |
| Q2 | How does product pricing (list price vs actual selling price) vary across categories, and where is the largest price gap? | ✅ Fully feasible |
| Q3 | Which individual products have the highest margin and revenue, and which high-revenue products have dangerously low margins that need pricing correction? | ✅ Fully feasible |

---

## SUMMARY

| Dashboard | Status | Key Note |
|---|---|---|
| 1️⃣ Financial Overview | ⚠️ Mostly OK | No full OpEx (SGA, payroll); no budget/target — use prior-period |
| 2️⃣ Revenue Deep Dive & Growth | ✅ Perfect | — |
| 3️⃣ Cost Structure & Control | ⚠️ Minor gap | Only production-related costs, no full OpEx |
| 4️⃣ Profitability & Margin | ✅ Perfect | — |
| 5️⃣ Territory & Channel Finance | ✅ Perfect | — |
| 6️⃣ Procurement Finance | ✅ Perfect | — |
| 7️⃣ Product Portfolio Finance | ✅ Perfect | — |

**Result: 5/7 fully feasible, 2/7 need minor wording adjustments (no structural changes needed).**
