/*
PROJECT: Layoffs Data Cleaning & Preparation for Analysis

OBJECTIVE:
Clean and standardize raw layoffs data to make it analysis-ready by:
- Removing duplicate records
- Standardizing categorical values
- Handling missing and null values
- Ensuring proper data types
- Creating a clean final table for downstream analysis

TOOLS:
- MySQL
- Window Functions (ROW_NUMBER)
- CTEs
*/

SELECT *
FROM layoffs;

-- Create a staging table to preserve raw data integrity
-- Best practice: never perform data cleaning directly on raw/source tables

DROP TABLE layoffs_fake;

CREATE TABLE layoffs_fake
LIKE layoffs;


SELECT *
FROM layoffs_fake ;

INSERT layoffs_fake
SELECT *
FROM layoffs ;

SELECT *
FROM layoffs_fake ;

-- Identify duplicate records using ROW_NUMBER()
-- Assumption: records sharing country, industry, layoff numbers, date,
-- and funding represent the same layoff event


SELECT *,
ROW_NUMBER() OVER(PARTITION BY country,industry,total_laid_off,percentage_laid_off,`date`,funds_raised_millions) as row_num
FROM layoffs_fake ;


DROP TABLE layoffs_fake_2;

-- Use a CTE to isolate duplicate records
-- This improves readability and allows safe validation before deletion

WITH duplicate_cte AS
(SELECT *,ROW_NUMBER() OVER(
PARTITION BY country,industry,total_laid_off,percentage_laid_off,`date`,funds_raised_millions) as row_num
FROM layoffs_fake
)
SELECT *
FROM duplicate_cte
where row_num >1 ;


CREATE TABLE `layoffs_fake_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


SELECT *
FROM layoffs_fake_2 ;

INSERT INTO layoffs_fake_2
SELECT * ,
ROW_NUMBER()OVER(
PARTITION BY country,industry,total_laid_off,percentage_laid_off,`date`,funds_raised_millions) as row_num
FROM layoffs_fake ;

SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM layoffs_fake_2 ;

-- Remove duplicate records while retaining one unique entry per event

DELETE
FROM layoffs_fake_2 
WHERE row_num > 1;

SELECT *
FROM layoffs_fake_2 
WHERE row_num > 1;

-- standerdise data

SELECT company,(TRIM(company))
FROM layoffs_fake_2; 

SELECT DISTINCT industry
FROM layoffs_fake_2; 

-- Standardize company names by removing leading/trailing spaces
-- Prevents grouping and aggregation errors during analysis

UPDATE layoffs_fake_2
SET company = TRIM(company);

SELECT *
FROM layoffs_fake_2
WHERE industry LIKE 'Crypto%';

-- Normalize industry values (e.g., CryptoCurrency, Crypto Tech → Crypto)
-- Improves consistency in industry-level reporting

UPDATE layoffs_fake_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%' ;

SELECT DISTINCT industry
FROM layoffs_fake_2;

SELECT DISTINCT country
FROM layoffs_fake_2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_fake_2
ORDER BY 1;

-- Remove punctuation inconsistencies in country names
-- Ensures accurate country-based analysis


UPDATE layoffs_fake_2 
SET country = TRIM(TRAILING '.' FROM country)
where country LIKE  'United States';

SELECT `date`
FROM layoffs_fake_2;

-- Convert date column from text to DATE format
-- Enables time-series and trend analysis

UPDATE layoffs_fake_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE  layoffs_fake_2
MODIFY COLUMN `date` DATE ;

-- data cleaning (null and missing values)
-- popultate data in colums 
SELECT *
FROM layoffs_fake_2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_fake_2
WHERE industry IS NULL
OR industry  = '';

UPDATE layoffs_fake_2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_fake_2 t1
JOIN layoffs_fake_2 t2
    ON t1.company = t2.company
WHERE t1.industry IS NULL;

-- Populate missing industry values using company-level matches
-- Assumption: each company belongs to a single primary industry

UPDATE layoffs_fake_2 t1
JOIN layoffs_fake_2 t2
    ON t1.company = t2.company
SET t1.industry  = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove records with no layoff information
-- These rows are not useful for analytical purposes

DELETE
FROM layoffs_fake_2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_fake_2;

ALTER TABLE layoffs_fake_2
DROP COLUMN row_num;

-- Final cleaned dataset ready for analysis

SELECT *
FROM layoffs_fake_2;







