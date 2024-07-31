-- DATA CLEANING
-- 1) removing duplicates
-- 2) standardizing data
-- 3)managing null or blanks
-- 4) remove any columns and rows if required

-- *********************************************************REMOVING DUPLICATES*****************************************************
select *from layoffs;
create table layoffs_staging
like layoffs;
insert into layoffs_staging
select *from layoffs;
select *from layoffs_staging;        
-- -------------------------------COMPLETED------------------------creation of layoffs_staging table done -------
select *,
row_number()over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num
from layoffs_staging;
with CTE_eg as
(
select *,
row_number()over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num
from layoffs_staging
)
select * from CTE_eg
where row_num > 1;
select *from layoffs_staging where company="Casper";
-- --------------------------------COMPLETED--------got the rows where there are duplicates-----------------------
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
insert into  layoffs_staging2
select *,
row_number()over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num
from layoffs_staging;
select *from layoffs_staging2;
-- ---------------------COMPLETED------creation of layoffs_staging2 table done for deleting the duplicate rows-----------
delete from layoffs_staging2
where row_num>1;
select * from layoffs_staging2 where company="Casper";
-- ------------------------------COMPLETED--------------------deletion of the duplicate values done-----------------------


-- *****************************************************STANDARDIZING DATA************************************************
select distinct company,(trim(company))
from layoffs_staging2;
update layoffs_staging2
set company=(trim(company));
select *from layoffs_staging2;
-- -----------COMPLETED--------------------trimming the spaces infront of the companies---------------------------
select distinct industry
from layoffs_staging2
order by 1;
select *
from layoffs_staging2
where industry like "Crypto%";
update layoffs_staging2
set industry="Crypto"
where industry like "Crypto%";
-- -----------------------COMPLETED--------converting 'cryptocurrency' company to 'crypto' done----------------------
select distinct country
from layoffs_staging2
order by 1;
select  distinct country
from layoffs_staging2
where country like "United St%";
select distinct country,trim(trailing'.' from  country)
from layoffs_staging2;
update layoffs_staging2
set country=trim(trailing'.' from  country);
-- -----------COMPLETED--------------trimming the trailing dot from 'country' done-------------------------
select `date`,
str_to_date(`date`,"%m/%d/%Y")
from layoffs_staging2;
update layoffs_staging2
set `date`=str_to_date(`date`,"%m/%d/%Y");
alter table layoffs_staging2
-- --------------FAILED----------converting the data type of 'date' from text to date---------------------
modify `date` date;
select* from layoffs_staging2;
-- --------------COMPLETED--------converting the data type of 'date' from text to date-------------------


-- *********************************************REMOVING THE NULL AND THE BLANKS******************************************
 update layoffs_staging2
 set industry=null
 where industry='';
 -- ---------------COMPLETED-----------setting the blanks of the 'industry' into null values---------------------
 select * 
 from layoffs_staging2
 where industry is null
 or industry='';
 select  *
 from layoffs_staging2
 where company="Airbnb";
 select t1.industry,t2.industry
 from layoffs_staging2 t1
 join layoffs_staging2 t2
	on t1.company=t2.company
where (t1.industry is null or t1.industry='')
and t2.industry is not null;
update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
set t1.industry=t2.industry
where t1.industry is null 
and t2.industry is not null;
-- -------COMPLETED----managing the null values from the industry column where other records of the same company exist----------


-- *******************************************************REMOVING ANY ROWS**************************************************
select  *
from layoffs_staging2
where total_laid_off is null
 and percentage_laid_off is null;
delete
from layoffs_staging2
where total_laid_off is null
 and percentage_laid_off is null;
-- ---------------------------------COMPLETED--------------------------------deleting rows done-----------------------------


-- ********************************************************REMOVING ANY COLUMN**************************************************
select * from layoffs_staging2;
alter table layoffs_staging2
drop column row_num;
-- ---------------------COMPLETED----------------------deleting 'row_num' done------------------------------------------
