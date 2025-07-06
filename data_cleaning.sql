-- STEP 1: Create a staging table to work with data without modifying original
CREATE TABLE layoffs_staging LIKE layoffs;

-- Insert data from the original table into staging
INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- STEP 2: Create a second staging table with a row_num column for deduplication
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

-- Insert data with row_number to identify duplicates
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER (
  PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Remove duplicate records (row_num > 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- STEP 3: Standardize company names (trim extra spaces)
UPDATE layoffs_staging2
SET company = TRIM(company);

-- STEP 4: Standardize industry values (e.g., all variations of "Crypto" to "Crypto")
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- STEP 5: Standardize country names (remove trailing periods)
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- STEP 6: Convert `date` from string to DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Alter column type to DATE for proper formatting
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- STEP 7: Replace empty strings in industry with NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- STEP 8: Fill NULL industry values using existing non-null rows from the same company & location
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
  ON t1.company = t2.company AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- STEP 9: Delete rows that contain no layoff information at all
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 10: Final cleanup – remove the helper column used for deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- ✅ Final cleaned dataset is in `layoffs_staging2`
SELECT * FROM layoffs_staging2;
