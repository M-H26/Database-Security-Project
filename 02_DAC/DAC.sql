-- Marwan Alaa Sadek 

USE DBSecurityProject;
GO

--------------------------------------------------------------------------------
-- 1. creating Logins و Users و Roles 
--------------------------------------------------------------------------------
CREATE LOGIN user_public WITH PASSWORD = 'StrongPassword123!';
CREATE LOGIN user_admin WITH PASSWORD = 'StrongPassword123!';
GO

CREATE USER general FOR LOGIN user_public;
CREATE USER admin1 FOR LOGIN user_admin;
GO

CREATE ROLE public_role;
CREATE ROLE admin_role;
GO

ALTER ROLE public_role ADD MEMBER general;
ALTER ROLE admin_role ADD MEMBER admin1;
GO

--------------------------------------------------------------------------------
-- 2.  ( giving roles and save viewing etc)
--------------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Employees TO admin_role;
GO

CREATE VIEW dbo.v_Employees_Public AS
SELECT EmpID, FullName
FROM dbo.Employees;
GO

GRANT SELECT ON dbo.v_Employees_Public TO public_role;
GO

--------------------------------------------------------------------------------
-- 3.  (Testing)
--------------------------------------------------------------------------------
--  testing to see if the normal employee can open (Permission Denied)
EXECUTE AS USER = 'general';
SELECT * FROM dbo.Employees; 
REVERT;
GO

-- testing if he can open it without seeing the salaries 
EXECUTE AS USER = 'general';
SELECT * FROM dbo.v_Employees_Public; 
REVERT;
GO

--  (   the admin can accesss everthing )
EXECUTE AS USER = 'admin1';
SELECT * FROM dbo.Employees; 
REVERT;
GO


-- 4. (attack Scenario - Ownership Chaining)

CREATE TABLE dbo.OfficeLocations (
    EmpID INT PRIMARY KEY,
    Location VARCHAR(50)
);
INSERT INTO dbo.OfficeLocations (EmpID, Location) VALUES
(1, 'Cairo'), (2, 'Alex'), (3, 'Giza'), (4, 'Cairo'), (5, 'Alex'), (6, 'Giza');
GO

CREATE VIEW dbo.v_LeakyReport AS
SELECT e.EmpID, e.FullName, e.Salary, o.Location
FROM dbo.Employees e
JOIN dbo.OfficeLocations o ON e.EmpID = o.EmpID;
GO

GRANT SELECT ON dbo.v_LeakyReport TO PUBLIC;
GO

--  (starting the attack as a normal user to leak the info )
EXECUTE AS USER = 'general';
SELECT * FROM dbo.v_LeakyReport; 
REVERT;
GO

--------------------------------------------------------------------------------
-- 5. (The Fix for the leak )
--------------------------------------------------------------------------------
REVOKE SELECT ON dbo.v_LeakyReport FROM PUBLIC;
GO

DROP VIEW dbo.v_LeakyReport;
GO

--  retesting the normal user to see if the leak stopped
EXECUTE AS USER = 'general';
REVERT;
GO