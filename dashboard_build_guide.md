# Financial KPI Executive Dashboard — Power BI Build Guide

## Overview

This guide walks you through building a production-ready executive dashboard from `financial_data.csv`. Follow the steps in order: data import → data model → DAX measures → visuals → formatting.

**End result:** A 6-visual, single-page executive dashboard surfacing revenue trends, budget adherence, margin health, headcount efficiency, and target attainment across 5 departments over 24 months.

---

## Part 1 — Import the Data

### Step 1: Load the CSV

1. Open Power BI Desktop. Click **Home → Get Data → Text/CSV**.
2. Navigate to `financial_data.csv` and click **Open**.
3. In the preview dialog, confirm the delimiter is **Comma** and the first row is used as headers.
4. Click **Transform Data** (do not click Load yet — you need to clean the date first).

### Step 2: Add a Date Column in Power Query

In the Power Query Editor:

1. Click **Add Column → Custom Column**.
2. Name it `Date` and enter this formula:
   ```
   Date.FromText([Month] & " " & Text.From([Year]))
   ```
3. Right-click the `Date` column → **Change Type → Date**.
4. Click **Home → Close & Apply**.

### Step 3: Create a Calculated Column for Month Number

In the **Data** view, select the table and add a new column:

```dax
Month Number = 
SWITCH([Month],
    "Jan", 1, "Feb", 2, "Mar", 3, "Apr", 4,
    "May", 5, "Jun", 6, "Jul", 7, "Aug", 8,
    "Sep", 9, "Oct", 10, "Nov", 11, "Dec", 12
)
```

This enables correct chronological sorting on the Month axis in all visuals.

### Step 4: Sort Month Column

1. In the **Data** view, select the `Month` column.
2. On the **Column Tools** ribbon, click **Sort by Column → Month Number**.

---

## Part 2 — Create a Date Table (Best Practice)

In the **Modeling** tab → **New Table**:

```dax
DateTable = 
CALENDAR(DATE(2024,1,1), DATE(2025,12,31))
```

Then add columns to the date table:

```dax
Year = YEAR(DateTable[Date])
Month Name = FORMAT(DateTable[Date], "MMM")
Month Number = MONTH(DateTable[Date])
Quarter = "Q" & QUARTER(DateTable[Date])
Year-Month = FORMAT(DateTable[Date], "YYYY-MMM")
```

**Create a relationship:** Link `DateTable[Date]` → `financial_data[Date]` (many-to-one, single direction).

---

## Part 3 — DAX Measures

Create a dedicated **Measures** table: **Modeling → New Table**, name it `_Measures`, body = `_Measures = {""}`). All measures below go into this table.

---

### Measure 1: Total Revenue

```dax
Total Revenue = SUM(financial_data[Revenue])
```

**Answers:** What is the raw top-line across any slicer selection?

---

### Measure 2: YTD Revenue

```dax
YTD Revenue = 
CALCULATE(
    [Total Revenue],
    DATESYTD(DateTable[Date])
)
```

**Answers:** How much revenue has the company (or a department) accumulated since January 1 of the current year in context?

---

### Measure 3: MoM Revenue Growth %

```dax
MoM Revenue Growth % = 
VAR CurrentRevenue = [Total Revenue]
VAR PreviousRevenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD(DateTable[Date], -1, MONTH)
    )
RETURN
    IF(
        PreviousRevenue <> 0,
        DIVIDE(CurrentRevenue - PreviousRevenue, PreviousRevenue),
        BLANK()
    )
```

**Answers:** Is growth accelerating or decelerating month over month?

---

### Measure 4: YoY Revenue Variance

```dax
YoY Revenue Variance = 
VAR CurrentRevenue = [Total Revenue]
VAR PriorYearRevenue = 
    CALCULATE(
        [Total Revenue],
        DATEADD(DateTable[Date], -1, YEAR)
    )
RETURN
    IF(
        PriorYearRevenue <> 0,
        DIVIDE(CurrentRevenue - PriorYearRevenue, PriorYearRevenue),
        BLANK()
    )
```

**Answers:** How does this year's performance compare to the same period last year?

---

### Measure 5: Rolling 3-Month Average Revenue

```dax
Rolling 3M Avg Revenue = 
AVERAGEX(
    DATESINPERIOD(
        DateTable[Date],
        LASTDATE(DateTable[Date]),
        -3,
        MONTH
    ),
    [Total Revenue]
)
```

**Answers:** What is the smoothed revenue trend, stripping out single-month volatility?

---

### Measure 6: Budget vs Actuals Gap

```dax
Budget vs Actuals Gap = 
VAR TotalExpenses = SUM(financial_data[Expenses])
VAR TotalBudget = SUM(financial_data[Budget])
RETURN TotalBudget - TotalExpenses
```

> Positive = under budget (favorable). Negative = over budget (unfavorable).

