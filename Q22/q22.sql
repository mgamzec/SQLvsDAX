-- Apply the following discounts to 2009 sales: Store sales 40% discount, Online sales 20% discount, Catalog sales 30% discount
-- and all other sales 10% discount. Show the sales and discounted sales amount by product.

IF OBJECT_ID('tempdb..#tbl') IS NOT NULL DROP TABLE #tbl

SELECT
    s.ChannelKey,
    s.ProductKey,
    s.SalesAmount AS SalesAmount_2009,
    CASE
        WHEN s.ChannelKey = 1 THEN s.SalesAmount * 0.6 -- 1-0.40
        WHEN s.ChannelKey = 2 THEN s.SalesAmount * 0.8 -- 1-0.20
        WHEN s.ChannelKey = 3 THEN s.SalesAmount * 0.7 -- 1-0.30
        ELSE s.SalesAmount * 0.9 -- 1-0.10
    END AS SalesAmount_2009_Discounted
INTO #tbl
FROM FactSales s
WHERE 1 = 1
    AND YEAR(s.DateKey) = 2009;

SELECT
    t.ProductKey,
    SUM(t.SalesAmount_2009) / 1000 AS SalesAmount_2009,
    SUM(CAST(t.SalesAmount_2009_Discounted AS money)) / 1000 AS SalesAmount_2009_Discounted
FROM #tbl t
GROUP BY t.ProductKey
ORDER BY 1;

------------------------------------------------------------------------------------

DEFINE
MEASURE FactSales[SalesAmount - 2009] = CALCULATE(
    SUM(FactSales[SalesAmount]),
    DimDate[Year] = 2009
)

MEASURE FactSales[Discounted Sales Amount - 2009] = SUMX(
    VALUES(DimChannel[ChannelKey]),
    VAR Discount = SWITCH(
        TRUE(),
        DimChannel[ChannelKey] = 1, 0.6,
        DimChannel[ChannelKey] = 2, 0.8,
        DimChannel[ChannelKey] = 3, 0.7,
        0.9
    )
    RETURN
    [SalesAmount - 2009] * Discount
)

EVALUATE
SUMMARIZECOLUMNS(
    DimProduct[ProductKey],
    "SalesAmount - 2009", [SalesAmount - 2009] / 1000,
    "Discounted Sales Amount - 2009", [Discounted Sales Amount - 2009] / 1000
)
