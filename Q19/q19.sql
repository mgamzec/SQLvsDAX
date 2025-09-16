-- Question 19: TotalCost and Yearly Average TotalCost by Color Name
-- Question: Find the TotalCost and yearly average TotalCost by color name.

SELECT
    t.ColorName,
    SUM(t.TotalCost) AS TotalCost,
    AVG(t.TotalCost) AS "Yearly Avg"
FROM (
    SELECT
        YEAR(s.DateKey) AS Year,
        pd.ColorName,
        SUM(s.TotalCost) / 1000 AS TotalCost
    FROM
        FactSales s
    LEFT JOIN
        DimProduct pd ON pd.ProductKey = s.ProductKey
    GROUP BY
        YEAR(s.DateKey),
        pd.ColorName
) t
GROUP BY
    t.ColorName
ORDER BY
    t.ColorName;

--------------------------------------------------------------------

DEFINE
MEASURE FactSales[Total Cost] =
    SUM ( FactSales[TotalCost] ) / 1000
MEASURE FactSales[Yearly Avg] =
    AVERAGEX (
        VALUES ( DimDate[Year] ),
        [Total Cost]
    )
EVALUATE
SUMMARIZECOLUMNS (
    DimProduct[ColorName],
    "Total Cost", [Total Cost],
    "Yearly Avg", [Yearly Avg]
);
