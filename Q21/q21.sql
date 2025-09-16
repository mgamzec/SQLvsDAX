-- Question 21: Number of Stores Where the Difference Between Opening Date and First Sale Date is Greater Than 1000 Days
-- Question: What is the count of stores where the difference between their opening date and their first sale date is greater than 1000 days?

SELECT
    COUNT(t.StoreKey) AS GunFarki
FROM (
    SELECT
        st.StoreKey,
        MIN(s.DateKey) AS ilkSatisTarihi,
        st.OpenDate
    FROM
        FactSales s
    INNER JOIN
        DimStore st ON st.StoreKey = s.StoreKey
    LEFT JOIN
        DimStore st2 ON st2.StoreKey = s.StoreKey AND st2.Status = 'On' -- Assuming 'On' status is relevant
    WHERE
        st.StoreKey IS NOT NULL -- This condition might be redundant depending on INNER JOIN
    GROUP BY
        st.StoreKey,
        st.OpenDate
) t
WHERE
    DATEDIFF(day, t.OpenDate, t.ilkSatisTarihi) > 1000
ORDER BY
    4; -- Ordering by the 4th column, which is implicitly the count

---------------------------------------------------------------------------------------------------------------------

DEFINE
VAR tbl =
    SUMMARIZECOLUMNS (
        DimStore[StoreKey],
        DimStore[OpenDate],
        "FirstSaleDate", CALCULATE ( MIN ( FactSales[Date] ) ),
        "DaysDifference", CALCULATE ( DATEDIFF ( MIN ( DimStore[OpenDate] ), MIN ( FactSales[Date] ), DAY ) )
    )
EVALUATE
ROW (
    "Count", COUNTROWS (
        FILTER ( tbl, [DaysDifference] > 1000 )
    )
);
