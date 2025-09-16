-- Question 11: Daily Total SalesAmount and Cumulative SalesAmount (in Millions)
-- Question: Find the total SalesAmount and cumulative SalesAmount (in millions) per day.

SELECT
    t.DateKey,
    t.SalesAmount,
    SUM(t.SalesAmount) OVER (ORDER BY t.DateKey) AS "Cumulative Total"
FROM (
    SELECT
        s.DateKey,
        SUM(s.SalesAmount) / 1000000 AS SalesAmount
    FROM
        FactSales s
    GROUP BY
        s.DateKey
) t
ORDER BY
    t.DateKey;

----------------------------------------------------------------------------

EVALUATE
SUMMARIZECOLUMNS (
    FactSales[Date],
    "Sales Amount", SUM ( FactSales[SalesAmount] ) / 1000000,
    "Cumulative Total", CALCULATE (
        SUM ( FactSales[SalesAmount] ),
        FILTER (
            ALL ( FactSales ),
            FactSales[Date] <= MAX ( FactSales[Date] )
        )
    ) / 1000000
)
ORDER BY
    FactSales[Date];
