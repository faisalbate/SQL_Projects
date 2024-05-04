CREATE DATABASE world_layoffs;

-- Inserted our data by right clicking on Tables and using table data import wizard

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null or Blank Values
-- 4. Remove unnecessary column or rows

-- Creating copy of raw data to make sure, we have backup data
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- 1. Remove Duplicates

-- Duplicate spots
SELECT *,
row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS number_of_rows
FROM layoffs_staging
ORDER BY number_of_rows DESC;

-- Creating a same table to insert a dublicate spots column
CREATE TABLE layoffs_staging2
LIKE layoffs_staging;

ALTER TABLE layoffs_staging2
ADD COLUMN number_of_rows INT;

-- Inserting the data into empty table

INSERT INTO layoffs_staging2
SELECT *,
row_number() OVER(partition by company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS number_of_rows
FROM layoffs_staging;

-- We check the Data
SELECT *
FROM layoffs_staging2
WHERE number_of_rows > 1;

-- We Delete the Duplicate Data
DELETE
FROM layoffs_staging2
WHERE number_of_rows > 1;

-- 2. Standardize the Data

-- Removing spaces from the data
SELECT TRIM(company), Company
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET Company = TRIM(Company);

-- Using TRIM with Trailing to get rid of special characters
SELECT DISTINCT Country
FROM layoffs_staging2;

SELECT DISTINCT TRIM(TRAILING '.' FROM Country), Country
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM Country)
WHERE Country LIKE 'United States%';

-- Correcting the spellings
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1; -- means industry is 1st Column

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Changing the format of date column from string to date
SELECT `DATE`,
str_to_date(`DATE`,'%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `Date` = STR_TO_DATE(`Date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `Date` Date;

-- 3. Null or Blank Values
-- We can spot the null or blanks using DISTINCT

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR Industry = '';

-- Checking the NULL matching industry by company
SELECT *
FROM layoffs_staging2
WHERE company = "Airbnb";

-- Updateing blanks with nulls to use joins for updating rows

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 4. Remove unnecessary column or rows

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN number_of_rows;

-- Here's our cleaned Data

SELECT *
FROM layoffs_staging2;