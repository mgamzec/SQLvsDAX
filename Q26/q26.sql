-- Find the total sales count for ChannelNames that contain the word "re" and were made after 2009.

SELECT
    cn.ChannelName,
    COUNT(*) AS generel_count,
    COUNT(CASE WHEN cn.ChannelName LIKE '%re%' THEN s.SalesKey END) AS advanced_search_count
FROM
    DimChannel cn
LEFT JOIN
    FactSales s ON s.channelKey = cn.ChannelKey
WHERE 1 = 1
    AND s.DateKey >= '20090101'
GROUP BY
    cn.ChannelName
ORDER BY
    cn.ChannelName;

-----------------------------------------------------------------

DEFINE
VAR var_date = DATE(2009, 01, 01)
MEASURE FactSales[general_count] = CALCULATE(
    COUNTROWS(FactSales),
    FILTER(FactSales, FactSales[Date] > var_date)
)
MEASURE FactSales[advanced_search_count] = COUNTROWS(
    FILTER(
        FactSales,
        FactSales[Date] > var_date
        && CONTAINSSTRING(RELATED(DimChannel[ChannelName]), "re")
    )
)
EVALUATE
SUMMARIZECOLUMNS(
    DimChannel[ChannelName],
    "general_count", [general_count],
    "advanced_search_count", [advanced_search_count]
)
