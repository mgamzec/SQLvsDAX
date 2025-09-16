-- Find the product names that have more than 50 sales with the same PromotionKey

SELECT pd.ProductName,
       s.PromotionKey,
       COUNT(*) AS Quantity
FROM FactSales s
LEFT JOIN DimProduct pd ON pd.ProductKey = s.ProductKey
GROUP BY pd.ProductName, s.PromotionKey
HAVING COUNT(*) > 50
ORDER BY Quantity, pd.ProductName;

----------------------------------------------------------------------------

DEFINE
    VAR grouped_table =
        SUMMARIZECOLUMNS(
            DimProduct[ProductName],
            DimPromotion[PromotionKey],
            "Quantity", COUNTROWS(FactSales)
        )
EVALUATE
    FILTER(
        grouped_table,
        [Quantity] > 50
    )
ORDER BY [Quantity], DimProduct[ProductName]
