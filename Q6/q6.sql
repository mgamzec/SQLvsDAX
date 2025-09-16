-- What is the total sales amount (in thousands) on the last sales day?

SELECT SUM(s.SalesAmount) / 1000 AS "Last Day Total Sales (KTL)"
FROM FactSales s
WHERE s.DateKey = (
    SELECT MAX(s.DateKey)
    FROM FactSales s
);

-------------------------------------------------------------------

DEFINE
    VAR LastDate = MAX(FactSales[Date])
EVALUATE
ROW(
    "Last Day Total Sales (KTL)",
    CALCULATE(
        SUM(FactSales[SalesAmount]) / 1000,
        FILTER(
            FactSales,
            FactSales[Date] = LastDate
        )
    )
)
