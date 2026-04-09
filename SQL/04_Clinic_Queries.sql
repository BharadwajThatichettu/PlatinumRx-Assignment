-- 1. Revenue by sales channel for a given year

SELECT sales_channel, SUM(amount) AS total_revenue
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY sales_channel; [cite: 17, 27]

-- 2. Top 10 most valuable customers for a given year

SELECT uid, SUM(amount) AS total_spent
FROM clinic_sales
WHERE strftime('%Y', datetime) = '2021'
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10; [cite: 18, 27]

-- 3. Month-wise revenue, expense, profit, and status (2021)

WITH MonthlyRevenue AS (
    SELECT strftime('%m', datetime) AS month, SUM(amount) AS revenue
    FROM clinic_sales
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY month
),
MonthlyExpenses AS (
    SELECT strftime('%m', datetime) AS month, SUM(amount) AS expense
    FROM expenses
    WHERE strftime('%Y', datetime) = '2021'
    GROUP BY month
)
SELECT 
    r.month, 
    r.revenue, 
    IFNULL(e.expense, 0) AS expense,
    (r.revenue - IFNULL(e.expense, 0)) AS profit,
    CASE WHEN (r.revenue - IFNULL(e.expense, 0)) > 0 THEN 'profitable' ELSE 'not-profitable' END AS status
FROM MonthlyRevenue r
LEFT JOIN MonthlyExpenses e ON r.month = e.month; [cite: 19, 27, 29]

-- 4. For each city find the most profitable clinic for a given month

WITH ClinicProfit AS (
    SELECT 
        c.city, 
        c.clinic_name, 
        (SUM(s.amount) - (SELECT SUM(amount) FROM expenses e WHERE e.cid = c.cid AND strftime('%m', e.datetime) = '09')) AS net_profit,
        RANK() OVER(PARTITION BY c.city ORDER BY (SUM(s.amount) - (SELECT SUM(amount) FROM expenses e WHERE e.cid = c.cid AND strftime('%m', e.datetime) = '09')) DESC) as rnk
    FROM clinics c
    JOIN clinic_sales s ON c.cid = s.cid
    WHERE strftime('%m', s.datetime) = '09'
    GROUP BY c.cid
)
SELECT city, clinic_name, net_profit
FROM ClinicProfit
WHERE rnk = 1; [cite: 20, 23, 27]

-- 5. For each state find the second least profitable clinic for a given month

WITH StateProfit AS (
    SELECT 
        c.state, 
        c.clinic_name, 
        (SUM(s.amount) - (SELECT SUM(amount) FROM expenses e WHERE e.cid = c.cid AND strftime('%m', e.datetime) = '09')) AS net_profit,
        RANK() OVER(PARTITION BY c.state ORDER BY (SUM(s.amount) - (SELECT SUM(amount) FROM expenses e WHERE e.cid = c.cid AND strftime('%m', e.datetime) = '09')) ASC) as rnk
    FROM clinics c
    JOIN clinic_sales s ON c.cid = s.cid
    WHERE strftime('%m', s.datetime) = '09'
    GROUP BY c.cid
)
SELECT state, clinic_name, net_profit
FROM StateProfit
WHERE rnk = 2; [cite: 21, 23, 27]
