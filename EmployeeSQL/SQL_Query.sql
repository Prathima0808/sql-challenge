-- Data Engineering

--creating Tables.


-- Creating Titles Table & importing CSV File.
CREATE TABLE titles 
(
	title_id VARCHAR PRIMARY KEY,
	title VARCHAR
);

select * from titles;
-- creating employee table & formatting Date(dd/mm/yyyy)
-- Use an intermediate load table to get the data in
-- Notice how both date fields are created as VARCHAR here
DROP TABLE IF EXISTS employees_load;
CREATE TABLE employees_load (
    emp_no INT   NOT NULL,
    emp_title_id VARCHAR NOT NULL,
    birth_date_text VARCHAR   NOT NULL,
    first_name VARCHAR   NOT NULL,
    last_name VARCHAR   NOT NULL,
    sex VARCHAR   NOT NULL,
    hire_date_text VARCHAR   NOT NULL,
    PRIMARY KEY (emp_no)
	FOREIGN KEY(emp_title_id) REFERENCES titles(title_id)

);
-- Now import into the intermediate table

SELECT * FROM employees_load;
-- Finally, insert into 
INSERT INTO employees
SELECT 
 emp_no
,emp_title_id
-- Use to_date() to convert text to date
,to_date(birth_date_text, 'MM/DD/YYYY') as birth_date
,first_name
,last_name
,sex
-- Use to_date() to convert text to date
,to_date(hire_date_text, 'MM/DD/YYYY') as hire_date
FROM employees_load
WHERE emp_no NOT IN
  (SELECT emp_no FROM employees)
;
-- Check data has loaded
SELECT * FROM employees;

--createing departmentsts &import CSV file
CREATE TABLE departments
(	
	dept_no VARCHAR PRIMARY KEY,
	dept_name VARCHAR
);

SELECT * FROM departments;

--creating dept_manager table & importing CSV file

CREATE TABLE dept_manager
(
	dept_no VARCHAR,
	emp_no INT,
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	PRIMARY KEY (dept_no, emp_no)

);

SELECT * FROM dept_manager;

--creating dept_emp table & import CSV file

CREATE TABLE dept_emp
(
	emp_no INT,	
	dept_no VARCHAR,
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	PRIMARY KEY (emp_no, dept_no)
	

);

SELECT * FROM dept_emp;

--creating salaries table and import dept_emp CSV file.

CREATE TABLE salaries
(
	emp_no INT PRIMARY KEY,
	salary INT,
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no)
	
);

SELECT * FROM salaries;

-- Data Analysis

--1.List the employee number, last name, first name, sex, and salary of each employee.

SELECT employees.emp_no, first_name, last_name, sex, salary
FROM employees
INNER JOIN salaries
ON employees.emp_no = salaries.emp_no
ORDER BY employees.emp_no;

--2.List the first name, last name, and hire date for the employees who were hired in 1986.

SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31';

--3.List the manager of each department along with their department number, department name, employee number, last name, and first name.
select * from dept_manager;
SELECT departments.dept_no,dept_manager.dept_no,dept_manager.emp_no, dept_name, employees.emp_no, first_name, last_name
FROM dept_manager
INNER JOIN departments
ON departments.dept_no = dept_manager.dept_no
INNER JOIN employees
ON employees.emp_no = dept_manager.emp_no;

--4.List the department number for each employee along with that employee’s employee number, last name, first name, and department name.

SELECT employees.emp_no, last_name, first_name, departments.dept_name
FROM employees
INNER JOIN dept_emp
ON employees.emp_no = dept_emp.emp_no
INNER JOIN departments
ON departments.dept_no = dept_emp.dept_no;



--5.List first name, last name, and sex of each employee whose first name is Hercules and whose last name begins with the letter B.

SELECT first_name, last_name, sex
FROM employees
WHERE first_name = 'Hercules'
AND last_name LIKE 'B%';


--6.List each employee in the Sales department, including their employee number, last name, and first name.

SELECT employees.emp_no, last_name, first_name, departments.dept_name
FROM employees
INNER JOIN dept_emp
ON employees.emp_no = dept_emp.emp_no
INNER JOIN departments
ON departments.dept_no = dept_emp.dept_no
WHERE departments.dept_name = 'Sales'


--7.List each employee in the Sales and Development departments, including their employee number, last name, first name, and department name.

SELECT employees.emp_no, first_name, last_name, dept_name
FROM employees
INNER JOIN dept_emp
ON employees.emp_no = dept_emp.emp_no
INNER JOIN departments
ON departments.dept_no = dept_emp.dept_no
WHERE departments.dept_name IN ('Sales', 'Development');


--8.List the frequency counts, in descending order, of all the employee last names (that is, how many employees share each last name).

SELECT last_name, COUNT(last_name) AS "Last Name Count"
FROM employees
GROUP BY last_name
ORDER BY "Last Name Count" DESC;
