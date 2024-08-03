-- ******************************************************EXPLORATORY DATA ANALYSIS******************************************************************************
select *from layoffs_staging2;

-- displaying the max total laid off(no of people laid off at once from a particular company) and max percentage of the company being laid off-----------------
select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;

-- displaying the records which show the companies were totally laid off at once-------------------------------------------------------------------------------
select * 
from layoffs_staging2
where percentage_laid_off=1;

-- displaying the records which show the companies were totally laid off at once with the maximum employees laid off-------------------------------------------
select * 
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc;

-- displaying the companies which went down even after a lot of funding-----------------------------------------------------------------------------------------
select * 
from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc;

-- displaying the companies and their total laid off individually in descending order----------------------------------------------------------------------------
select company,sum(total_laid_off) as summ
from layoffs_staging2
group by company
order by summ desc;

-- to see the date when the laying off started and ended---------------------------------------------------------------------------------------------------------
select max(`date`),min(`date`)
from layoffs_staging2;

-- displaying which industry got the most laid offs---------------------------------------------------------------------------------------------------------------
select industry,sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- displaying the total laid off sbased upon country--------------------------------------------------------------------------------------------------------------
select country,sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- displaying the total laid offs based upon years-----------------------------------------------------------------------------------------------------------------
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- displaying the worst year in terms of laid off employees--------------------------------------------------------------------------------------------------------
select year(`date`),sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by 2 desc
limit 1;

-- displaying the total laid off in each stage of the company-------------------------------------------------------------------------------------------------------
select stage,sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- rolling total of the total laid off based upon month-------------------------------------------------------------------------------------------------------------
select substring(`date`,1,7) as `month`,sum(total_laid_off)
from  layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with Rolling_total as
(
select substring(`date`,1,7) as `month`,sum(total_laid_off) as total_off
from  layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`,total_off,sum(total_off) over(order by `month`) as rolling_total
from Rolling_total;

-- displaying the company name and the total laid off according to the years-----------------------------------------------------------------------------------------
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by company;

-- displaying the rank of the companies based upon the total laid off yearwise---------------------------------------------------------------------------------------
with Company_Year(company,years,total_laid_off) as
(
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
),
Company_Year_Rank as
(
select *,
dense_rank()over(partition by years order by total_laid_off desc)
as ranking
from Company_Year
where  years is not null
)
select *
from Company_Year_Rank;

-- displaying the top 5 companies every year based upon the total laid offs------------------------------------------------------------------------------------------
with Company_Year(company,years,total_laid_off) as
(
select company,year(`date`),sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
),
Company_Year_Rank as
(
select *,
dense_rank()over(partition by years order by total_laid_off desc)
as ranking
from Company_Year
where  years is not null
)
select *
from Company_Year_Rank
where ranking<=5;
