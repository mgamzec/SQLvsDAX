-- Question 17: TotalCost and SalesAmount Ranking by ChannelKey and StoreKey
-- Question: Rank TotalCost and SalesAmount by ChannelKey and StoreKey. Get the rank of the largest row.

SELECT
    t.StoreKey
FROM (
    SELECT
        s.channelKey,
        s.StoreKey,
        SUM(s.TotalCost) AS TotalCost,
        SUM(s.SalesAmount) AS SalesAmount,
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNo -- Placeholder for ranking if needed
    FROM
        FactSales s
    GROUP BY
        s.channelKey,
        s.StoreKey
) t
WHERE
    t.RowNo = 1;

-------------------------------------------------------------------------------------------------------

DEFINE
MEASURE FactSales[Total Cost] =
    SUM ( FactSales[TotalCost] )
MEASURE FactSales[Sales Amount] =
    SUM ( FactSales[SalesAmount] )
MEASURE FactSales[Rank Order] =
    RANKX (
        ALL ( FactSales ),
        DIVIDE ( [Total Cost], [Sales Amount], 0 ),
        ,
        ASC
    )
VAR tbl =
    SUMMARIZECOLUMNS (
        FactSales[channelKey],
        FactSales[StoreKey],
        "SalesAmount", [Sales Amount],
        "TotalCost", [Total Cost],
        "Rank Order", [Rank Order]
    )
EVALUATE
FILTER (
    tbl,
    [Rank Order] = 1
);
