SELECT * FROM capstone.countries;
SELECT * FROM capstone.departments; 
SELECT * FROM capstone.employees;
SELECT * FROM capstone.jobs;

-- 1. Workforce Distribution
-- Count of employees in each department and rank departments by headcount.

SELECT d.department_id, d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM capstone.departments d
LEFT JOIN capstone.employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY employee_count DESC;

-- 2. Salary Comparison
-- Calculate average salary for each department.

SELECT d.department_id, d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM capstone.departments d
INNER JOIN capstone.employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;

-- Highest average salary
SELECT d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM capstone.departments d
INNER JOIN capstone.employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC
LIMIT 1;

-- Lowest average salary
SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM capstone.departments d
INNER JOIN capstone.employees e
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary ASC
LIMIT 1;

-- 3. Salary Bands for Employees
-- Classify employees based on their salary and count each category.

SELECT salary_band,
    COUNT(employee_id) AS employee_count
FROM (
    SELECT
        employee_id,
        CASE
            WHEN salary < 5000 THEN 'Low'
            WHEN salary BETWEEN 5000 AND 10000 THEN 'Medium'
            ELSE 'High'
        END AS salary_band
    FROM capstone.employees
) AS employee_bands
GROUP BY salary_band;

-- 4. Country-Level Analysis
-- Count distinct departments represented by employees in each country.

SELECT 	c.country_name, c.country_id,
COUNT(DISTINCT e.department_id) AS department_count
FROM capstone.countries c
INNER JOIN capstone.employees e
    ON c.country_id = e.country_id
GROUP BY
    c.country_id,
    c.country_name
ORDER BY department_count DESC;

-- 5. High Earners
-- Find employees earning more than the company-wide average salary.

SELECT
    employee_id,
    emp_name,
    salary
FROM capstone.employees
WHERE salary > (
    SELECT AVG(salary)
    FROM capstone.employees
)
ORDER BY salary DESC;

-- 6. Department Leaders
-- Retrieve department managers and count employees in each department.

SELECT
    d.department_id,
    d.department_name,
    m.emp_name AS manager_name,
    COUNT(e.employee_id) AS employee_count
FROM capstone.departments d
LEFT JOIN capstone.employees m
    ON d.manager_id = m.employee_id
LEFT JOIN capstone.employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name,
    m.employee_id,
    m.emp_name;
    
    -- 7. Job Role Analysis
-- Calculate average salary per job title and identify roles above 12000.

WITH job_salary AS (
    SELECT
        j.job_id,
        j.job_title,
        ROUND(AVG (e.salary), 0) AS average_salary
    FROM capstone.jobs j
    INNER JOIN capstone.employees e
        ON j.job_id = e.job_id
    GROUP BY
        j.job_id,
        j.job_title
)
SELECT
    job_id,
    job_title,
    average_salary
FROM job_salary
WHERE average_salary > 12000;

-- 8. Employee Ranking
-- Rank employees by salary within each department.

SELECT
    e.employee_id,
    e.emp_name,
    d.department_name,
    e.salary,
    ROW_NUMBER() OVER (
        PARTITION BY e.department_id
        ORDER BY e.salary DESC
    ) AS salary_rank
FROM capstone.employees e
INNER JOIN capstone.departments d
    ON e.department_id = d.department_id;
    
    -- 9. Salary Growth Trend
-- Calculate total employee salary cost for each country.

SELECT
    c.country_name,
    SUM(e.salary) AS total_salary_cost
FROM capstone.employees e
INNER JOIN capstone.countries c
    ON e.country_id = c.country_id
GROUP BY
    c.country_id,
    c.country_name, 
    e.salary
ORDER BY total_salary_cost DESC;

-- 10. Workforce Gaps
-- Find job roles that have no employees assigned.

SELECT
    j.job_id,
    j.job_title
FROM capstone.employees e
RIGHT JOIN capstone.jobs j
    ON e.job_id = j.job_id
WHERE e.employee_id IS NULL;
