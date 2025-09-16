# SQL vs. DAX

This repository contains a collection of practical SQL and DAX query examples designed to help data professionals enhance their skills in data manipulation and analysis. Each example addresses a specific business question and provides both the SQL and DAX solutions.

## Objectives

* **Demonstrate SQL Proficiency:** Showcase how to retrieve, filter, and aggregate data effectively using SQL.
* **Illustrate DAX Power:** Highlight the capabilities of DAX in Power BI and other tools for complex calculations and data modeling.
* **Facilitate Learning:** Provide clear, commented code for users to learn from and adapt to their own projects.

## Examples

Here's a preview of the types of problems solved in this repository:

### 1. Sales by Color and Year
**Objective:** Find the year in which the sales amount for each product color reached its maximum.

* **SQL:**
    ```sql
    SELECT
        pd.ColorName,
        YEAR(s.DateKey) AS SalesYear,
        SUM(s.SalesAmount) AS TotalSalesAmount
    FROM
        FactSales s
    JOIN
        DimProduct pd ON s.ProductKey = pd.ProductKey
    GROUP BY
        pd.ColorName,
        YEAR(s.DateKey)
    ORDER BY
        pd.ColorName,
        TotalSalesAmount DESC;
    ```
* **DAX:**
    ```dax
    DEFINE
        MEASURE FactSales[Max Sales Amount] = SUM(FactSales[SalesAmount])
    EVALUATE
        SUMMARIZECOLUMNS(
            DimProduct[ColorName],
            "Max Monthly Sales", MAXX(
                VALUES(DimDate[Year and Month]),
                [Sales Amount]
            )
        )
    ```

### 2. Active Stores by Opening Date
**Objective:** Count the number of stores that opened more than 1000 days ago.

* **SQL:**
    ```sql
    SELECT
        COUNT(t.StoreID) AS StoreCount
    FROM
        (
            SELECT
                st.StoreID,
                st.OpenDate,
                MIN(s.DateKey) AS FirstSaleDate
            FROM
                FactSales s
            JOIN
                DimStore st ON s.StoreID = st.StoreID
            WHERE
                st.Status = 'On'
            GROUP BY
                st.StoreID,
                st.OpenDate
        ) t
    WHERE
        DATEDIFF(day, t.OpenDate, t.FirstSaleDate) > 1000;
    ```
* **DAX:**
    ```dax
    EVALUATE
        ROW(
            "Count", COUNTROWS(
                FILTER(
                    tbl,
                    [GunFarki] > 1000
                )
            )
        )
    ```

### 3. Sales Amount by Channel and Store
**Objective:** Calculate the total sales amount by ChannelKey and StoreKey.

