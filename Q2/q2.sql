-- How many stores have 100 or more employees?

SELECT COUNT(*) AS Result
FROM DimStore st
WHERE st.EmployeeCount >= 100;

--------------------------------------------------------

EVALUATE
ROW(
    "Result",
    CALCULATE(
        COUNTROWS(DimStore),
        FILTER(
            DimStore,
            DimStore[EmployeeCount] >= 100
        )
    )
)
