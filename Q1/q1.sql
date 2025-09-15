-- Find the top 3 rows with the highest Sales Amount by Year and Month (e.g., March 2008, January 2009, April 2009, etc.)

SELECT TOP 3 *
FROM (
    SELECT d.CalendarMonth,
           SUM(s.Salesamount) AS Salesamount
    FROM FactSales s
    LEFT JOIN DimDate d ON d.Datekey = s.DateKey
    GROUP BY d.CalendarMonth
) a
ORDER BY a.Salesamount DESC;


--------------------------------------------------------------------------

DEFINE
    VAR MonthlyTotalSales =
        SUMMARIZECOLUMNS(
            DimDate[YearAndMonth],
            "Total Sales", SUM(FactSales[SalesAmount])
        )
EVALUATE
    TOPN(
        3,
        MonthlyTotalSales,
        [Total Sales]
    )
ORDER BY [Total Sales]
