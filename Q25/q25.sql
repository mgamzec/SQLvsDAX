-- Provide examples of CountRows(), Count(), CountBlank(), DISTINCTCOUNTNOBLANK(), and DISTINCTCOUNT() functions in DAX.

-- SQL Query: (This question is primarily about DAX functions. The SQL part shows equivalent counting logic and an unpivot operation.)

SELECT
    mt.MovieType,
    COUNT(*) AS CountRows,
    COUNT(mt.MovieType) AS Count_MovieType,
    COUNT(*) - COUNT(mt.MovieType) AS CountBlank,
    COUNT(distinct mt.MovieType) AS DISTINCTCOUNTNOBLANK,
    COUNT(distinct ISNULL(mt.MovieType, 999)) AS DISTINCTCOUNT
FROM #Movie_table mt
GROUP BY mt.MovieType

----------------------------------------------------------------

EVALUATE
SUMMARIZECOLUMNS(
    Movie_Table[MovieType],
    "CountRows", COUNTROWS(Movie_Table),
    "Count_MovieType", COUNT(Movie_Table[MovieType]),
    "CountBlank", COUNTBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNTNOBLANK", DISTINCTCOUNTNOBLANK(Movie_Table[MovieType]),
    "DISTINCTCOUNT", DISTINCTCOUNT(Movie_Table[MovieType])
)
