create database HRProject;

select * from hr;

-- ------------------ Data Cleaning -------------------------------------

alter table hr
change column ï»¿id EmployeeID varchar(20) null;

describe hr;

-- Format birthdate and hiredate values as per date datatype
update hr
set birthdate = (case
					when birthdate like '%/%'
					then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
                    when birthdate like '%-%'
					then date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
                    else null
				end);
                
update hr
set hire_date = (case
					when hire_date like '%/%'
					then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
                    when hire_date like '%-%'
					then date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
                    else null
				end);

-- change data type of birthdate and hiredate column to date
alter table hr
modify column birthdate date;

alter table hr
modify column hire_date date;

-- Update the values of termdate and change the data type
update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'));

alter table hr
modify column termdate date;

-- Adding age column

alter table hr
add column age int;

update hr
set age = timestampdiff(year, birthdate, curdate());

select birthdate,age
from hr;

-- check the records having age < 18 and exclude it from analysis

select min(age) as youngest, max(age) eldest from hr;

select count(*) from hr
where age < 18;

-- ----------------------------------------- Exploratory Data Analysis -------------------------------------------------

select * from hr where age > 18;

-- 1. What is the gender breakdown of employees in the company?

select gender, count(gender) as TotalCount
from hr
where age >= 18 and termdate = 0000-00-00
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

select race, count(race) as TotalCount
from hr
where age >= 18 and termdate = 0000-00-00
group by race
order by TotalCount Desc;

-- 3. What is the age distribution of employees in the company?

alter table hr
modify column EmployeeCategory varchar(30);

update hr
set EmployeeCategory = (
		case 
			when age > 18 and age <=35 then 'Young (18-35)'
			when age > 35 and age <=50 then 'Senior (35-50)'
			when age > 50 then  'Super Senior (>50)'
        end);


select EmployeeCategory
        ,count(EmployeeCategory) as AgeDistribution
from hr
where age >= 18 and termdate = 0000-00-00
group by EmployeeCategory
order by AgeDistribution Desc;

-- What is the age distribution of employees in the company?

select EmployeeCategory,gender,
        count(gender) as GenderDistribution
from hr
where age >= 18 and termdate = 0000-00-00
group by EmployeeCategory,gender
order by EmployeeCategory,GenderDistribution Desc;

-- 4. How many employees work at headquarters versus remote locations?

select location, count(location) as EmployeesAtLocation
from hr
where age >= 18 and termdate = 0000-00-00
group by location;

-- 5. What is the average length of employment for employees who have been terminated?

select round(avg((datediff(termdate,hire_date)/365)),2) as AvgEmpDurarion_Terminated
from hr
where termdate <> 0000-00-00 and termdate < date_format(now(),'%Y-%m-%d') and age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?

select department,jobtitle, gender,count(gender) as GenderDistribution
from hr
where age >= 18 and termdate = 0000-00-00
group by department,jobtitle, gender
order by department,jobtitle, gender;

-- 7. What is the distribution of job titles across the company?

select jobtitle, count(jobtitle) as JobDistribution
from hr
where age >= 18 and termdate = 0000-00-00
group by jobtitle
order by JobDistribution Desc;

-- 8. Which department has the highest turnover rate?

select department, round((Term_count*100.0/total_count),2) as Turnover_rate_Percent from
	(select department,  
    count(
			case 
				when termdate <> 0000-00-00 and termdate <= curdate() then 1
			end
		) as Term_Count,
	count(*) as total_count
	from hr
	where age >= 18 
	group by department
	order by Term_Count desc) as Term
group by department
order by Turnover_rate_Percent desc;

-- 9. What is the distribution of employees across locations by city and state?

select location_state, location_city, count(*) as EmpCount
from hr
where age >= 18 and termdate = 0000-00-00
group by location_state, location_city
order by location_state asc, EmpCount desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?

select Years, hires_per_year, terminated_per_year, hires_per_year-terminated_per_year as net_change,
round(((hires_per_year-terminated_per_year)/hires_per_year)*100,2) as net_change_percent 
from
	(select year(hire_date) as Years,
	count(hire_date) as hires_per_year,
	count(
		case
			when termdate <> '0000-00-00' and termdate <= curdate() then 1
		end
		) as terminated_per_year
	from hr
	where age >= 18
	group by year(hire_date)) as EmpChange
group by Years
order by Years;

-- 11. What is the tenure distribution for each department?

select department, 
		round(datediff(date_format(now(), '%Y-%m-%d'), hire_date)/365,2) as TenureDistributionInYears
from hr
where age > 18
group by department;