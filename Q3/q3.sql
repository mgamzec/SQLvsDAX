-- Find the TotalCost (in thousands) of products with a unit cost less than 7 and color Red or Blue in the year 2009**

SELECT SUM(s.TotalCost) / 1000 AS TotalCost
FROM FactSales s
LEFT JOIN DimProduct pd ON pd.ProductKey = s.ProductKey
WHERE pd.UnitCost < 7
  AND (pd.ColorID = 3 OR pd.ColorID = 6)
  AND s.DateKey BETWEEN '20090101' AND '20091231';


------------------------------------------------------------------------------------

EVALUATE
ROW(
    "TotalCost",
    CALCULATE(
        SUM(FactSales[TotalCost]) / 1000,
        DimProduct[UnitCost] < 7,
        OR(
            DimProduct[ColorID] = "3",
            DimProduct[ColorID] = "6"
        ),
        DimDate[Year] = 2009
    )
)
