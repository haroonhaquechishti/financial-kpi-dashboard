-- ============================================================
-- Financial KPI Executive Dashboard — SQL Query Library
-- Compatible with: PostgreSQL, SQL Server, DuckDB, SQLite*
-- * SQLite requires LAG/LEAD polyfills for window functions
-- ============================================================

-- SETUP: load the CSV as a table before running queries
-- DuckDB:     CREATE TABLE financial_data AS SELECT * FROM read_csv_auto('financial_data.csv');
-- SQL Server: BULK INSERT or import via SSMS / Power Query
-- PostgreSQL: \copy financial_data FROM 'financial_data.csv' DELIMITER ',' CSV HEADER;


-- ============================================================
-- 1. REVENUE BY DEPARTMENT AND MONTH (chronological)
-- ============================================================
SELECT
    Year,
    Month,
    Department,
    Revenue,
    SUM(Revenue) OVER (PARTITION BY Year, Month) AS total_company_revenue,
    ROUND(Revenue * 100.0 / SUM(Revenue) OVER (PARTITION BY Year, Month), 2) AS revenue_share_pct
FROM financial_data
ORDER BY Year,
    CASE Month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END,
    Department;


-- ============================================================
-- 2. ANNUAL REVENUE SUMMARY BY DEPARTMENT
-- ============================================================
SELECT
    Year,
    Department,
    SUM(Revenue)   AS annual_revenue,
    SUM(Expenses)  AS annual_expenses,
    SUM(Budget)    AS annual_budget,
    SUM(Revenue) - SUM(Expenses) AS annual_profit
FROM financial_data
GROUP BY Year, Department
ORDER BY Year, annual_revenue DESC;


-- ============================================================
-- 3. EXPENSES VS BUDGET VARIANCE BY DEPARTMENT AND MONTH
-- ============================================================
SELECT
    Year,
    Month,
    Department,
    Expenses,
    Budget,
    Expenses - Budget                                          AS variance_abs,
    ROUND((Expenses - Budget) * 100.0 / Budget, 2)            AS variance_pct,
    CASE WHEN Expenses > Budget THEN 'Over Budget'
         WHEN Expenses < Budget THEN 'Under Budget'
         ELSE 'On Budget' END                                  AS budget_status
FROM financial_data
ORDER BY Year,
    CASE Month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END,
    Department;


-- ============================================================
-- 4. YEAR-OVER-YEAR (YoY) REVENUE GROWTH BY DEPARTMENT
-- ============================================================
WITH monthly_revenue AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        LAG(Revenue) OVER (
            PARTITION BY Department, Month
            ORDER BY Year
        ) AS prior_year_revenue
    FROM financial_data
)
SELECT
    Year,
    Month,
    Department,
    Revenue                                                                AS current_revenue,
    prior_year_revenue,
    Revenue - prior_year_revenue                                           AS yoy_revenue_change,
    ROUND((Revenue - prior_year_revenue) * 100.0 / prior_year_revenue, 2) AS yoy_growth_pct
FROM monthly_revenue
WHERE prior_year_revenue IS NOT NULL
ORDER BY Year, Department,
    CASE Month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END;


