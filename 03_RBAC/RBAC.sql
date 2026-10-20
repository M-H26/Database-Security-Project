-- ahmed wael galal here 

USE DBSecurityProject;
GO

-- 1. Logins, users, roles
CREATE LOGIN user_reader   WITH PASSWORD = 'StrongPassword123!';
CREATE LOGIN user_inserter WITH PASSWORD = 'StrongPassword123!';
CREATE LOGIN user_power    WITH PASSWORD = 'StrongPassword123!';
GO
CREATE USER reader   FOR LOGIN user_reader;
CREATE USER inserter FOR LOGIN user_inserter;
CREATE USER poweru   FOR LOGIN user_power;
GO
CREATE ROLE read_onlyX;
CREATE ROLE insert_onlyX;
CREATE ROLE power_user;
GO

-- 2. Assign users to roles
ALTER ROLE read_onlyX   ADD MEMBER reader;
ALTER ROLE insert_onlyX ADD MEMBER inserter;
GO

-- 3. GRANT (least privilege)
GRANT SELECT ON dbo.Employees TO read_onlyX;
GRANT INSERT ON dbo.Employees TO insert_onlyX;
GO

-- 4. Test reader: SELECT works, INSERT fails
EXECUTE AS USER = 'reader';
SELECT * FROM dbo.Employees;                                    -- works
INSERT INTO dbo.Employees VALUES (99, 'Test', 50000);           -- FAILS (denied)
REVERT;
GO
SELECT USER_NAME() AS running_as;
-- 5. Test inserter: INSERT works, SELECT fails
EXECUTE AS USER = 'inserter';
INSERT INTO dbo.Employees VALUES (101, 'Test', 50000);           -- works
SELECT * FROM dbo.Employees;                                    -- FAILS (denied)
REVERT;
GO

-- 6. power_user inherits both roles
ALTER ROLE read_onlyX   ADD MEMBER power_user;
ALTER ROLE insert_onlyX ADD MEMBER power_user;
ALTER ROLE power_user   ADD MEMBER poweru;
GO

EXECUTE AS USER = 'poweru';
SELECT * FROM dbo.Employees;                                    -- works
INSERT INTO dbo.Employees VALUES (102, 'PowerTest', 60000);     -- works
DELETE FROM dbo.Employees WHERE EmpID = 100;                    -- FAILS (denied)
REVERT;
GO

-- 7. Remove one role from power_user
ALTER ROLE insert_onlyX DROP MEMBER power_user;
GO

EXECUTE AS USER = 'poweru';
SELECT * FROM dbo.Employees;                                    -- still works
INSERT INTO dbo.Employees VALUES (101, 'PowerTest2', 60000);    -- FAILS (denied)
REVERT;
GO

-- 8. REVOKE demo
REVOKE SELECT ON dbo.Employees FROM read_onlyX;
GO

EXECUTE AS USER = 'reader';
SELECT * FROM dbo.Employees;                                    -- FAILS (denied)
REVERT;
GO

-- 9. Clean up test rows
DELETE FROM dbo.Employees WHERE EmpID IN (99, 100, 101);
GO