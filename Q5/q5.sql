-- Find the number of sales where the ClassName is 'Economy' or 'Deluxe', ColorID is not in (1,2,3,4,5), and Sales Amount is greater than 10000**

SELECT COUNT(*) AS Quantity
FROM FactSales s
LEFT JOIN DimProduct pd ON pd.ProductKey = s.ProductKey
WHERE pd.ClassName IN ('Economy', 'Deluxe')
  AND pd.ColorID NOT IN (1,2,3,4,5)
  AND s.SalesAmount > 10000;

-------------------------------------------------------------------------

EVALUATE
ROW(
    "Quantity",
    CALCULATE(
        COUNTROWS(FactSales),
        DimProduct[ClassName] IN {"Economy", "Deluxe"},
        NOT DimProduct[ColorID] IN {"1","2","3","4","5"},
        FactSales[SalesAmount] > 10000
    )
)