* **SQL:**
    ```sql
    SELECT
        a.ChannelKey,
        a.StoreKey,
        SUM(a.SalesAmount) AS TotalSalesAmount
    FROM
        (
            SELECT
                s.ChannelKey,
                s.StoreKey,
                SUM(s.SalesAmount) / 1000000 AS SalesAmount
            FROM
                FactSales s
            GROUP BY
                s.ChannelKey,
                s.StoreKey
        ) a
    ORDER BY
        a.ChannelKey,
        a.StoreKey;
    ```
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            FactSales[ChannelKey],
            FactSales[StoreKey],
            "SalesAmount", SUM(FactSales[SalesAmount]) / 1000000,
            "SalesAmount_ALL", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                ALL(FactSales)
            ),
            "SalesAmount_ALL_EXCEPT", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                ALL(FactSales[ChannelKey])
            )
        )
    ```

### 4. Weekly Sales Amount Analysis
**Objective:** Calculate the total sales amount for each day of the week, previous week's total sales, and the total sales for the past Sunday, along with the ratio of weekday sales to weekend sales.

* **SQL:** (Complex SQL for this would involve multiple CTEs or subqueries, DAX is more suited for this)
* **DAX:**
    ```dax
    DEFINE
        VAR Gun_Satis =
            SUMMARIZECOLUMNS(
                DimDate[Day/Name],
                "SalesAmount", CALCULATE(SUM(FactSales[SalesAmount])) / 1000000
            )
        VAR Week_End =
            SUM(FactSales[SalesAmount]) / 1000000
        VAR Week_Day =
            SUM(FactSales[SalesAmount]) / 1000000
        VAR Oran =
            CALCULATE(SUM(FactSales[SalesAmount])) / SUM(FactSales[SalesAmount])
    EVALUATE
        UNION(
            Gun_Satis,
            Week_End,
            Week_Day,
            Oran
        )
    ```

### 5. Products Sold in 2007
**Objective:** List the product codes and names of products sold in the year 2007.

* **SQL:**
    ```sql
    SELECT DISTINCT
        p.ProductKey,
        p.ProductName
    FROM
        DimProduct p
    INNER JOIN (
        SELECT DISTINCT s.ProductKey
        FROM FactSales s
        WHERE YEAR(s.DateKey) = 2007
    ) t ON p.ProductKey = t.ProductKey
    ORDER BY
        p.ProductKey;
    ```
* **DAX:**
    ```dax
    DEFINE
        VAR satilan_urun_kodu_2007 =
            CALCULATETABLE(
                VALUES(FactSales[ProductKey]),
                DimDate[Year] = 2007
            )
    EVALUATE
        SUMMARIZECOLUMNS(
            DimProduct[ProductKey],
            DimProduct[ProductName],
            TREATAS(satilan_urun_kodu_2007, DimProduct[ProductKey])
        )
    ORDER BY
        DimProduct[ProductKey];
    ```

### 6. Total Weight and Average Weight per KG by Year
**Objective:** Calculate the total weight of products sold and the average weight per sale by year.

* **SQL:**
    ```sql
    SELECT
        d.CalendarMonth,
        SUM(s.SalesQuantity * pd.Weight) AS TotalWeightOfProductsSold_KG,
        AVG(s.SalesQuantity * pd.Weight) AS AverageWeightPerSale_KG
    FROM
        FactSales s
    LEFT JOIN
        DimDate d ON d.DateKey = s.DateKey
    LEFT JOIN
        DimProduct pd ON s.ProductKey = pd.ProductKey
    GROUP BY
        d.CalendarMonth
    ORDER BY
        d.CalendarMonth;
    ```
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            DimDate[YearAndMonth],
            "Satılan Ürünlerin toplam ağırlığı (KG)", SUMX(
                FactSales,
                FactSales[SalesQuantity] * RELATED(DimProduct[Weight])
            ),
            "Satış başına ortalama ağırlık (KG)", AVERAGEX(
                FactSales,
                FactSales[SalesQuantity] * RELATED(DimProduct[Weight])
            )
        )
    ```

### 7. Sales Data with 2007 Indicator
**Objective:** Create a table with SalesKey, DateKey, SalesAmount, and a column indicating if the sale occurred in 2007.

* **SQL:**
    ```sql
    SELECT
        s.SalesKey,
        s.DateKey,
        s.SalesAmount,
        CASE
            WHEN s.DateKey BETWEEN '20070101' AND '20071231' THEN 1
            ELSE 0
        END AS '2007 Satışı mı?'
    FROM
        FactSales s
    ORDER BY
        s.SalesKey;
    ```
* **DAX:**
    ```dax
    EVALUATE
        SELECTCOLUMNS(
            FactSales,
            "SalesKey", FactSales[SalesKey],
            "Date", FactSales[Date],
            "SalesAmount", FactSales[SalesAmount],
            "Is 2007 Sale?", IF(
                YEAR(FactSales[Date]) = 2007,
                1,
                0
            )
        )
    ORDER BY
        FactSales[SalesKey];
    ```

### 8. Year with Max Sales Amount per Color
**Objective:** Find the year in which the sales amount for each product color reached its maximum.

