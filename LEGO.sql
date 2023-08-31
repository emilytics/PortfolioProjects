SELECT *
FROM lego_sets_and_themes$

-- 1. Trends in LEGO Set Sizes and Themes Over Time
	-- Analyze how the number of parts in LEGO sets has changed over the years. 
	-- Line graphs/heat maps

SELECT year_released, ROUND(AVG(number_of_parts), 1) AS avg_num_parts
FROM lego_sets_and_themes$
WHERE year_released IS NOT NULL
GROUP BY year_released
ORDER BY year_released

-- Explore how different themes have evoled in terms of the average set size.

SELECT theme_name, ROUND(AVG(number_of_parts), 1) AS avg_num_parts
FROM lego_sets_and_themes$
GROUP BY theme_name
ORDER BY avg_num_parts DESC

-- Most popular theme of the year

WITH RankedThemes AS (
    SELECT
        year_released,
        theme_name,
        COUNT(theme_name) AS num_of_sets,
        ROW_NUMBER() OVER(PARTITION BY year_released ORDER BY COUNT(theme_name) DESC) AS theme_rank
    FROM lego_sets_and_themes$
    WHERE year_released IS NOT NULL
    GROUP BY year_released, theme_name
)
SELECT year_released, theme_name, num_of_sets
FROM RankedThemes
WHERE theme_rank = 1
ORDER BY year_released

-- 2. Text Analysis on Set Names
	-- Analyze the set names to identify common words or patterns in popular sets.
	-- World cloud

WITH WordCloudCTE AS(
	SELECT
		set_name,
		--PARSENAME(REPLACE(set_name, ' ', '.'), 5),
		PARSENAME(REPLACE(set_name, ' ', '.'), 4) AS word1, 
		PARSENAME(REPLACE(set_name, ' ', '.'), 3) AS word2, 
		PARSENAME(REPLACE(set_name, ' ', '.'), 2) AS word3, 
		PARSENAME(REPLACE(set_name, ' ', '.'), 1)AS word4
	FROM lego_sets_and_themes$
	--WHERE PARSENAME(REPLACE(set_name, ' ', '.'), 5) IS NOT NULL
)
SELECT 
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(word1, '(', ''), ')', ''), '{', ''), '}', ''), ':', ''), ',', ''), '!', '') AS Word,
	COUNT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(word1, '(', ''), ')', ''), '{', ''), '}', ''), ':', ''), ',', ''), '!', '')) AS Count
FROM (
	SELECT word1
	FROM WordCloudCTE
	UNION ALL
	SELECT word2
	FROM WordCloudCTE
	UNION ALL
	SELECT word3
	FROM WordCloudCTE
	UNION ALL
	SELECT word4
	FROM WordCloudCTE
	) AS WordList
WHERE word1 NOT IN ('NULL', 'at', 'for', 'from', 'I', 'II', 'in', 'it', 'the', '-', '--', '#1', '#2', '#3', '#4', '#5', '#6', '#7', '#8', '&', '(1)', '(13)', '(17)', '(18)', '(19)', '(2)', '(20)', '(2012', '(2015', '(21)', '(23)', '(4', '(42', '(5)', '(6', '(4)', '(6)', '(7)', '(8)', '(9)', 'and', '/', '+', '0', 'with', 'of', '07', '1', '-1-', '1/2', '1/3', '1', '110', '117', '124', '1300', '155', '18', '187', '19', '10', '100', '1001', '1030', '1032', '1090', '1092', '1100', '12', '1-2', '1210-2', '123', '1-2-3', '125', '128cm', '13', '1307-1', '1308-1', '1500', '150°', '16', '17M', '1800', '19', '1909', '1913', '1926', '1965', '1968', '1969', '1970', '1989', '1992', '1999', '2', '-2-', '20', '200', '2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '21', '210-2', '220', '24', '248', '25', '250', '258-2', '259-1', '25th', '2-6', '260', '2600', '261-2', '3', '-3-', '3+', '300', '3000', '307-2', '308-3', '310-5', '3245', '33', '35', '350', '37', '38', '3×3', '4', '4+', '40', '400-Piece', '42mm', '430', '45', '458', '4614581-1', '47', '48', '488', '5', '50', '500', '512', '52', '560-4', '6', '6000', '626', '64', '6500', '697', '7', '727', '7777', '787', '8', '8-', '800', '8000', '812', '85', '8748-1', '8888', '8889', '8890', '8891', '9', '90', '911', '918', '919', '963', '9654', '9800', 'a', '110')
GROUP BY word1
HAVING COUNT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(word1, '(', ''), ')', ''), '{', ''), '}', ''), ':', ''), ',', ''), '!', '')) > 1
ORDER BY Count DESC