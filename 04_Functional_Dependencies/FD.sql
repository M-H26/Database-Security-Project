SELECT USER_NAME() AS running_as;
--ENG. Mohamed Hamouda 
USE DBSecurityProject;
-- 1) Tables creation
-- FD2: Title -> Grade
CREATE TABLE dbo.TitleGrade (                       
    Title VARCHAR(30) PRIMARY KEY,
    Grade VARCHAR(10) NOT NULL
);

INSERT INTO dbo.TitleGrade (Title, Grade) VALUES
('Professor','Lead'),
('Associate Professor','Senior'),
('Assistant Professor','Junior'),
('Engineer I','Junior'),
('Engineer II','Senior'),
('Engineer Lead','Lead');

-- FD3: Dept, Grade -> Bonus
CREATE TABLE dbo.BonusMatrix (
    Dept  VARCHAR(20) NOT NULL,
    Grade VARCHAR(10) NOT NULL,
    Bonus INT NOT NULL,
    CONSTRAINT PK_BonusMatrix PRIMARY KEY (Dept, Grade)
);

INSERT INTO dbo.BonusMatrix (Dept, Grade, Bonus) VALUES
('CS','Junior', 8000), ('CS','Senior',12000), ('CS','Lead',15000),
('IT','Junior', 6000), ('IT','Senior',10000), ('IT','Lead',13000);

-- FD1: EmpID -> Dept
CREATE TABLE dbo.Employee (    
    EmpID INT PRIMARY KEY,
    Dept  VARCHAR(20) NOT NULL,
    Title VARCHAR(30) NOT NULL,
    Bonus INT NOT NULL,
    CONSTRAINT FK_E_Title FOREIGN KEY (Title) REFERENCES dbo.TitleGrade(Title)
);

INSERT INTO dbo.Employee (EmpID, Dept, Title, Bonus) VALUES
(1,'CS','Professor',15000),
(2,'CS','Associate Professor',12000),
(3,'CS','Assistant Professor',8000),
(4,'IT','Engineer I',6000),
(5,'IT','Engineer II',10000),
(6,'IT','Engineer Lead',13000);
GO

-- 2) Proving that bonus can be inferred from {Dept, Tittle}
SELECT e.Dept, e.Title, t.Grade, b.Bonus AS inferred_bonus
FROM dbo.Employee e
JOIN dbo.TitleGrade  t ON t.Title = e.Title                      -- FD2
JOIN dbo.BonusMatrix b ON b.Dept = e.Dept AND b.Grade = t.Grade  -- FD3
ORDER BY e.Dept, e.Title;
-- Inference Validation: confirms Bonus derived via FD2 + FD3 matches the stored Bonus.
-- Expected result: 0 rows (inference is exact, so Bonus ∈ Q⁺ holds on this data).
SELECT e.EmpID
FROM dbo.Employee e
JOIN dbo.TitleGrade  t ON t.Title = e.Title
JOIN dbo.BonusMatrix b ON b.Dept = e.Dept AND b.Grade = t.Grade
WHERE b.Bonus <> e.Bonus;
GO

-- 3) Logins
CREATE LOGIN student_login1
    WITH PASSWORD = '1',
         DEFAULT_DATABASE = DBSecurityProject;
GO
CREATE USER student_user FOR LOGIN student_login1;
CREATE ROLE student_role;
ALTER ROLE student_role ADD MEMBER student_user;
GO

-- 4) Safe Views
-- v_employee_safe: no Title, no Bonus  -> Q = {Dept, Title} can't be formed                                         
CREATE VIEW dbo.v_employee_safe AS
SELECT EmpID, Dept FROM dbo.Employee;
GO
-- v_safe: Dept + count only 
CREATE VIEW dbo.v_safe AS
SELECT Dept, COUNT(*) AS n
FROM dbo.Employee
GROUP BY Dept;
GO

-- 5) Premissions
DENY SELECT ON OBJECT::dbo.Employee    TO student_role;
DENY SELECT ON OBJECT::dbo.TitleGrade  TO student_role;
DENY SELECT ON OBJECT::dbo.BonusMatrix TO student_role;

GRANT SELECT ON OBJECT::dbo.v_employee_safe TO student_role;
GRANT SELECT ON OBJECT::dbo.v_safe          TO student_role;
GO

-- 6) Final testing
EXECUTE AS USER = 'student_user';
SELECT USER_NAME() AS running_as;

SELECT * FROM dbo.v_safe;             -- works
SELECT * FROM dbo.v_employee_safe;    -- works (EmpID, Dept only)

-- Each of the following must FAIL
SELECT Bonus FROM dbo.Employee;
SELECT Dept, Title FROM dbo.Employee;   -- the rejected query (Q = {Dept, Title})
SELECT * FROM dbo.TitleGrade;
SELECT * FROM dbo.BonusMatrix;

REVERT;
SELECT USER_NAME() AS running_as;     -- back to dbo
EXECUTE AS USER = 'dbo' ;