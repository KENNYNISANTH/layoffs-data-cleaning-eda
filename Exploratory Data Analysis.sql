-- STEP 1: View the cleaned dataset
SELECT * 
FROM layoffs_staging2;

-- STEP 2: Find the maximum number of layoffs and max layoff percentage
-- Note: percentage_laid_off is in 0-1 range, so multiply by 100
SELECT MAX(total_laid_off), MAX(percentage_laid_off) * 100
FROM layoffs_staging2;

-- STEP 3: Companies with 100% layoffs, ordered by most funding
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- STEP 4: Total layoffs per company
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC;

-- STEP 5: Earliest and latest layoff dates in dataset
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- STEP 6: Year-wise total layoffs
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;

-- STEP 7: Layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- STEP 8: Average layoffs per company
SELECT company, AVG(total_laid_off) AS avg_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY company DESC;

-- STEP 9: Monthly layoffs
SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY `month`
ORDER BY `month` ASC;

-- STEP 10: Monthly rolling total of layoffs
WITH rolling_total AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
  FROM layoffs_staging2
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
  GROUP BY `month`
)
SELECT `month`, total_off, 
       SUM(total_off) OVER (ORDER BY `month`) AS Rolling_Total
FROM rolling_total;

-- STEP 11: Company layoffs per year
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_laid_off DESC;

-- STEP 12: Top 5 companies by layoffs each year
WITH company_year (company, Years, Total_laid_off) AS (
  SELECT company, YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY company, YEAR(`date`)
),
company_year_rank AS (
  SELECT *, 
         DENSE_RANK() OVER (PARTITION BY Years ORDER BY Total_laid_off DESC) AS ranking
  FROM company_year
  WHERE Years IS NOT NULL
)
SELECT *
FROM company_year_rank
WHERE ranking <= 5;
