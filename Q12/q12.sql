-- Question 12: Product Code and Name for Products Sold in 2007
-- Question: List the product code and name of products that were sold in 2007.

SELECT
    p.ProductKey,
    p.ProductName
FROM
    DimProduct p
INNER JOIN (
    SELECT DISTINCT
        s.ProductKey
    FROM
        FactSales s
    WHERE
        YEAR(s.DateKey) = 2007
) t ON t.ProductKey = p.ProductKey
ORDER BY
    p.ProductKey;

----------------------------------------------------------------------------------------

DEFINE
VAR satilan_urun_kodu_2007 =
    CALCULATETABLE (
        VALUES ( FactSales[ProductKey] ),
        DimDate[Year] = 2007
    )
EVALUATE
SUMMARIZECOLUMNS (
    DimProduct[ProductKey],
    DimProduct[ProductName],
    "Products Sold in 2007", TREATAS ( satilan_urun_kodu_2007, DimProduct[ProductKey] )
)
ORDER BY
    DimProduct[ProductKey];
