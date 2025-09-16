-- Question 9: Weekly, Weekly Total, Half-Weekly Total, and Ratio of Weekday to Weekend Sales
-- Question: Calculate the total SalesAmount for each day of the week, the total SalesAmount for the first half of the week, the total SalesAmount for the second half of the week, 
-- and the ratio of "weekday total" to "weekend total." (SalesAmount should be in millions).

-- Total SalesAmount for each day of the week
SELECT
    SUM(CASE WHEN d.DayOfWeek = 1 THEN s.SalesAmount ELSE 0 END) AS Sunday,
    SUM(CASE WHEN d.DayOfWeek = 2 THEN s.SalesAmount ELSE 0 END) AS Monday,
    SUM(CASE WHEN d.DayOfWeek = 3 THEN s.SalesAmount ELSE 0 END) AS Tuesday,
    SUM(CASE WHEN d.DayOfWeek = 4 THEN s.SalesAmount ELSE 0 END) AS Wednesday,
    SUM(CASE WHEN d.DayOfWeek = 5 THEN s.SalesAmount ELSE 0 END) AS Thursday,
    SUM(CASE WHEN d.DayOfWeek = 6 THEN s.SalesAmount ELSE 0 END) AS Friday,
    SUM(CASE WHEN d.DayOfWeek = 7 THEN s.SalesAmount ELSE 0 END) AS Saturday
FROM
    FactSales s
LEFT JOIN
    DimDate d ON s.DateKey = d.DateKey;

-- Total SalesAmount for the first half of the week (e.g., Monday-Wednesday)
SELECT
    SUM(s.SalesAmount) / 1000000 AS "First Half SalesAmount (Millions)"
FROM
    FactSales s
LEFT JOIN
    DimDate d ON s.DateKey = d.DateKey
WHERE
    d.DayOfWeek BETWEEN 2 AND 4; -- Adjust range as needed for "first half"

-- Total SalesAmount for the second half of the week (e.g., Thursday-Sunday)
SELECT
    SUM(s.SalesAmount) / 1000000 AS "Second Half SalesAmount (Millions)"
FROM
    FactSales s
LEFT JOIN
    DimDate d ON s.DateKey = d.DateKey
WHERE
    d.DayOfWeek BETWEEN 5 AND 7; -- Adjust range as needed for "second half"

-- Ratio of weekday total to weekend total
WITH WeekdaySales AS (
    SELECT SUM(s.SalesAmount) AS TotalWeekdaySales
    FROM FactSales s
    LEFT JOIN DimDate d ON s.DateKey = d.DateKey
    WHERE d.DayOfWeek BETWEEN 2 AND 6 -- Monday to Friday
),
WeekendSales AS (
    SELECT SUM(s.SalesAmount) AS TotalWeekendSales
    FROM FactSales s
    LEFT JOIN DimDate d ON s.DateKey = d.DateKey
    WHERE d.DayOfWeek IN (1, 7) -- Saturday and Sunday
)
SELECT
    ws.TotalWeekdaySales / we.TotalWeekendSales AS "Weekday/Weekend Sales Ratio"
FROM WeekdaySales ws, WeekendSales we;

------------------------------------------------------------------------------------------

DEFINE
VAR WeekdaySales =
    CALCULATE (
        SUM ( FactSales[SalesAmount] ),
        FILTER (
            DimDate,
            DimDate[DayOfWeek] >= 2 && DimDate[DayOfWeek] <= 6 // Monday to Friday
        )
    )
VAR WeekendSales =
    CALCULATE (
        SUM ( FactSales[SalesAmount] ),
        FILTER (
            DimDate,
            DimDate[DayOfWeek] = 1 || DimDate[DayOfWeek] = 7 // Saturday and Sunday
        )
    )
RETURN
    UNION ALL (
        SELECTCOLUMNS (
            SalesAmount,
            "Weekday Sales (Millions)", DIVIDE ( WeekdaySales, 1000000 )
        )
    )
    UNION ALL (
        SELECTCOLUMNS (
            SalesAmount,
            "Weekend Sales (Millions)", DIVIDE ( WeekendSales, 1000000 )
        )
    )
    UNION ALL (
        SELECTCOLUMNS (
            SalesAmount,
            "Weekday/Weekend Sales Ratio", DIVIDE ( WeekdaySales, WeekendSales )
        )
    );

-- For daily sales, you would typically use a different approach with SUMMARIZECOLUMNS and grouping by DayOfWeek.
-- The provided DAX snippet focuses on aggregated weekday/weekend totals and ratios.
