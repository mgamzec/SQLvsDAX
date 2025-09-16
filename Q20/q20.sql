-- Question 20: SalesAmount by ChannelKey and StoreKey, with Overall and Channel-Specific Totals
-- Question: Find the SalesAmount by ChannelKey and StoreKey. Add the following to the resulting table: 1. Overall Total SalesAmount. 2. Total SalesAmount by ChannelKey.

SELECT
    a.*,
    SUM(a.SalesAmount) OVER () AS SalesAmount_ALL,
    SUM(a.SalesAmount) OVER (PARTITION BY a.ChannelKey) AS SalesAmount_ALLExcept
FROM (
    SELECT
        s.channelKey,
        s.StoreKey,
        SUM(s.SalesAmount) / 1000000 AS SalesAmount
    FROM
        FactSales s
    GROUP BY
        s.channelKey,
        s.StoreKey
) a
ORDER BY
    a.channelKey, a.StoreKey;

--------------------------------------------------------------------------------------------------------
EVALUATE
SUMMARIZECOLUMNS (
    FactSales[channelKey],
    FactSales[StoreKey],
    "SalesAmount", SUM ( FactSales[SalesAmount] ) / 1000000,
    "SalesAmount_ALL", CALCULATE (
        SUM ( FactSales[SalesAmount] ) / 1000000,
        ALL ( FactSales )
    ),
    "SalesAmount_ALLExcept", CALCULATE (
        SUM ( FactSales[SalesAmount] ) / 1000000,
        ALL ( FactSales[StoreKey] ) // This is to partition by channelKey, effectively removing the StoreKey context
    )
)
ORDER BY
    FactSales[channelKey], FactSales[StoreKey];
