-- ============================================================================
-- 04. PART 4:  AGGREGATE INFERENCE + INTEGRATION (Mahmoud Gad)
-- ============================================================================

USE DBSecurityProject;
GO

-- 1. Create a view to calculate count and average salary for all employees (including target Ahmed)
CREATE OR ALTER VIEW dbo.v_Avg_All AS
SELECT 
    COUNT(*) AS N_all,
    AVG(Salary) AS A_avg_all
FROM dbo.Employees;
GO

-- 2. Create a second view to calculate count and average salary excluding the target Ahmed (EmpID = 6)
CREATE OR ALTER VIEW dbo.v_Avg_Excl_Target AS
SELECT 
    COUNT(*) AS N_excl,
    AVG(Salary) AS B_avg_excl
FROM dbo.Employees
WHERE EmpID <> 6;
GO

-- 3. Grant SELECT permissions on both views to public_role
GRANT SELECT ON dbo.v_Avg_All TO public_role;
GRANT SELECT ON dbo.v_Avg_Excl_Target TO public_role;
GO

-- 4. Execute the Inference Attack as the normal user ('general')
EXECUTE AS USER = 'general';

SELECT 
    a.N_all,
    a.A_avg_all AS Avg_All_6,
    b.N_excl,
    b.B_avg_excl AS Avg_Without_Ahmed_5,
    (a.N_all * a.A_avg_all) AS Total_Salary_All_6,
    (b.N_excl * b.B_avg_excl) AS Total_Salary_5,
    (a.N_all * a.A_avg_all) - (b.N_excl * b.B_avg_excl) AS Inferred_Ahmed_Salary
FROM dbo.v_Avg_All a
CROSS JOIN dbo.v_Avg_Excl_Target b;

REVERT;
GO

-- 5. Test K-Anonymity on small groups (e.g., group of 3 employees) -> BLOCKED by k=4
SELECT 
    COUNT(*) AS GroupSize,
    AVG(Salary) AS AvgSalary
FROM dbo.Employees
WHERE EmpID <= 3
HAVING COUNT(*) >= 4;
GO

-- 6. Apply K-Anonymity (k=4) check to the views (Note: Fails to stop the 6 vs 5 aggregate attack)
CREATE OR ALTER VIEW dbo.v_Avg_All AS
SELECT 
    COUNT(*) AS N_all,
    AVG(Salary) AS A_avg_all
FROM dbo.Employees
HAVING COUNT(*) >= 4;
GO

CREATE OR ALTER VIEW dbo.v_Avg_Excl_Target AS
SELECT 
    COUNT(*) AS N_excl,
    AVG(Salary) AS B_avg_excl
FROM dbo.Employees
WHERE EmpID <> 6
HAVING COUNT(*) >= 4;
GO

-- 7. Revoke old view permissions and drop them to secure the database properly
REVOKE SELECT ON dbo.v_Avg_All FROM public_role;
REVOKE SELECT ON dbo.v_Avg_Excl_Target FROM public_role;
DROP VIEW dbo.v_Avg_All;
DROP VIEW dbo.v_Avg_Excl_Target;
GO

-- 8. Create an Audit Log table to track user queries and prevent overlapping/leave-one-out attacks
CREATE TABLE dbo.AggregateQueryLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    QueriedGroupSize INT NOT NULL,
    ExcludedEmpID INT NULL,
    QueryTime DATETIME2 DEFAULT SYSDATETIME()
);
GO

-- 9. Create a secure Stored Procedure implementing K-Anonymity (k=4) and Overlap Control
CREATE OR ALTER PROCEDURE dbo.sp_GetProtectedSalaryAvg
    @MaxEmpID INT = NULL,        -- Optional parameter to filter group size
    @ExcludeEmpID INT = NULL     -- Optional parameter to exclude a target employee
WITH EXECUTE AS OWNER            -- Executes with table owner permissions to read Employees and write to Log
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentUser NVARCHAR(100) = USER_NAME();
    DECLARE @GroupSize INT;
    DECLARE @AvgSalary DECIMAL(10,2);

    -- Calculate group size and average for the requested query
    SELECT 
        @GroupSize = COUNT(*),
        @AvgSalary = AVG(Salary)
    FROM dbo.Employees
    WHERE (@MaxEmpID IS NULL OR EmpID <= @MaxEmpID)
      AND (@ExcludeEmpID IS NULL OR EmpID <> @ExcludeEmpID);

    -- Defense Line 1: Check K-Anonymity threshold (k = 4)
    IF @GroupSize < 4
    BEGIN
        RAISERROR('SECURITY BLOCK [K-Anonymity]: Query rejected because group size (%d) is smaller than minimum threshold k = 4.', 16, 1, @GroupSize);
        RETURN;
    END

    -- Defense Line 2: Check Overlap / Leave-One-Out attack using the Audit Log history
    IF EXISTS (
        SELECT 1 
        FROM dbo.AggregateQueryLog
        WHERE UserName = @CurrentUser
          AND (
              ABS(QueriedGroupSize - @GroupSize) = 1
              OR (ExcludedEmpID IS NOT NULL AND @ExcludeEmpID IS NOT NULL AND ExcludedEmpID <> @ExcludeEmpID)
          )
    )
    BEGIN
        RAISERROR('SECURITY BLOCK [Overlap Control]: Query rejected! Overlapping / Leave-One-Out query detected against your previous query history.', 16, 1);
        RETURN;
    END

    -- If valid, log the query and return the safe average result
    INSERT INTO dbo.AggregateQueryLog (UserName, QueriedGroupSize, ExcludedEmpID)
    VALUES (@CurrentUser, @GroupSize, @ExcludeEmpID);

    SELECT 
        @GroupSize AS Safe_Group_Size,
        @AvgSalary AS Safe_Average_Salary;
END;
GO

-- Grant execute permission on the secure procedure to public_role
GRANT EXECUTE ON dbo.sp_GetProtectedSalaryAvg TO public_role;
GO

-- 10. Final Retest and Evidence Validation as normal user ('general')
EXECUTE AS USER = 'general';

-- Test 1: Try querying a small group of 3 employees -> Expected: BLOCKED by K-Anonymity
EXEC dbo.sp_GetProtectedSalaryAvg @MaxEmpID = 3;

-- Test 2: First valid query for all 6 employees -> Expected: SUCCESS (returns average 95,000)
EXEC dbo.sp_GetProtectedSalaryAvg;

-- Test 3: Attempt second query excluding Ahmed (EmpID = 6) -> Expected: BLOCKED by Overlap Control
EXEC dbo.sp_GetProtectedSalaryAvg @ExcludeEmpID = 6;

-- Test 4: Attempt querying excluding another employee -> Expected: BLOCKED by Overlap Control
EXEC dbo.sp_GetProtectedSalaryAvg @ExcludeEmpID = 5;

REVERT;
GO

-- View the Audit Log records for oral discussion proof
SELECT * FROM dbo.AggregateQueryLog;
GO