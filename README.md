# Financial KPI Executive Dashboard

**CFO-level Power BI dashboard tracking $25M+ revenue across 5 departments.**  
Built with SQL, DAX, and Power BI. Every visual answers a specific business question.

---

## Dashboard

![Financial KPI Dashboard](dashboard_screenshot.png)

---

## Results at a Glance

| KPI | Value | Insight |
|---|---|---|
| Total Revenue | $25M | Sales drives majority of company revenue |
| Total Expenses | $18M | Overall cost structure healthy |
| Net Margin | 26.20% | Company profitable — Marketing is the outlier |
| Budget Variance | -$284K | Slight underperformance driven by Marketing overspend |

**Key finding:** Marketing is the only department with negative net margin (-40%). Sales is outperforming budget. Immediate action recommended on Marketing spend.

---

## Dashboard Visuals

| Visual | Type | Business Question Answered |
|---|---|---|
| KPI Cards (4) | Card | What are the top-line numbers right now? |
| Revenue by Department | Horizontal Bar | Which department drives the most revenue? |
| Budget vs Actuals | Clustered Column | Who is over or under budget? |
| Revenue Trend by Month | Line Chart | What is the revenue trajectory over time? |
| Net Margin % by Department | Column Chart | Which departments are profitable? |

---

## DAX Measures

```dax
Total Revenue = SUM(financial_data[Revenue])

Total Expenses = SUM(financial_data[Expenses])

Budget Variance = SUM(financial_data[Revenue]) - SUM(financial_data[Budget])

Net Margin % = DIVIDE(
    SUM(financial_data[Revenue]) - SUM(financial_data[Expenses]),
    SUM(financial_data[Revenue]), 0) * 100
```

---

## SQL Queries — All 16

Full file: [`kpi_queries.sql`](kpi_queries.sql)

1. Revenue by department and month with company share %
2. Annual revenue summary by department
3. Expenses vs budget variance with Over/Under status label
4. YoY growth % using LAG window function
5. MoM growth % using LAG window function
6. Net margin % with margin band classification (Healthy/Moderate/Thin/Negative)
7. Headcount efficiency — revenue, cost, and profit per employee
8. Top 3 departments by profit margin (ranked)
9. Bottom 3 departments by budget overspend (ranked)
10. Rolling 3-month average revenue
11. Rolling 3-month average net margin
12. Cumulative YTD revenue vs YTD target gap
13. Revenue vs target attainment with status labels (Exceeded/Met/Near Miss/Missed)
14. Expense ratio trend with rolling average
15. Company-wide monthly executive snapshot
16. Department contribution % to total company revenue

---

## Files

| File | Description |
|---|---|
| [`financial_kpi_dashboard.pbix`](financial_kpi_dashboard.pbix) | Power BI file — open in Power BI Desktop |
| [`financial_data.csv`](financial_data.csv) | Dataset — 24 months x 5 departments (120 rows) |
| [`kpi_queries.sql`](kpi_queries.sql) | All 16 SQL transformation and analytics queries |
| [`dashboard_build_guide.md`](dashboard_build_guide.md) | Step by step build instructions with DAX formulas |
| [`dashboard_screenshot.png`](dashboard_screenshot.png) | Dashboard preview |

---

## How to Open

1. Download [`financial_kpi_dashboard.pbix`](financial_kpi_dashboard.pbix)
2. Open in **Power BI Desktop** — free from [microsoft.com/power-bi](https://powerbi.microsoft.com/desktop)
3. If data does not load: click **Transform data** and update the CSV path to your local location
4. All visuals and DAX measures render automatically

---

**Tools:** `Power BI` `DAX` `SQL` `Window Functions` `Financial Modeling`

*[Haroon Haque Chishti](https://github.com/haroonhaquechishti) — Business & Data Analyst Portfolio*
