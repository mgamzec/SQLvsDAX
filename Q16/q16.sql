-- Question 16: Years with More Than 70000 Sales or No Sales
-- Question: Find the years with more than 70000 sales, or years with no sales at all. Add the sales figures next to the years.

SELECT
    d.CalendarYear,
    COUNT(s.SalesKey) AS SalesCount
FROM
    DimDate d
LEFT JOIN
    FactSales s ON d.DateKey = s.DateKey
GROUP BY
    d.CalendarYear
HAVING
    COUNT(s.SalesKey) > 70000 OR COUNT(s.SalesKey) = 0
ORDER BY
    d.CalendarYear;

-----------------------------------------------------------------------------------

EVALUATE
FILTER (
    ADDCOLUMNS (
        VALUES ( DimDate[Year] ),
        "Sales Count", CALCULATE ( COUNT ( FactSales[SalesKey] ) )
    ),
    [Sales Count] > 70000 || ISBLANK ( [Sales Count] )
)
ORDER BY
    DimDate[Year];
