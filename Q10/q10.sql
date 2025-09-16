-- Question 10: Total Weight and Average Weight per Sale by Year and Month
-- Question: Find the total weight of sold items and the average weight per sale (in KG) by year and month.

SELECT
    d.CalendarMonth,
    SUM(s.SalesQuantity * pd.Weight) AS "Total Weight of Sold Items (KG)",
    AVG(s.SalesQuantity * pd.Weight) AS "Average Weight per Sale (KG)"
FROM
    FactSales s
LEFT JOIN
    DimDate d ON s.DateKey = d.DateKey
LEFT JOIN (
    SELECT
        s.ProductKey,
        CASE
            WHEN pd.WeightUnitMeasureID = 28 THEN (pd.Weight * 28) / 1000 -- ounces
            WHEN pd.WeightUnitMeasureID = 454 THEN (pd.Weight * 454) / 1000 -- pounds
            ELSE pd.Weight / 1000 -- grams
        END AS Weight
    FROM
        DimProduct pd
) p ON p.ProductKey = s.ProductKey
GROUP BY
    d.CalendarMonth
ORDER BY
    d.CalendarMonth;

-------------------------------------------------------------------------------------------------

EVALUATE
SUMMARIZECOLUMNS (
    DimDate[YearAndMonth],
    "Total Weight of Sold Items (KG)", SUMX (
        FactSales,
        FactSales[SalesQuantity] * RELATED ( DimProduct[Weight] )
    ),
    "Average Weight per Sale (KG)", AVERAGEX (
        FactSales,
        FactSales[SalesQuantity] * RELATED ( DimProduct[Weight] )
    )
);