**Answers:** Are departments spending within their approved budgets?

---

### Measure 7: Net Margin %

```dax
Net Margin % = 
DIVIDE(
    SUM(financial_data[Revenue]) - SUM(financial_data[Expenses]),
    SUM(financial_data[Revenue])
)
```

Format this measure as **Percentage** with 1 decimal place.

**Answers:** How much of each revenue dollar is kept as profit?

---

### Measure 8: Expense Ratio

```dax
Expense Ratio = 
DIVIDE(
    SUM(financial_data[Expenses]),
    SUM(financial_data[Revenue])
)
```

Format as **Percentage** with 1 decimal place. A lower value is better.

**Answers:** What fraction of revenue is consumed by expenses — and is it trending up or down?

---

### Measure 9: Headcount Cost (Cost per Employee)

```dax
Headcount Cost = 
DIVIDE(
    SUM(financial_data[Expenses]),
    SUM(financial_data[Headcount])
)
```

Format as **Currency** with 0 decimals.

**Answers:** How much does the company spend per employee? Which departments are most cost-efficient?

---

### Measure 10: Revenue per Head

```dax
Revenue per Head = 
DIVIDE(
    SUM(financial_data[Revenue]),
    SUM(financial_data[Headcount])
)
```

Format as **Currency** with 0 decimals.

**Answers:** Which departments generate the most revenue per employee? Where should headcount grow?

---

### Measure 11: Target Attainment %

```dax
Target Attainment % = 
DIVIDE(
    SUM(financial_data[Revenue]),
    SUM(financial_data[Target])
)
```

Format as **Percentage** with 1 decimal place.

**Answers:** Is each department hitting its revenue targets?

---

### Measure 12: Contribution Margin %

```dax
Contribution Margin % = 
VAR DeptRevenue = SUM(financial_data[Revenue])
VAR TotalRevenue = 
    CALCULATE(
        SUM(financial_data[Revenue]),
        ALL(financial_data[Department])
    )
RETURN DIVIDE(DeptRevenue, TotalRevenue)
```

Format as **Percentage** with 1 decimal place.

**Answers:** What share of total company revenue does each department contribute?

---

## Part 4 — Build the 6 Visuals

Set the canvas size to **1280 × 720** (16:9): **View → Page view → Actual size**, then in **Format page → Canvas settings** set Width=1280, Height=720.

Add a **Department** slicer and a **Year** slicer at the top of the page so all visuals respond to the same filter context.

---

### Visual 1: Revenue Trend Line Chart

**Purpose:** Show company-wide and per-department revenue trajectory over 24 months.

| Field well | Value |
|---|---|
| Visual type | **Line chart** |
| X-axis | `DateTable[Year-Month]` |
| Y-axis | `[Total Revenue]` |
| Legend | `financial_data[Department]` |
| Secondary Y-axis | `[Rolling 3M Avg Revenue]` (as a dashed line) |
| Tooltips | `[MoM Revenue Growth %]`, `[YoY Revenue Variance]` |

**Formatting tips:**
- Sort X-axis by `DateTable[Month Number]` ascending.
- Enable **Data labels** on the last data point only.
- Set the secondary line style to **dashed** and color to **gray**.

**Executive insight:** *Is revenue growing consistently, or are there seasonal dips? The rolling average cuts through noise to reveal the true trend.*

---

### Visual 2: Budget vs Actuals Clustered Bar Chart

**Purpose:** Reveal which departments are over or under budget each month.

| Field well | Value |
|---|---|
| Visual type | **Clustered bar chart** |
| Y-axis | `financial_data[Department]` |
| X-axis (Value 1) | `SUM(financial_data[Expenses])` — label: "Actual Expenses" |
| X-axis (Value 2) | `SUM(financial_data[Budget])` — label: "Budget" |
| Tooltips | `[Budget vs Actuals Gap]`, `[Expense Ratio]` |

**Conditional formatting:** Add a **KPI indicator** or bar color rule — color bars red when Expenses > Budget, green when under.

**Executive insight:** *Which departments are disciplined stewards of their budget, and which consistently overspend? The gap measure surfaces both magnitude and direction.*

---

### Visual 3: Net Margin % Waterfall or Column Chart

**Purpose:** Compare profitability across departments at a glance.

| Field well | Value |
|---|---|
| Visual type | **Clustered column chart** |
| X-axis | `financial_data[Department]` |
| Y-axis | `[Net Margin %]` |
| Small multiples | `DateTable[Year]` |
| Tooltips | `[Total Revenue]`, `SUM(financial_data[Expenses])`, `[Expense Ratio]` |

**Conditional formatting on columns:** Apply a color scale (red → yellow → green) based on `[Net Margin %]` value.

**Add a constant line** at 20% to mark the company profitability target.

