-- Question 15: Total SalesAmount per Day and Previous Year's SalesAmount
-- Question: Calculate the total SalesAmount per day. Create a conditional column that shows the previous year's SalesAmount if it exists; otherwise, write "No Sales" for empty rows.

-- Note: SQL does not have a direct equivalent to DAX's DATEADD for "previous year" within a simple SELECT statement
-- without using window functions or CTEs. The DAX query is more direct for this specific request.
-- A basic SQL approach to show daily sales would be:
SELECT
    DateKey,
    SUM(SalesAmount) / 1000000 AS "Total SalesAmount (Millions)"
FROM
    FactSales
GROUP BY
    DateKey
ORDER BY
    DateKey;

-- To get the previous year's sales, you'd typically use LAG or a self-join with date manipulation.

----------------------------------------------------------------------------------------------------------

EVALUATE
SUMMARIZECOLUMNS (
    FactSales[Date],
    "Total SalesAmount", SUM ( FactSales[SalesAmount] ) / 1000000,
    "Previous Year - SalesAmount",
        VAR CurrentYear = YEAR ( FactSales[Date] )
        VAR PreviousYearSales =
            CALCULATE (
                SUM ( FactSales[SalesAmount] ) / 1000000,
                FILTER (
                    ALL ( FactSales ),
                    YEAR ( FactSales[Date] ) = CurrentYear - 1
                )
            )
        RETURN
            IF ( ISBLANK ( PreviousYearSales ), "No Sales", PreviousYearSales )
)
ORDER BY
    FactSales[Date];
