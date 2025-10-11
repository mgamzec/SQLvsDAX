-- Find the total sales count in 2009 for products where the unit cost is greater than the average unit cost of all products.

SELECT COUNT(*) AS Adet
FROM FactSales s
INNER JOIN (
    SELECT
        pd.ProductKey
    FROM
        DimProduct pd
    WHERE 1 = 1
        AND pd.UnitCost > (
            SELECT AVG(p.UnitCost) AS OrtalamaUrunMaliyeti
            FROM DimProduct p
        )
) t ON t.ProductKey = s.ProductKey
WHERE 1 = 1
    AND s.DateKey BETWEEN '20090101' AND '20091231';

-------------------------------------------------------------

EVALUATE
ROW(
    "Satış Miktarı", CALCULATE(
        COUNTROWS(FactSales),
        DimDate[Year] = 2009,
        DimProduct[UnitCost] > AVERAGE(DimProduct[UnitCost])
    )
)
