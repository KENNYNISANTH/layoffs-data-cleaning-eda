# Layoffs Data Cleaning & Exploratory Analysis

A robust, end‑to‑end SQL pipeline for ingesting, cleansing, standardizing, and analyzing a global technology‑sector layoffs dataset. This project transforms raw layoff records into a clean, analysis‑ready table and provides targeted SQL queries to uncover key trends by company, funding stage, time period, and geography.

## Project Overview

Workforce reductions are announced in waves across the tech industry. By applying systematic data‑cleaning techniques and exploratory analysis, you can:

- Safely ingest raw CSV data into MySQL without altering the source.  
- Remove duplicate entries using window functions.  
- Trim and normalize text fields (`company`, `industry`, `country`).  
- Convert string‑formatted dates into native `DATE` types.  
- Handle NULLs and blank values in numeric and categorical columns.  
- Produce a final, clean table (`layoffs_staging2`) ready for analysis.  
- Execute a suite of SQL queries to:
  - Summarize maximum, minimum, and 100% layoff events.  
  - Aggregate layoffs by year, month, company, and funding stage.  
  - Compute rolling cumulative totals.  
  - Identify top‑N companies by annual layoffs.

## Prerequisites

- MySQL 8.0+ (or any SQL engine supporting window functions)  
- Access to the `world_layoffs.csv` file  
- Basic familiarity with running `.sql` scripts and terminal/git commands
