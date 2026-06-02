# Financial KPI Executive Dashboard

## Project Overview
Finance teams spend hours every month manually pulling numbers from different systems to answer the same executive questions: How are we tracking against budget? Which departments are over or under? What is our growth trend? This project automates that entire process into a single CFO-level Power BI dashboard — built entirely from SQL-transformed data.

## Business Problem
A multi-department organization needed a **single source of truth** for financial performance — replacing manual Excel reporting with an always-current, decision-ready executive dashboard.

## Dataset
- Simulated multi-department financial dataset covering revenue, expenses, headcount, and budget allocations
- 5 departments: Sales, Operations, Marketing, Finance, HR
- 24 months of transaction-level data

## Methodology

### Step 1 — Data Modeling (SQL)
Wrote 15+ SQL queries to transform raw transactional data into clean KPI tables:
- Revenue by department and month
- Operating expenses vs. budget
- Net margin by business unit
- Headcount efficiency ratios
- YoY and MoM variance calculations

### Step 2 — DAX Measures (Power BI)
Built 8 dynamic DAX measures:
- Rolling 3-month average revenue
- Month-over-Month growth %
- Year-over-Year variance %
- Budget vs. actuals gap
- Department contribution margin
- Cumulative YTD revenue
- Expense ratio by department
- Headcount cost per unit of revenue

### Step 3 — Dashboard Design (Power BI)
Designed with one principle: **every visual answers a specific business question.** No decorative charts.

Dashboard pages:
1. **Executive Summary** — top-line KPIs at a glance
2. **Revenue Analysis** — trends, YoY, MoM by department
3. **Budget vs. Actuals** — variance flags by department and quarter
4. **Department Drill-down** — individual department performance detail

## Key Metrics Tracked
- $2M+ in total simulated revenue across 5 departments
- YoY growth rate and variance from forecast
- Budget adherence by department (% over/under)
- Top and bottom performing business units by margin

## Business Impact
- Replaced manual monthly reporting process
- CFO-level visibility into performance in under 30 seconds
- Drill-down capability eliminates back-and-forth data requests

## Tools & Technologies
- **SQL** — data transformation and KPI table creation
- **Power BI** — dashboard design and visualization
- **DAX** — dynamic measure calculations

## Files
```
financial-kpi-dashboard/
├── sql/                # All 15+ SQL transformation queries
├── dashboard/          # Power BI .pbix file
├── data/               # Simulated dataset (CSV)
├── screenshots/        # Dashboard screenshots
└── README.md
```

## How to Run
1. Clone the repository
2. Run SQL scripts in `/sql` against the dataset in `/data`
3. Open `/dashboard/kpi_dashboard.pbix` in Power BI Desktop
4. Refresh data source to point to your local dataset path
