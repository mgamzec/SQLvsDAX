-- Question 18: Stores with Average SalesAmount per Employee Exceeding 100,000
-- Question: Find the stores where the average SalesAmount per employee exceeds 100,000.

SELECT
    a.SalesAmount / a.EmployeeCount AS "Average Sales per Employee"
FROM (
    SELECT
        st.StoreName,
        SUM(s.SalesAmount) AS SalesAmount,
        st.EmployeeCount
    FROM
        FactSales s
    LEFT JOIN
        DimStore st ON st.StoreKey = s.StoreKey
    WHERE
        st.channelKey = 1 -- Assuming channelKey = 1 represents stores you want to consider
    GROUP BY
        st.StoreName,
        st.EmployeeCount
) a
WHERE
    a.SalesAmount / a.EmployeeCount > 100000
ORDER BY
    "Average Sales per Employee";

-----------------------------------------------------------------------------------------------

DEFINE
VAR tbl =
    ADDCOLUMNS (
        SUMMARIZECOLUMNS (
            DimStore[StoreName],
            DimStore[EmployeeCount],
            FactSales[channelKey],
            "SalesAmount", CALCULATE ( SUM ( FactSales[SalesAmount] ) )
        ),
        "Average Sales per Employee", DIVIDE ( [SalesAmount], DimStore[EmployeeCount] )
    )
EVALUATE
FILTER (
    tbl,
    [Average Sales per Employee] > 100000
        && DimStore[channelKey] = 1 -- Filter for channelKey = 1 if needed
)
ORDER BY
    [Average Sales per Employee];