**Executive insight:** *Which departments are operating at healthy margins versus eroding company profitability? Are margins improving year over year?*

---

### Visual 4: YoY Growth % Heat Map (Matrix)

**Purpose:** Give executives a 2D view of growth performance — department by month.

| Field well | Value |
|---|---|
| Visual type | **Matrix** |
| Rows | `financial_data[Department]` |
| Columns | `DateTable[Month Name]` (sorted by Month Number) |
| Values | `[YoY Revenue Variance]` |

**Conditional formatting on Values:** Apply a **Background color** diverging scale — red for negative growth, white at 0%, green for positive growth.

**Executive insight:** *In which months does each department grow faster or slower than the prior year? Patterns reveal seasonality and momentum shifts.*

---

### Visual 5: Headcount Efficiency Scatter Plot

**Purpose:** Plot departments by revenue-per-head vs cost-per-head to identify efficiency quadrants.

| Field well | Value |
|---|---|
| Visual type | **Scatter chart** |
| X-axis | `[Revenue per Head]` |
| Y-axis | `[Headcount Cost]` |
| Legend / Details | `financial_data[Department]` |
| Size | `SUM(financial_data[Headcount])` |
| Play axis | `DateTable[Year-Month]` (enables animation over time) |
| Tooltips | `[Net Margin %]`, `[Target Attainment %]` |

**Add reference lines:** Draw a vertical line at the average Revenue per Head and a horizontal line at average Cost per Head. This creates four quadrants: High-Efficiency, High-Cost, Low-Efficiency, Lean.

**Executive insight:** *Which departments produce the most revenue per employee at the lowest cost? Where does adding headcount have the greatest ROI?*

---

### Visual 6: Target Attainment KPI Cards + Gauge

**Purpose:** Give executives an instant pass/fail summary of how each department tracks against revenue targets.

**Section A — KPI Cards (one per department, arranged in a row):**

| Field well | Value |
|---|---|
| Visual type | **KPI** card (5× — one per department) |
| Value | `[Total Revenue]` |
| Target | `SUM(financial_data[Target])` |
| Trend axis | `DateTable[Date]` |

Apply a **Department** filter to each card individually (right-click visual → Edit filters → add Department = "Sales" etc.).

**Section B — Company-Wide Gauge:**

| Field well | Value |
|---|---|
| Visual type | **Gauge** |
| Value | `[Total Revenue]` |
| Target | `SUM(financial_data[Target])` |
| Maximum | Set to 110% of total annual target |

**Executive insight:** *At a glance — are we on track to hit our numbers? Which departments are lagging and need intervention before quarter-end?*

---

## Part 5 — Slicers and Interactivity

Add these slicers to the top of the page:

| Slicer | Field | Style |
|---|---|---|
| Year | `DateTable[Year]` | Dropdown |
| Department | `financial_data[Department]` | Tile (multi-select) |
| Month range | `DateTable[Date]` | Between (date range picker) |

**Sync slicers:** Go to **View → Sync slicers** and enable sync across all visuals so any filter applies everywhere.

**Cross-filter behavior:** Set all visuals to **Cross-highlight** (not cross-filter) so clicking one department dim-highlights the others rather than hiding them — this preserves the executive context.

---

## Part 6 — Formatting Checklist

- [ ] Set theme: **View → Themes → Executive** or import a custom JSON theme matching your brand colors.
- [ ] Title bar: Add a text box at the top — "Financial KPI Executive Dashboard | FY 2024–2025".
- [ ] Add a **Last Refreshed** card: `NOW()` formatted as date-time to show data freshness.
- [ ] Set all currency measures to display in **$K** (divide by 1000 in the measure and append "K" using FORMAT).
- [ ] Enable **tooltips** on all visuals with the key measures for drill-through context.
- [ ] Add **bookmarks** for two views: "Full Company" (no department filter) and "Department Drilldown" (one department selected).
- [ ] Set **mobile layout** (View → Mobile layout) by stacking the KPI cards vertically on top of the trend chart.

---

## Quick Reference — Measure to Visual Mapping

| DAX Measure | Visuals that use it |
|---|---|
| Total Revenue | All visuals |
| YTD Revenue | KPI cards (as secondary value) |
| MoM Revenue Growth % | Line chart tooltip, Matrix |
| YoY Revenue Variance | Line chart tooltip, Heat Map Matrix |
| Rolling 3M Avg Revenue | Line chart (secondary axis) |
| Budget vs Actuals Gap | Bar chart tooltip |
| Net Margin % | Column chart, Scatter tooltip |
| Expense Ratio | Bar chart tooltip, Column chart tooltip |
| Headcount Cost | Scatter chart (Y-axis) |
| Revenue per Head | Scatter chart (X-axis) |
| Target Attainment % | KPI cards, Gauge, Scatter tooltip |
| Contribution Margin % | Column chart tooltip |
