-- Question 13: Sales Amount for Each ChannelKey (1, 2, 3, 4) and Maximum Sales Amount per ChannelKey
-- Question: In the sales table, list the sales amount for each channelKey (1, 2, 3, 4). Then, create a conditional column and write the total sales amount for each row.

SELECT
    s.*,
    MAX(s.SalesAmount) OVER (PARTITION BY s.channelKey) AS Max_SalesAmount
FROM
    FactSales s
ORDER BY
    s.channelKey;

-- The SQL query above calculates the max sales amount per channelKey.
-- To achieve the combined output as shown in the DAX example (concatenated string),
-- you would typically use string aggregation functions specific to your SQL dialect (e.g., STRING_AGG in SQL Server).
-- For example:
/*
SELECT
    s.channelKey,
    s.SalesAmount,
    CONCAT(s.channelKey, ' - ', s.SalesAmount) AS CombinedColumns
FROM
    FactSales s
ORDER BY
    s.channelKey;
*/
--------------------------------------------------------------------------------------

DEFINE
VAR tbl =
    SUMMARIZECOLUMNS (
        FactSales[channelKey],
        "Max Sales", MAX ( FactSales[SalesAmount] )
    )
VAR tbl2 =
    SELECTCOLUMNS (
        ADDCOLUMNS (
            tbl,
            "CombinedColumns", CONCATENATE ( FactSales[channelKey], " - ", [Max Sales] )
        ),
        "SpecialColumns", [CombinedColumns]
    )
VAR tbl3 =
    ADDCOLUMNS (
        FactSales,
        "SpecialColumns", CONCATENATE ( FactSales[channelKey], " - ", FactSales[SalesAmount] )
    )
EVALUATE
NATURALINNERJOIN ( tbl, tbl3 );
