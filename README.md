# Database Security Project

## Overview

A practical SQL Server project demonstrating access control and inference control techniques to protect sensitive data.

## Objectives

- Implement Discretionary Access Control (DAC).
- Implement Role-Based Access Control (RBAC).
- Apply the principle of least privilege.
- Demonstrate indirect access vulnerabilities and their fixes.
- Analyze functional dependencies and inference risks.
- Demonstrate aggregate inference attacks.
- Apply K-anonymity-based protection.

## Technologies

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Transact-SQL (T-SQL)
- Git and GitHub

## Project Structure

- `01_Database_Setup/` - Database setup and sample data
- `02_DAC/` - DAC roles, permissions, and attack scenarios
- `03_RBAC/` - RBAC roles, permissions, and inheritance
- `04_Functional_Dependencies/` - Attribute closure and inference analysis
- `05_Aggregate_Inference/` - Aggregate attacks and K-anonymity
- `06_Test_Results/` - Test evidence and screenshots
- `docs/` - Report and presentation

## Team Workflow

1. Each team member works on assigned SQL scripts.
2. Changes are committed and pushed to GitHub.
3. Team members pull updates before integration.
4. Scripts are reviewed and executed in the agreed order.
5. Test results are documented.

## Security Notes

- Never commit passwords or sensitive credentials.
- Use separate accounts to test different privileges.
- Execute scripts only against the intended development database.
- Review destructive statements and permission changes before execution.

## Status

In progress.
