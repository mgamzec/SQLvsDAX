-- SalesKey, DateKey, SalesAmount Table Creation
-- Question: Create a table that outputs SalesKey, DateKey, and SalesAmount. For the "2007 Sales?" column, 
-- output 1 if the sales date is between '20070101' and '20071231', and 0 otherwise.

SELECT
    s.SalesKey,
    s.DateKey,
    s.SalesAmount,
    CASE
        WHEN s.DateKey BETWEEN '20070101' AND '20071231' THEN 1
        ELSE 0
    END AS "2007 Sales?"
FROM
    FactSales s
ORDER BY
    s.SalesKey;

--------------------------------------------------------------------------------

EVALUATE
SELECTCOLUMNS (
    FactSales,
    "SalesKey", FactSales[SalesKey],
    "DateKey", FactSales[DateKey],
    "SalesAmount", FactSales[SalesAmount],
    "2007 Sales?", IF (
        YEAR ( FactSales[DateKey] ) = 2007,
        1,
        0
    )
)
ORDER BY
    FactSales[SalesKey];
