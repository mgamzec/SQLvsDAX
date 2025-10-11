-- Find the count of orange-colored products sold in 2007 where the total SalesAmount is greater than 50,000 and the average SalesAmount is greater than 10,000.

SELECT COUNT(*) AS Adet
FROM (
    SELECT
        s.ProductKey,
        SUM(s.SalesAmount) AS SalesAmount_SUM,
        AVG(s.SalesAmount) AS SalesAmount_AVG
    FROM
        FactSales s
    LEFT JOIN
        DimProduct pd ON pd.ProductKey = s.ProductKey
    WHERE 1 = 1
        AND pd.ColorName = 'Orange'
        AND s.DateKey BETWEEN '20070101' AND '20071231'
    GROUP BY
        s.ProductKey
) t
WHERE 1 = 1
    AND t.SalesAmount_SUM > 50000
    AND t.SalesAmount_AVG > 10000;

-------------------------------------------------------------

EVALUATE
ROW(
    "Adet", CALCULATE(
        COUNTROWS(DimProduct),
        FILTER(
            DimProduct,
            DimProduct[ColorName] = "Orange"
            && CALCULATE(SUM(FactSales[SalesAmount]), DimDate[Year] = 2007) > 50000
            && CALCULATE(AVERAGE(FactSales[SalesAmount]), DimDate[Year] = 2007) > 10000
        )
    )
)