* **SQL:**
    ```sql
    SELECT
        pd.ColorName,
        YEAR(s.DateKey) AS SalesYear,
        SUM(s.SalesAmount) AS TotalSalesAmount
    FROM
        FactSales s
    JOIN
        DimProduct pd ON s.ProductKey = pd.ProductKey
    GROUP BY
        pd.ColorName,
        YEAR(s.DateKey)
    ORDER BY
        pd.ColorName,
        TotalSalesAmount DESC;
    ```
* **DAX:**
    ```dax
    DEFINE
        MEASURE FactSales[Max Sales Amount] = SUM(FactSales[SalesAmount])
    EVALUATE
        SUMMARIZECOLUMNS(
            DimProduct[ColorName],
            "Max Monthly Sales", MAXX(
                VALUES(DimDate[Year and Month]),
                [Sales Amount]
            )
        )
    ```

### 9. Weekly Sales Amount Analysis
**Objective:** Calculate the total sales amount for each day of the week, the total sales for the previous week, the total sales for the past Sunday, and the ratio of weekday sales to weekend sales (SalesAmount in millions).

* **SQL:** (This type of layered aggregation and ratio calculation is more efficiently handled in DAX.)
* **DAX:**
    ```dax
    DEFINE
        VAR DailySales =
            SUMMARIZECOLUMNS(
                DimDate[DayName],
                "Total Sales Amount (Millions)", SUM(FactSales[SalesAmount]) / 1000000
            )
        VAR PreviousWeekSales =
            CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                DATESINPERIOD(DimDate[Date], MAX(DimDate[Date]), -7, DAY)
            )
        VAR PastSundaySales =
            CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                DimDate[DayOfWeek] = "Sunday",
                DATESINPERIOD(DimDate[Date], MAX(DimDate[Date]), -7, DAY)
            )
        VAR WeekdayVsWeekendRatio =
            DIVIDE(
                CALCULATE(SUM(FactSales[SalesAmount]), DimDate[IsWeekday] = TRUE()),
                CALCULATE(SUM(FactSales[SalesAmount]), DimDate[IsWeekday] = FALSE()),
                0
            )
    EVALUATE
        UNION(
            DailySales,
            VAR PreviousWeekSalesTable = ROW("Previous Week Sales", PreviousWeekSales),
            VAR PastSundaySalesTable = ROW("Past Sunday Sales", PastSundaySales),
            VAR RatioTable = ROW("Weekday/Weekend Ratio", WeekdayVsWeekendRatio)
        )
    ```

### 10. Total Weight and Average Weight per Sale by Year
**Objective:** Calculate the total weight of products sold and the average weight per sale by year.

* **SQL:**
    ```sql
    SELECT
        YEAR(s.DateKey) AS SalesYear,
        SUM(s.SalesQuantity * pd.Weight) AS TotalWeightOfProductsSold_KG,
        AVG(s.SalesQuantity * pd.Weight) AS AverageWeightPerSale_KG
    FROM
        FactSales s
    LEFT JOIN
        DimProduct pd ON s.ProductKey = pd.ProductKey
    GROUP BY
        YEAR(s.DateKey)
    ORDER BY
        SalesYear;
    ```
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            DimDate[Year],
            "Satılan Ürünlerin toplam ağırlığı (KG)", SUMX(
                FactSales,
                FactSales[SalesQuantity] * RELATED(DimProduct[Weight])
            ),
            "Satış başına ortalama ağırlık (KG)", AVERAGEX(
                FactSales,
                FactSales[SalesQuantity] * RELATED(DimProduct[Weight])
            )
        )
    ```

### 11. Daily Sales and Cumulative Sales
**Objective:** Calculate daily sales amount and cumulative sales amount (in millions).

* **SQL:** (SQL can do this with window functions, but DAX provides a more straightforward approach for cumulative calculations.)
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            FactSales[Date],
            "Sales Amount", SUM(FactSales[SalesAmount]) / 1000000,
            "Cumulative Amount", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                FILTER(
                    ALL(FactSales),
                    FactSales[Date] <= MAX(FactSales[Date])
                )
            )
        )
    ORDER BY
        FactSales[Date];
    ```

