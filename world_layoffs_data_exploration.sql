-- Data Exploration
-- SUM, YEAR, SUBSTRING, CTE, Window Function, LIMIT

SELECT * 
FROM layoffs_staging2;

/*
1. One by one Total Laid offs by Industry, Top 5 Country, Indian Locations, and Year
2. Trendline of Month_Year and rolling total of total_laid_offs
3. Rank top 5 laid offs by the company with each year
*/

-- 1. One by one Total Laid offs by Industry, Top 5 Country, Indian Locations, and Year
-- Total Laid offs by Industry
SELECT Industry, SUM(total_laid_off) AS laid_offs
FROM layoffs_staging
WHERE industry IS NOT NULL
GROUP BY Industry
ORDER BY 2 DESC;

-- Top 5 Total laid off by Country
SELECT Country, SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
WHERE Country IS NOT NULL
GROUP BY Country
ORDER BY laid_off DESC
LIMIT 5;

-- Total Laid offs by Indian locations
SELECT location, SUM(total_laid_off) AS laid_off
FROM layoffs_staging2
WHERE location IS NOT NULL AND Country = 'India'
GROUP BY location
ORDER BY 2 DESC;

-- Total Laid offs by year

SELECT MIN(`Date`), MAX(`Date`)
FROM layoffs_staging2;

SELECT YEAR(`Date`) AS `Year`, SUM(total_laid_off) AS Total_laid_offs
FROM layoffs_staging2
WHERE `Date` IS NOT NULL
GROUP BY `Year`
ORDER BY 2 DESC;

-- 2. Trendline of Month_Year and rolling total of total_laid_offs
-- Trendline with Year_Months of total laid offs

SELECT SUBSTRING(`Date`, 1, 7) AS Months, SUM(total_laid_off) AS Laid_offs
FROM layoffs_staging2
WHERE `Date` IS NOT NULL
GROUP BY Months
ORDER BY 1;

-- Trendline with rolling total by year of total_laid_offs

WITH rolling_total AS (
SELECT SUBSTRING(`Date`, 1, 7) AS Months, SUM(total_laid_off) AS Laid_offs
FROM layoffs_staging2
WHERE `Date` IS NOT NULL
GROUP BY Months
ORDER BY Laid_offs
)
SELECT Months, Laid_offs, SUM(Laid_offs) OVER(PARTITION BY SUBSTRING(Months, 1, 4) ORDER BY Months) AS Rolling_total
FROM rolling_total
ORDER BY 1;


-- 3. Rank top 5 laid offs by the company with each year

SELECT company, YEAR(`Date`) AS years, SUM(total_laid_off) AS laid_offs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
GROUP BY company, years
ORDER BY 1;

WITH ranking AS (
SELECT company, YEAR(`Date`) AS years, SUM(total_laid_off) AS laid_offs
FROM layoffs_staging2
WHERE total_laid_off
GROUP BY company, years
), Ranking_top AS (
SELECT *, DENSE_RANK () OVER(PARTITION BY years ORDER BY laid_offs DESC) AS ranked
FROM ranking
WHERE years IS NOT NULL
)
SELECT *
FROM ranking_top
WHERE ranked <= 5;