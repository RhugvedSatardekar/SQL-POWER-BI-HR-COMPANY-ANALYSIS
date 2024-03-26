### HR Project 

---

#### Description
This README provides an overview and detailed description of the HR Project database schema and the SQL queries used for data cleaning, exploratory data analysis, and employee analysis. 

##### I have used MYSQL Database to perform Data cleaning and Exploratory Data Analysis. You can use Table Import Wizard to load the data into the database schema from "Human Resources Excel Workbook" added to this repository. 

---

#### Database Creation

```sql
CREATE DATABASE HRProject;
```
This SQL command creates a new database named HRProject.
Use Table import Wizard(R-click on schema name) to load the data into mysql workbench:
Kindly refer to this link: https://dev.mysql.com/doc/workbench/en/wb-admin-export-import-table.html

![image](https://github.com/RhugvedSatardekar/SQL-POWER-BI-HR-COMPANY-ANALYSIS/assets/163725285/649c9a56-e6be-4060-b6b9-0bc85ce9fe5d)


---

#### Data Cleaning

```sql
ALTER TABLE hr
CHANGE COLUMN ï»¿id EmployeeID VARCHAR(20) NULL;
```
This command changes the data type of the EmployeeID column to VARCHAR(20).

```sql
UPDATE hr
SET birthdate = (
	CASE
		WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
		WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
		ELSE NULL
	END
);
```
This query formats the birthdate values in the 'mm/dd/yyyy' or 'mm-dd-yyyy' format to 'yyyy-mm-dd'.

```sql
UPDATE hr
SET hire_date = (
	CASE
		WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
		WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
		ELSE NULL
	END
);
```
This query formats the hire_date values in the 'mm/dd/yyyy' or 'mm-dd-yyyy' format to 'yyyy-mm-dd'.

```sql
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;
```
These commands change the data type of the birthdate and hire_date columns to DATE.

```sql
UPDATE hr
SET termdate = DATE(STR_TO_DATE(termdate,'%Y-%m-%d %H:%i:%s UTC'));

ALTER TABLE hr
MODIFY COLUMN termdate DATE;
```
These commands update the termdate values and change the data type of the termdate column to DATE.

```sql
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
SET age = TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
```
These commands add an age column to the table and calculate the age of each employee based on their birthdate.

---

#### Exploratory Data Analysis

You can export the result of each query into .CSV format to prepare the dataset for further visualization in Power BI

![image](https://github.com/RhugvedSatardekar/SQL-POWER-BI-HR-COMPANY-ANALYSIS/assets/163725285/43fc825b-9335-445d-9c3e-30e887de5e59)


```sql
SELECT gender, COUNT(gender) AS TotalCount
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;
```
This query provides the gender breakdown of employees in the company.

```sql
SELECT race, COUNT(race) AS TotalCount
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY TotalCount DESC;
```
This query provides the race/ethnicity breakdown of employees in the company.

```sql
SELECT EmployeeCategory, COUNT(EmployeeCategory) AS AgeDistribution
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY EmployeeCategory
ORDER BY AgeDistribution DESC;
```
This query shows the age distribution of employees in the company based on age categories.

```sql
SELECT department, jobtitle, gender, COUNT(gender) AS GenderDistribution
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, GenderDistribution DESC;
```
This query shows how the gender distribution varies across departments and job titles.

---

#### Employee Analysis

```sql
SELECT location, COUNT(location) AS EmployeesAtLocation
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;
```
This query provides the number of employees working at headquarters versus remote locations.

```sql
SELECT ROUND(AVG((DATEDIFF(termdate,hire_date)/365)),2) AS AvgEmpDuration_Terminated
FROM hr
WHERE termdate <> '0000-00-00' AND termdate < DATE_FORMAT(NOW(),'%Y-%m-%d') AND age >= 18;
```
This query calculates the average length of employment for terminated employees.

```sql
SELECT department, ROUND(((Term_count*100.0)/total_count),2) AS Turnover_rate_Percent
FROM (
	SELECT department,  
		COUNT(
			CASE 
				WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1
			END
		) AS Term_Count,
		COUNT(*) AS total_count
	FROM hr
	WHERE age >= 18 
	GROUP BY department
) AS Term
GROUP BY department
ORDER BY Turnover_rate_Percent DESC;
```
This query identifies the department with the highest turnover rate.

```sql
SELECT location_state, location_city, COUNT(*) AS EmpCount
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state, location_city
ORDER BY location_state ASC, EmpCount DESC;
```
This query shows the distribution of employees across locations by city and state.

```sql
SELECT Years, hires_per_year, terminated_per_year, hires_per_year - terminated_per_year AS net_change,
ROUND(((hires_per_year - terminated_per_year)/hires_per_year)*100,2) AS net_change_percent 
FROM (
	SELECT YEAR(hire_date) AS Years,
		COUNT(hire_date) AS hires_per_year,
		COUNT(
			CASE
				WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1
			END
		) AS terminated_per_year
	FROM hr
	WHERE age >= 18
	GROUP BY YEAR(hire_date)
) AS EmpChange
GROUP BY Years
ORDER BY Years;
```
This query shows how the company's employee count has changed over time based on hire and term dates.

```sql
SELECT department, 
	ROUND(AVG(DATEDIFF(termdate,hire_date)/365),2) AS AvgTenure
FROM hr
WHERE age > 18 AND termdate <> '0000-00-00' AND termdate <= CURDATE()
GROUP BY department
ORDER BY AvgTenure DESC;
```
This query provides the tenure distribution for each department.

---


### SNAPSHOTS OF POWER-BI REPORT GENERATED USING DATASET OF EXPLORATORY DATA ANALYSIS

![image](https://github.com/RhugvedSatardekar/SQL-POWER-BI-HR-COMPANY-ANALYSIS/assets/163725285/81481ba5-df33-4f8e-af50-c79d0e19278c)

![image](https://github.com/RhugvedSatardekar/SQL-POWER-BI-HR-COMPANY-ANALYSIS/assets/163725285/84684df3-45a5-4425-afd3-92bdb300de9e)