### 12. Products Sold in 2007
**Objective:** List the product codes and names of products sold in the year 2007.

* **SQL:**
    ```sql
    SELECT DISTINCT
        p.ProductKey,
        p.ProductName
    FROM
        DimProduct p
    INNER JOIN (
        SELECT DISTINCT s.ProductKey
        FROM FactSales s
        WHERE YEAR(s.DateKey) = 2007
    ) t ON p.ProductKey = t.ProductKey
    ORDER BY
        p.ProductKey;
    ```
* **DAX:**
    ```dax
    DEFINE
        VAR satilan_urun_kodu_2007 =
            CALCULATETABLE(
                VALUES(FactSales[ProductKey]),
                DimDate[Year] = 2007
            )
    EVALUATE
        SUMMARIZECOLUMNS(
            DimProduct[ProductKey],
            DimProduct[ProductName],
            TREATAS(satilan_urun_kodu_2007, DimProduct[ProductKey])
        )
    ORDER BY
        DimProduct[ProductKey];
    ```

### 13. Top Sales per Channel Key
**Objective:** Retrieve rows from the Sales table for each channelKey that has the highest SalesAmount.

* **SQL:**
    ```sql
    SELECT
        s.*
    FROM
        FactSales s
    INNER JOIN (
        SELECT
            s.channelKey,
            MAX(s.SalesAmount) AS Max_SalesAmount
        FROM
            FactSales s
        GROUP BY
            s.channelKey
    ) t ON t.channelKey = s.channelKey AND t.Max_SalesAmount = s.SalesAmount
    ORDER BY
        s.channelKey;
    ```
* **DAX:**
    ```dax
    DEFINE
        VAR tbl =
            SUMMARIZECOLUMNS(
                FactSales[channelKey],
                "Max Satis", MAX(FactSales[SalesAmount])
            )
        VAR tbl2 =
            ADDCOLUMNS(
                tbl,
                "CombinedColumns", CONCATENATE(FactSales[channelKey], FactSales[Max Satis])
            )
        VAR tbl3 =
            ADDCOLUMNS(
                FactSales,
                "specialColumns", CONCATENATE(FactSales[channelKey], FactSales[SalesAmount])
            )
    EVALUATE
        NATURALINNERJOIN(tbl3, tbl2)
    ```

### 14. Sales Count by Channel and Channel Name
**Objective:** Calculate the sales count grouped by ChannelKey and ChannelName, and then create a conditional column based on these counts.

* **SQL:**
    ```sql
    SELECT
        c.c.ChannelKey,
        c.c.ChannelName,
        COUNT(*) AS 'Sales Count'
    FROM
        DimChannel c
    LEFT JOIN
        FactSales s ON c.ChannelKey = s.ChannelKey
    GROUP BY
        c.ChannelKey,
        c.ChannelName
    ORDER BY
        c.ChannelKey;
    ```
* **DAX:**
    ```dax
    DEFINE
        MEASURE FactSales[Sales Count] = COUNTROWS(FactSales)
        MEASURE FactSales[Sales Count (ALL)] = CALCULATE(COUNTROWS(FactSales), ALL(FactSales))
        MEASURE FactSales[Sales Count (ALLSELECTED)] = CALCULATE(COUNTROWS(FactSales), ALLSELECTED(FactSales))
    EVALUATE
        SUMMARIZECOLUMNS(
            DimChannel[ChannelKey],
            DimChannel[ChannelName],
            "Sales Count", [Sales Count],
            "Sales Count (ALL)", [Sales Count (ALL)],
            "Sales Count (ALLSELECTED)", [Sales Count (ALLSELECTED)]
        )
    ```