-- ============================================================
-- 5. MONTH-OVER-MONTH (MoM) REVENUE GROWTH BY DEPARTMENT
-- ============================================================
WITH ordered_data AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num
    FROM financial_data
),
with_lag AS (
    SELECT
        Year,
        Month,
        month_num,
        Department,
        Revenue,
        LAG(Revenue) OVER (
            PARTITION BY Department
            ORDER BY Year, month_num
        ) AS prev_month_revenue
    FROM ordered_data
)
SELECT
    Year,
    Month,
    Department,
    Revenue,
    prev_month_revenue,
    Revenue - prev_month_revenue                                               AS mom_revenue_change,
    ROUND((Revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2)     AS mom_growth_pct
FROM with_lag
WHERE prev_month_revenue IS NOT NULL
ORDER BY Year, month_num, Department;


-- ============================================================
-- 6. NET MARGIN BY DEPARTMENT AND MONTH
-- ============================================================
SELECT
    Year,
    Month,
    Department,
    Revenue,
    Expenses,
    Revenue - Expenses                                     AS net_profit,
    ROUND((Revenue - Expenses) * 100.0 / Revenue, 2)      AS net_margin_pct,
    CASE
        WHEN (Revenue - Expenses) * 100.0 / Revenue >= 30 THEN 'Healthy'
        WHEN (Revenue - Expenses) * 100.0 / Revenue >= 15 THEN 'Moderate'
        WHEN (Revenue - Expenses) * 100.0 / Revenue >= 0  THEN 'Thin'
        ELSE 'Negative'
    END AS margin_band
FROM financial_data
ORDER BY Year,
    CASE Month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END,
    net_margin_pct DESC;


-- ============================================================
-- 7. HEADCOUNT EFFICIENCY (REVENUE PER EMPLOYEE)
-- ============================================================
SELECT
    Year,
    Month,
    Department,
    Revenue,
    Headcount,
    ROUND(Revenue * 1.0 / Headcount, 0)                       AS revenue_per_head,
    ROUND(Expenses * 1.0 / Headcount, 0)                      AS cost_per_head,
    ROUND((Revenue - Expenses) * 1.0 / Headcount, 0)          AS profit_per_head
FROM financial_data
ORDER BY Year,
    CASE Month
        WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
        WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
        WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
        WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
    END,
    revenue_per_head DESC;


-- ============================================================
-- 8. TOP 3 PERFORMING DEPARTMENTS BY ANNUAL PROFIT MARGIN
-- ============================================================
WITH dept_annual AS (
    SELECT
        Year,
        Department,
        SUM(Revenue)  AS total_revenue,
        SUM(Expenses) AS total_expenses,
        SUM(Revenue) - SUM(Expenses) AS total_profit
    FROM financial_data
    GROUP BY Year, Department
),
ranked AS (
    SELECT
        *,
        ROUND(total_profit * 100.0 / total_revenue, 2) AS profit_margin_pct,
        RANK() OVER (PARTITION BY Year ORDER BY total_profit DESC) AS profit_rank
    FROM dept_annual
)
SELECT Year, Department, total_revenue, total_expenses, total_profit, profit_margin_pct, profit_rank
FROM ranked
WHERE profit_rank <= 3
ORDER BY Year, profit_rank;


-- ============================================================
-- 9. BOTTOM 3 PERFORMING DEPARTMENTS BY BUDGET ADHERENCE
-- ============================================================
WITH dept_variance AS (
    SELECT
        Year,
        Department,
        SUM(Expenses)                                              AS total_expenses,
        SUM(Budget)                                                AS total_budget,
        SUM(Expenses) - SUM(Budget)                                AS total_overspend,
        ROUND((SUM(Expenses) - SUM(Budget)) * 100.0 / SUM(Budget), 2) AS overspend_pct
    FROM financial_data
    GROUP BY Year, Department
),
ranked AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY Year ORDER BY overspend_pct DESC) AS overspend_rank
    FROM dept_variance
)
SELECT Year, Department, total_expenses, total_budget, total_overspend, overspend_pct, overspend_rank
FROM ranked
WHERE overspend_rank <= 3
ORDER BY Year, overspend_rank;


