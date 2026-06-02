# Financial KPI Executive Dashboard

**CFO-level Power BI dashboard tracking $25M+ revenue across 5 departments.**  
Built with SQL, DAX, and Power BI. Every visual answers a specific business question.

---

## Dashboard

![Financial KPI Dashboard](dashboard_screenshot.png)

---

## What This Shows

| KPI | Value | Insight |
|---|---|---|
| Total Revenue | $25M | Sales drives majority of company revenue |
| Total Expenses | $18M | Overall cost structure healthy |
| Net Margin | 26.20% | Company profitable — Marketing is the outlier |
| Budget Variance | -$284K | Slight underperformance driven by Marketing overspend |

**Key finding:** Marketing is the only department with negative net margin (-40%). Sales is outperforming budget. Immediate action recommended on Marketing spend.

---

## Visuals

| Visual | Business Question Answered |
|---|---|
| Revenue by Department | Which department drives the most revenue? |
| Budget vs Actuals | Who is over or under budget? |
| Revenue Trend by Month | What is the revenue trajectory over time? |
| Net Margin % by Department | Which departments are profitable? |
| KPI Cards (4) | What are the top-line numbers right now? |

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

## SQL — 16 Queries

Full queries in [`kpi_queries.sql`](kpi_queries.sql)

Key queries include:
- Revenue by department and month with company share %
- Expenses vs budget variance with Over/Under status label
- YoY growth % and MoM growth % using LAG window functions
- Net margin % with margin band classification (Healthy/Moderate/Thin/Negative)
- Headcount efficiency — revenue, cost, and profit per employee
- Rolling 3-month average revenue
- Cumulative YTD revenue vs target gap

---

## Files

| File | Description |
|---|---|
| [`financial_kpi_dashboard.pbix`](financial_kpi_dashboard.pbix) | Power BI file — open in Power BI Desktop |
| [`financial_data.csv`](financial_data.csv) | Dataset — 24 months x 5 departments |
| [`kpi_queries.sql`](kpi_queries.sql) | All 16 SQL queries |
| [`dashboard_build_guide.md`](dashboard_build_guide.md) | Step by step build instructions |
| [`dashboard_screenshot.png`](dashboard_screenshot.png) | Dashboard image |

---

## How to Open

1. Download [`financial_kpi_dashboard.pbix`](financial_kpi_dashboard.pbix)
2. Open in **Power BI Desktop** — free from [microsoft.com/power-bi](https://powerbi.microsoft.com/desktop)
3. If data does not load: click **Transform data** and update the CSV file path
4. All visuals and DAX measures render automatically

**Tools:** `Power BI` `DAX` `SQL` `Window Functions`

---

*[Haroon Haque Chishti](https://github.com/haroonhaquechishti) — Business & Data Analyst Portfolio*
