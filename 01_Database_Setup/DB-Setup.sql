-- 1. Create the database
CREATE DATABASE DBSecurityProject;
GO

USE DBSecurityProject;
GO

-- 2. Original Employees table from the assignment
CREATE TABLE dbo.Employees (
    EmpID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL
);
GO

-- 3. Insert the original assignment data
INSERT INTO dbo.Employees (EmpID, FullName, Salary)
VALUES
(1, 'Ali',   120000),
(2, 'Asser', 110000),
(3, 'Mona',  100000),
(4, 'Fatma',  90000),
(5, 'Gehad',  80000),
(6, 'Ahmed',  70000);
GO

-- 4. Hypothetical table for Functional Dependency Inference
CREATE TABLE dbo.EmployeeFD (
    EmpID INT PRIMARY KEY,
    Dept VARCHAR(50) NOT NULL,
    Title VARCHAR(50) NOT NULL,
    Grade INT NOT NULL,
    Bonus DECIMAL(10,2) NOT NULL
);
GO

-- 5. Insert sample data satisfying the given FDs
INSERT INTO dbo.EmployeeFD (EmpID, Dept, Title, Grade, Bonus)
VALUES
(1, 'IT', 'Manager', 5, 20000),
(2, 'IT', 'Analyst', 3, 10000),
(3, 'HR', 'Manager', 5, 20000),
(4, 'HR', 'Analyst', 3, 10000),
(5, 'IT', 'Developer', 4, 15000),
(6, 'HR', 'Developer', 4, 15000);
GO

-- 6. Verify the data
SELECT * FROM dbo.Employees;
SELECT * FROM dbo.EmployeeFD;
GO
