-- Question 14: Number of Sales by ChannelKey and ChannelName
-- Question: Find the number of sales by ChannelKey and ChannelName. Create a conditional column and write the total sales count for each row.

SELECT
    c.channelKey,
    c.ChannelName,
    COUNT(s.SalesKey) AS "Sales Count"
FROM
    DimChannel c
LEFT JOIN
    FactSales s ON c.channelKey = s.channelKey
GROUP BY
    c.channelKey,
    c.ChannelName
ORDER BY
    c.channelKey;

-----------------------------------------------------------------------

DEFINE
MEASURE FactSales[Sales Count] =
    COUNTA ( FactSales[SalesKey] )
MEASURE FactSales[Sales Count (ALL)] =
    CALCULATE ( COUNTA ( FactSales[SalesKey] ), ALL ( FactSales ) )
MEASURE FactSales[Sales Count (ALLSELECTED)] =
    CALCULATE ( COUNTA ( FactSales[SalesKey] ), ALLSELECTED ( FactSales ) )
EVALUATE
SUMMARIZECOLUMNS (
    DimChannel[channelKey],
    DimChannel[ChannelName],
    "Sales Count", [Sales Count],
    "Sales Count (ALL)", [Sales Count (ALL)],
    "Sales Count (ALLSELECTED)", [Sales Count (ALLSELECTED)]
);