-- ============================================================
-- 10. ROLLING 3-MONTH AVERAGE REVENUE BY DEPARTMENT
-- ============================================================
WITH ordered_data AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num
    FROM financial_data
)
SELECT
    Year,
    Month,
    Department,
    Revenue,
    ROUND(AVG(Revenue) OVER (
        PARTITION BY Department
        ORDER BY Year, month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS rolling_3m_avg_revenue,
    ROUND(AVG(Expenses) OVER (
        PARTITION BY Department
        ORDER BY Year, month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS rolling_3m_avg_expenses
FROM ordered_data
ORDER BY Department, Year, month_num;


-- ============================================================
-- 11. ROLLING 3-MONTH AVERAGE NET MARGIN BY DEPARTMENT
-- ============================================================
WITH ordered_data AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        Expenses,
        ROUND((Revenue - Expenses) * 100.0 / Revenue, 2) AS net_margin_pct,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num
    FROM financial_data
)
SELECT
    Year,
    Month,
    Department,
    net_margin_pct,
    ROUND(AVG(net_margin_pct) OVER (
        PARTITION BY Department
        ORDER BY Year, month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3m_avg_margin
FROM ordered_data
ORDER BY Department, Year, month_num;


-- ============================================================
-- 12. CUMULATIVE YTD REVENUE BY DEPARTMENT
-- ============================================================
WITH ordered_data AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        Expenses,
        Target,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num
    FROM financial_data
)
SELECT
    Year,
    Month,
    Department,
    Revenue,
    SUM(Revenue) OVER (
        PARTITION BY Year, Department
        ORDER BY month_num
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_revenue,
    SUM(Target) OVER (
        PARTITION BY Year, Department
        ORDER BY month_num
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_target,
    SUM(Revenue) OVER (
        PARTITION BY Year, Department
        ORDER BY month_num
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) - SUM(Target) OVER (
        PARTITION BY Year, Department
        ORDER BY month_num
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS ytd_vs_target_gap
FROM ordered_data
ORDER BY Department, Year, month_num;


-- ============================================================
-- 13. REVENUE VS TARGET ATTAINMENT BY DEPARTMENT
-- ============================================================
SELECT
    Year,
    Department,
    SUM(Revenue)                                               AS actual_revenue,
    SUM(Target)                                                AS target_revenue,
    SUM(Revenue) - SUM(Target)                                 AS gap,
    ROUND(SUM(Revenue) * 100.0 / SUM(Target), 2)              AS attainment_pct,
    CASE
        WHEN SUM(Revenue) >= SUM(Target) * 1.05 THEN 'Exceeded'
        WHEN SUM(Revenue) >= SUM(Target)         THEN 'Met'
        WHEN SUM(Revenue) >= SUM(Target) * 0.95 THEN 'Near Miss'
        ELSE 'Missed'
    END AS attainment_status
FROM financial_data
GROUP BY Year, Department
ORDER BY Year, attainment_pct DESC;


-- ============================================================
-- 14. EXPENSE RATIO TREND (EXPENSES AS % OF REVENUE)
-- ============================================================
WITH ordered_data AS (
    SELECT
        Year,
        Month,
        Department,
        Revenue,
        Expenses,
        ROUND(Expenses * 100.0 / Revenue, 2) AS expense_ratio,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num
    FROM financial_data
)
SELECT
    Year,
    Month,
    Department,
    Revenue,
    Expenses,
    expense_ratio,
    AVG(expense_ratio) OVER (
        PARTITION BY Department
        ORDER BY Year, month_num
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3m_expense_ratio
FROM ordered_data
ORDER BY Department, Year, month_num;


-- ============================================================
-- 15. COMPANY-WIDE MONTHLY SNAPSHOT (EXECUTIVE SUMMARY)
-- ============================================================
WITH monthly_totals AS (
    SELECT
        Year,
        Month,
        CASE Month
            WHEN 'Jan' THEN 1  WHEN 'Feb' THEN 2  WHEN 'Mar' THEN 3
            WHEN 'Apr' THEN 4  WHEN 'May' THEN 5  WHEN 'Jun' THEN 6
            WHEN 'Jul' THEN 7  WHEN 'Aug' THEN 8  WHEN 'Sep' THEN 9
            WHEN 'Oct' THEN 10 WHEN 'Nov' THEN 11 WHEN 'Dec' THEN 12
        END AS month_num,
        SUM(Revenue)   AS total_revenue,
        SUM(Expenses)  AS total_expenses,
        SUM(Budget)    AS total_budget,
        SUM(Target)    AS total_target,
        SUM(Headcount) AS total_headcount
    FROM financial_data
    GROUP BY Year, Month
),
with_calcs AS (
    SELECT
        *,
        total_revenue - total_expenses                                    AS net_profit,
        ROUND((total_revenue - total_expenses) * 100.0 / total_revenue, 2) AS net_margin_pct,
        ROUND(total_expenses * 100.0 / total_budget, 2)                   AS budget_utilization_pct,
        ROUND(total_revenue * 100.0 / total_target, 2)                    AS target_attainment_pct,
        ROUND(total_revenue * 1.0 / total_headcount, 0)                   AS revenue_per_head,
        LAG(total_revenue) OVER (ORDER BY Year, month_num)                AS prev_month_revenue
    FROM monthly_totals
)
SELECT
    Year,
    Month,
    total_revenue,
    total_expenses,
    total_budget,
    total_target,
    total_headcount,
    net_profit,
    net_margin_pct,
    budget_utilization_pct,
    target_attainment_pct,
    revenue_per_head,
    ROUND((total_revenue - prev_month_revenue) * 100.0 / prev_month_revenue, 2) AS mom_growth_pct
FROM with_calcs
ORDER BY Year, month_num;


-- ============================================================
-- BONUS: DEPARTMENT CONTRIBUTION TO TOTAL COMPANY REVENUE (ANNUAL)
-- ============================================================
WITH dept_annual AS (
    SELECT
        Year,
        Department,
        SUM(Revenue) AS dept_revenue
    FROM financial_data
    GROUP BY Year, Department
),
company_annual AS (
    SELECT Year, SUM(Revenue) AS company_revenue
    FROM financial_data
    GROUP BY Year
)
SELECT
    d.Year,
    d.Department,
    d.dept_revenue,
    c.company_revenue,
    ROUND(d.dept_revenue * 100.0 / c.company_revenue, 2) AS revenue_contribution_pct,
    RANK() OVER (PARTITION BY d.Year ORDER BY d.dept_revenue DESC) AS contribution_rank
FROM dept_annual d
JOIN company_annual c ON d.Year = c.Year
ORDER BY d.Year, contribution_rank;
