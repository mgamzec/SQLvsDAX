-- Question 8: Max Sales Amount by Color Name
-- Question: Find the year and month when the product color reached the highest sales amount.

SELECT
    a.ColorName,
    MAX(a.SalesAmount) AS Max_SalesAmount
FROM (
    SELECT
        EOMONTH(s.DateKey) AS aysoni,
        pd.ColorName,
        SUM(s.SalesAmount) / 1000 AS SalesAmount
    FROM
        FactSales s
    LEFT JOIN
        DimProduct pd ON pd.ProductKey = s.ProductKey
    GROUP BY
        EOMONTH(s.DateKey),
        pd.ColorName
) a
GROUP BY
    a.ColorName;

---------------------------------------------------------------------------------------

DEFINE
MEASURE FactSales[Max Monthly Sales] =
    MAXX (
        VALUES ( DimProduct[ColorName] ),
        CALCULATE (
            SUM ( FactSales[SalesAmount] )
        )
    )
EVALUATE
SUMMARIZECOLUMNS (
    DimProduct[ColorName],
    "Max Monthly Sales", [Max Monthly Sales]
);
