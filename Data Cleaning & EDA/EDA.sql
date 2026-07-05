/*
=========================================================
Exploratory Data Analysis (EDA)
Project: Global Layoffs Dataset
=========================================================
*/

-- Dataset Preview
SELECT *
FROM world_layoffs.layoffs_staging2;


-- Maximum Layoffs in a Single Event
SELECT MAX(total_laid_off) AS highest_layoff
FROM world_layoffs.layoffs_staging2;


-- Layoff Percentage Range
SELECT
    MAX(percentage_laid_off) AS max_percentage,
    MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;


-- Companies with 100% Workforce Layoffs
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;


-- Fully Laid-off Companies by Funding Raised
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Largest Single Layoff Events
SELECT
    company,
    total_laid_off
FROM world_layoffs.layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 5;


-- Total Layoffs by Company
SELECT
    company,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;


-- Total Layoffs by Location
SELECT
    location,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY total_laid_off DESC
LIMIT 10;


-- Total Layoffs by Country
SELECT
    country,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC;


-- Total Layoffs by Year
SELECT
    YEAR(date) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year;


-- Total Layoffs by Industry
SELECT
    industry,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY total_laid_off DESC;


-- Total Layoffs by Funding Stage
SELECT
    stage,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;


-- Top 3 Companies by Layoffs Each Year
WITH Company_Year AS
(
    SELECT
        company,
        YEAR(date) AS year,
        SUM(total_laid_off) AS total_laid_off
    FROM world_layoffs.layoffs_staging2
    GROUP BY company, YEAR(date)
),
Company_Rank AS
(
    SELECT
        company,
        year,
        total_laid_off,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_laid_off DESC
        ) AS ranking
    FROM Company_Year
)
SELECT
    company,
    year,
    total_laid_off,
    ranking
FROM Company_Rank
WHERE ranking <= 3
AND year IS NOT NULL
ORDER BY year, total_laid_off DESC;


-- Monthly Layoffs
SELECT
    SUBSTRING(date,1,7) AS month,
    SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
GROUP BY month
ORDER BY month;


-- Rolling Monthly Layoffs
WITH Monthly_Layoffs AS
(
    SELECT
        SUBSTRING(date,1,7) AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM world_layoffs.layoffs_staging2
    GROUP BY month
)
SELECT
    month,
    SUM(total_laid_off) OVER (ORDER BY month) AS rolling_total_layoffs
FROM Monthly_Layoffs
ORDER BY month;
