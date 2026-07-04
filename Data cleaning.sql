/*
=========================================================
Data Cleaning
Project: Global Layoffs Dataset
=========================================================
*/

-- Preview Raw Dataset
SELECT *
FROM world_layoffs.layoffs;


-- Create Staging Table
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT *
FROM world_layoffs.layoffs;


-- =====================================================
-- Duplicate Detection
-- =====================================================

SELECT *
FROM world_layoffs.layoffs_staging;

SELECT
    company,
    industry,
    total_laid_off,
    `date`,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, `date`
    ) AS row_num
FROM world_layoffs.layoffs_staging;


-- Identify Duplicate Records
SELECT *
FROM (
    SELECT
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry,
                         total_laid_off, percentage_laid_off,
                         `date`, stage, country,
                         funds_raised_millions
        ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;


-- Create Clean Staging Table
CREATE TABLE world_layoffs.layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT,
    row_num INT
);


-- Insert Data with Duplicate Identifier
INSERT INTO world_layoffs.layoffs_staging2
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry,
                     total_laid_off, percentage_laid_off,
                     `date`, stage, country,
                     funds_raised_millions
    ) AS row_num
FROM world_layoffs.layoffs_staging;


-- Remove Duplicate Records
DELETE
FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;


-- =====================================================
-- Data Standardization
-- =====================================================

SELECT DISTINCT industry
FROM world_layoffs.layoffs_staging2
ORDER BY industry;


-- Replace Blank Industries with NULL
UPDATE world_layoffs.layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- Populate Missing Industry Values
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;


-- Standardize Industry Names
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');


-- Standardize Country Names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Convert Date Format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- =====================================================
-- Handle Missing Values
-- =====================================================

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- Remove Records Without Layoff Information
DELETE
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;


-- =====================================================
-- Final Cleanup
-- =====================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


-- Final Clean Dataset
SELECT *
FROM world_layoffs.layoffs_staging2;