### 15. Daily Sales Amount and Previous Year's Sales Amount
**Objective:** Calculate the total daily sales amount and, for rows with no sales, display "No Sales". Also, show the previous year's sales amount.

* **SQL:** (DAX is generally more intuitive for time-intelligence functions like "previous year".)
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            FactSales[Date],
            "Total Sales Amount", SUM(FactSales[SalesAmount]) / 1000000,
            "Previous Year - Sales Amount", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                DATEADD(FactSales[Date], -1, YEAR)
            ),
            "NoSales", COALESCE(
                SUM(FactSales[SalesAmount]) / 1000000,
                "No Sales"
            )
        )
    ORDER BY
        FactSales[Date];
    ```

### 16. Years with No Sales or Low Sales Volume
**Objective:** Find years with no sales or where sales are less than 70,000. List years with sales quantities next to them.

* **SQL:** (This type of conditional aggregation and filtering is more elegantly handled with DAX.)
* **DAX:**
    ```dax
    EVALUATE
        FILTER(
            ADDCOLUMNS(
                VALUES(DimDate[Year]),
                "Sales Count", CALCULATE(COUNT(FactSales[SalesKey]))
            ),
            [Sales Count] > 70000 || ISBLANK([Sales Count])
        )
    ORDER BY
        DimDate[Year];
    ```

### 17. Total Cost and Sales Amount by Channel and Store
**Objective:** Calculate the total TotalCost and SalesAmount by ChannelKey and StoreKey and determine their ratio. Show only the top row based on the ratio.

* **SQL:**
    ```sql
    SELECT
        a.StoreKey,
        a.TotalCost,
        a.SalesAmount,
        a.Ratio
    FROM
        (
            SELECT
                s.StoreKey,
                SUM(s.TotalCost) AS TotalCost,
                SUM(s.SalesAmount) AS SalesAmount,
                ROW_NUMBER() OVER (ORDER BY SUM(s.TotalCost) / SUM(s.SalesAmount) DESC) AS RowNo,
                SUM(s.TotalCost) / SUM(s.SalesAmount) AS Ratio
            FROM
                FactSales s
            GROUP BY
                s.StoreKey
        ) a
    WHERE
        a.RowNo = 1;
    ```
* **DAX:**
    ```dax
    DEFINE
        VAR tbl =
            SUMMARIZECOLUMNS(
                FactSales[ChannelKey],
                FactSales[StoreKey],
                "SalesAmount", FactSales[SalesAmount],
                "TotalCost", FactSales[TotalCost],
                "Ratio Sira", DIVIDE(FactSales[TotalCost], FactSales[SalesAmount], 0)
            )
    EVALUATE
        ROW(
            "StoreKey", CALCULATE(
                VALUES(FactSales[StoreKey]),
                FILTER(tbl, [Ratio Sira] = 1)
            )
        )
    ```

### 18. Stores with Average Sales Amount per Employee Over 100,000
**Objective:** Find stores where the average sales amount per employee exceeds 100,000.

* **SQL:**
    ```sql
    SELECT
        a.StoreName,
        a.SalesAmount / a.EmployeeCount AS 'Average Sales per Employee'
    FROM
        (
            SELECT
                st.StoreName,
                st.EmployeeCount,
                SUM(s.SalesAmount) AS SalesAmount
            FROM
                FactSales s
            LEFT JOIN
                DimStore st ON s.StoreKey = st.StoreKey
            WHERE
                st.ChannelKey = 1
            GROUP BY
                st.StoreName,
                st.EmployeeCount
        ) a
    WHERE
        a.SalesAmount / a.EmployeeCount > 100000
    ORDER BY
        [Average Sales per Employee] DESC;
    ```
* **DAX:**
    ```dax
    DEFINE
        VAR tbl =
            ADDCOLUMNS(
                SUMMARIZE(
                    DimStore,
                    DimStore[StoreName],
                    "EmployeeCount", DimStore[EmployeeCount]
                ),
                "SalesAmount", CALCULATE(
                    SUM(FactSales[SalesAmount]),
                    FactSales[ChannelKey] = 1
                )
            )
    EVALUATE
        FILTER(
            tbl,
            [SalesAmount] / [EmployeeCount] > 100000 && [EmployeeCount] <> 0
        )
    ORDER BY
        [SalesAmount] / [EmployeeCount] DESC;
    ```

### 19. Total Cost and Yearly Average Cost by Color
**Objective:** Calculate the total TotalCost and the yearly average TotalCost by color.

* **SQL:**
    ```sql
    SELECT
        t.ColorName,
        SUM(t.TotalCost) AS TotalCost,
        AVG(t.TotalCost) AS YearlyAvg
    FROM
        (
            SELECT
                YEAR(s.DateKey) AS Year,
                pd.ColorName,
                SUM(s.TotalCost) / 1000 AS TotalCost
            FROM
                FactSales s
            LEFT JOIN
                DimProduct pd ON s.ProductKey = pd.ProductKey
            GROUP BY
                YEAR(s.DateKey),
                pd.ColorName
        ) t
    GROUP BY
        t.ColorName
    ORDER BY
        t.ColorName;
    ```
* **DAX:**
    ```dax
    DEFINE
        MEASURE FactSales[Total Cost] = SUM(FactSales[TotalCost]) / 1000
        MEASURE FactSales[Yearly Avg] = AVERAGEX(
            VALUES(DimDate[Year]),
            [Total Cost]
        )
    EVALUATE
        SUMMARIZECOLUMNS(
            DimProduct[ColorName],
            "Total Cost", [Total Cost],
            "Yearly Avg", [Yearly Avg]
        )
    ```

### 20. Sales Amount by Channel and Store
**Objective:** Calculate the total sales amount by ChannelKey and StoreKey.

* **SQL:**
    ```sql
    SELECT
        a.ChannelKey,
        a.StoreKey,
        SUM(a.SalesAmount) AS TotalSalesAmount
    FROM
        (
            SELECT
                s.ChannelKey,
                s.StoreKey,
                SUM(s.SalesAmount) / 1000000 AS SalesAmount
            FROM
                FactSales s
            GROUP BY
                s.ChannelKey,
                s.StoreKey
        ) a
    ORDER BY
        a.ChannelKey,
        a.StoreKey;
    ```
* **DAX:**
    ```dax
    EVALUATE
        SUMMARIZECOLUMNS(
            FactSales[ChannelKey],
            FactSales[StoreKey],
            "SalesAmount", SUM(FactSales[SalesAmount]) / 1000000,
            "SalesAmount_ALL", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                ALL(FactSales)
            ),
            "SalesAmount_ALL_EXCEPT", CALCULATE(
                SUM(FactSales[SalesAmount]) / 1000000,
                ALL(FactSales[ChannelKey])
            )
        )
    ```

### 21. Active Stores by Opening Date
**Objective:** Count the number of stores that opened more than 1000 days ago.

* **SQL:**
    ```sql
    SELECT
        COUNT(t.StoreID) AS StoreCount
    FROM
        (
            SELECT
                st.StoreID,
                st.OpenDate,
                MIN(s.DateKey) AS FirstSaleDate
            FROM
                FactSales s
            JOIN
                DimStore st ON s.StoreID = st.StoreID
            WHERE
                st.Status = 'On'
            GROUP BY
                st.StoreID,
                st.OpenDate
        ) t
    WHERE
        DATEDIFF(day, t.OpenDate, t.FirstSaleDate) > 1000;
    ```
* **DAX:**
    ```dax
    EVALUATE
        ROW(
            "Count", COUNTROWS(
                FILTER(
                    tbl,
                    [GunFarki] > 1000
                )
            )
        )
    ```

## Contributing

Feel free to contribute by adding more examples or improving existing ones. Please submit a pull request.

## License

This project is licensed under the MIT License.
