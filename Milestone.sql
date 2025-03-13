create database Milestone; 
use Milestone;

CREATE TABLE salary_data (
    age_range VARCHAR(100),
    industry VARCHAR(255),
    job_title VARCHAR(255),
    annual_salary INT,
    annual_salary_usd INT,
    additional_monetary_compensation DECIMAL(10,2) NULL,
    additional_monetary_compensation_usd INT,
    currency VARCHAR(10),
    other_currency VARCHAR(50),
    income_clarification TEXT,
    country VARCHAR(255),
    state VARCHAR(255),
    city VARCHAR(255),
    experience_overall VARCHAR(100),
    experience_field VARCHAR(100),
    education_level VARCHAR(100),
    gender VARCHAR(100)
);

LOAD DATA LOCAL INFILE 'C:\\Users\\manik\\Desktop\\Milestone.csv'
INTO TABLE salary_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# 1. average salary by industry and gender
select industry, gender, avg(annual_salary) as avg_salary
from salary_data
where annual_salary is not null
group by industry, gender
order by industry, gender;

# 2. total salary compensation by job title
select job_title, 
       sum(annual_salary + coalesce(additional_monetary_compensation, 0)) as total_compensation
from salary_data
group by job_title
order by total_compensation desc;

# 3. salary distribution by education level
select education_level, 
       min(annual_salary) as min_salary, 
       max(annual_salary) as max_salary, 
       avg(annual_salary) as avg_salary
from salary_data
group by education_level
order by avg_salary desc;

# 4. number of employees by industry and years of experience
select industry, experience_overall, count(*) as employee_count
from salary_data
group by industry, experience_overall
order by industry, experience_overall;

# 5. median salary by age range and gender
select age_range, gender, 
       avg(annual_salary) as median_salary
from (
    select age_range, gender, annual_salary,
           row_number() over (partition by age_range, gender order by annual_salary) as row_num,
           count(*) over (partition by age_range, gender) as total_rows
    from salary_data
) ranked
where row_num in (total_rows div 2, (total_rows div 2) + 1)  -- Handles both odd and even cases
group by age_range, gender;

# 6. job titles with the highest salary in each country
select country, job_title, max(annual_salary) as highest_salary
from salary_data
group by country, job_title
order by country, highest_salary desc;

# 7. average salary by city and industry
select city, industry, avg(annual_salary) as avg_salary
from salary_data
group by city, industry
order by city, avg_salary desc;

# 8. percentage of employees with additional monetary compensation by gender
select gender, 
       count(case when additional_monetary_compensation > 0 then 1 end) * 100.0 / count(*) as percentage_with_bonus
from salary_data
group by gender;

# 9. total compensation by job title and years of experience
select job_title, experience_overall, 
       sum(annual_salary + coalesce(additional_monetary_compensation, 0)) as total_compensation
from salary_data
group by job_title, experience_overall
order by total_compensation desc;

# 10. average salary by industry, gender, and education level
select industry, gender, education_level, avg(annual_salary) as avg_salary
from salary_data
group by industry, gender, education_level
order by industry, gender, avg_salary desc;



