---DATA CLEANING


select *
from layoffs;

--- 1. remove duplicates
--- 2. Standarize data
--- 3. Null values or black values
--- 4. Remove any columns or rows

---CREATED A TABLE JUST IN CASE IF WE DELETE OR INSERT EXTRA COLUMNS OR WE MIGHT LOSE SOME OF THE DATA on the raw table

Create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;


--- SO WE START BY REMOVING DUPLICATES

Select *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) as row_numb
from layoffs_staging;

WITH duplicate_cte AS
(
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numb
from layoffs_staging
)
select *
from duplicate_cte 
where row_numb > 1



WITH duplicate_cte AS
(
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numb
from layoffs_staging
)
delete
from duplicate_cte 
where row_numb > 1;



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_numb` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

insert into layoffs_staging2
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_numb
from layoffs_staging;


select *
from layoffs_staging2
where row_numb > 1;

delete
from layoffs_staging2
where row_numb > 1;

---STANDARDIZING DATA


select company, trim(company)
from layoffs_staging2;


update layoffs_staging2
set company = trim(company);

select distinct industry
from layoffs_staging2;

select *
from layoffs_staging2
where industry like "Crypto%";

update layoffs_staging2
set industry = "Crypto"
where industry like 'Crypto%';

select distinct industry
from layoffs_staging2;

select distinct country, trim(Trailing '.' from country)
from layoffs_staging2
order by 1;


update layoffs_staging2
set country = trim(Trailing '.' from country)
where country like 'United States%';

 -----so on months and days we have to put lower case and for year we put uppercase (Y)
 
 
select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')  
from layoffs_staging2;


update layoffs_staging2
set `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


select `date`
from layoffs_staging2;

--- so we still have DATE as a text so lets change it to DATE

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

--- WE work with NULL VALUES now

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;


update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select *
from layoffs_staging2
where company like "Bally";

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
     on t1.company = t2.company
     and t1.location = t2.location
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update layoffs_staging2 t1
join layoffs_staging2 t2
     on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;

--- I DELETED SOME OF THE DATA CAUSE IT JUST DIDNT MAKE SENSE TO HAVE IT THERE AND I DIDNT TRUST THAT DATA WILL SERVE ANYTHING
---- SO TOTAL LAID OFF AND PERCENTAGE IS DELETED BUT IF WE HAD THE TOTAL BEFORE THE LAID OFF BUT WE DONT HAVE THAT DATA
--- SO LETS SAY IF TOTAL IS 50 AND 100% IS LAID OFF THAT MEANS 50 PEOPLE GOT LAID OFF BUT WE DONT HAVE THAT DATA 

Delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
drop column row_numb;




