-- Provide examples of CountRows(), Count(), CountBlank(), DISTINCTCOUNTNOBLANK(), and DISTINCTCOUNT() functions in DAX.

-- SQL Query: (This question is primarily about DAX functions. The SQL part shows equivalent counting logic and an unpivot operation.)

SELECT
    mt.MovieType,
    COUNT(*) AS CountRows,
    COUNT(mt.MovieType) AS Count_MovieType,
    COUNT(*) - COUNT(mt.MovieType) AS CountBlank, -- Calculates CountBlank by subtracting non-nulls from total rows
    COUNT(distinct mt.MovieType) AS DISTINCTCOUNTNOBLANK,
    COUNT(distinct ISNULL(mt.MovieType, 999)) AS DISTINCTCOUNT -- Uses a proxy value (999) to count NULLs as a distinct item
FROM #Movie_table mt
GROUP BY mt.MovieType

-- *********************************************************************************
-- SQL UNPIVOT Operation (for comparison/demonstration purposes)
-- *********************************************************************************
SELECT *
FROM (
    SELECT
        count(*) as CountRows,
        count(mt.MovieType) as Count_MovieType,
        count(*) - count(mt.MovieType) as CountBlank,
        count(distinct mt.MovieType) as DISTINCTCOUNTNOBLANK,
        count(distinct ISNULL(mt.MovieType, 999)) as DISTINCTCOUNT
    from #Movie_table mt
) as tbl
UNPIVOT (
    Quantity for Fields in (CountRows, Count_MovieType, CountBlank, DISTINCTCOUNTNOBLANK, DISTINCTCOUNT)
) as unpvt_table;

------------------------------------------------------------------------------------------

EVALUATE
SUMMARIZECOLUMNS(
    Movie_Table[MovieType],
    "CountRows", COUNTROWS(Movie_Table),
    "Count_MovieType", COUNT(Movie_Table[MovieType]),
    "CountBlank", COUNTBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNTNOBLANK", DISTINCTCOUNTNOBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNT", DISTINCTCOUNT(Movie_Table[MovieType])
)

EVALUATE
ROW(
    "CountRows", COUNTROWS(Movie_Table),
    "Count_MovieType", COUNT(Movie_Table[MovieType]),
    "CountBlank", COUNTBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNTNOBLANK", DISTINCTCOUNTNOBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNT", DISTINCTCOUNT(Movie_Table[MovieType])
)
