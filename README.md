# Database Security Project — SQL Server

A practical database security project implementing **Discretionary Access Control (DAC), Role-Based Access Control (RBAC), Functional Dependency Inference, and Aggregate Inference Protection** using Microsoft SQL Server and T-SQL.

The project demonstrates how database permissions, roles, views, and inference-control techniques can protect sensitive information while allowing authorized users to perform their assigned operations.

## Project Objectives

- Implement DAC using database users, roles, permissions, and views.
- Apply RBAC and the principle of least privilege.
- Demonstrate indirect access to restricted information and mitigate unauthorized access.
- Analyze functional dependencies to identify potential inference attacks.
- Demonstrate statistical inference attacks using aggregate queries.
- Apply K-anonymity-based restrictions and evaluate their effectiveness.
- Validate security controls through SQL queries and access-control scenarios.

## Technologies Used

- **Database:** Microsoft SQL Server
- **Query Language:** T-SQL
- **Database Management:** SQL Server Management Studio (SSMS)
- **Version Control:** Git and GitHub

## Project Structure

```text
Database-Security-Project/
│
├── 01_Database_Setup/
│   └── Database and table creation scripts
│
├── 02_DAC/
│   └── DAC users, roles, permissions, and views
│
├── 03_RBAC/
│   └── Role creation, membership, and permission queries
│
├── 04_Functional_Dependencies/
│   └── Functional dependency inference and protection
│
├── 05_Aggregate_Inference/
│   └── Statistical inference attacks and protection
│
├── docs/
│   └── Project documentation
│
├── .gitignore
└── README.md
```

*The directory names above describe the project organization. Adjust them to match the actual folders and filenames in the repository.*

## Project Implementation

### 1. Discretionary Access Control (DAC)

This part demonstrates how access can be granted or restricted for individual database users and roles.

**Key concepts:**
- Database users and role-based permission assignment.
- Separate access levels for general users and administrators.
- Restricted views that expose anonymized or limited information.
- Administrative access to authorized data.
- Demonstrating indirect access through views or inherited permissions and applying corrective permissions.

**Security objective:** Ensure users can access only the information and operations permitted by their assigned privileges.

### 2. Role-Based Access Control (RBAC)

This part organizes permissions into roles rather than assigning every permission individually to each user.

**Roles demonstrated:**
- `read_onlyX` — read access to permitted data.
- `insert_onlyX` — insertion privileges without automatically granting unrelated permissions.
- `power_user` — combines the required role memberships to demonstrate cumulative privileges.

**Key concepts:**
- Verify permitted `SELECT` and `INSERT` operations.
- Apply `GRANT` and `REVOKE` to modify permissions.
- Demonstrate how changing role membership affects effective privileges.
- Enforce the principle of least privilege.

**Security objective:** Simplify permission management while restricting users to their authorized operations.

### 3. Functional Dependency Inference

This part examines how relationships between attributes can reveal sensitive information indirectly.

The demonstration uses the following functional dependencies:

| Functional Dependency | Meaning |
|---|---|
| `EmpID → Dept` | An employee ID determines the employee's department. |
| `Title → Grade` | A job title determines its grade. |
| `(Dept, Grade) → Bonus` | The department and grade together determine the bonus. |

Given the initial attribute set:

\[
Q=\{Dept,Title\}
\]

The attribute closure is calculated by applying the dependencies:

1. Start with `{Dept, Title}`.
2. Apply `Title → Grade` to add `Grade`.
3. Apply `(Dept, Grade) → Bonus` to add `Bonus`.

Therefore:

\[
Q^+=\{Dept,Title,Grade,Bonus\}
\]

Since `Bonus` belongs to \(Q^+\), it can be inferred from the initial attributes under the specified dependencies.

**Security implementation:**
- Represent the functional dependencies using a practical SQL Server dataset.
- Demonstrate the inference using SQL queries.
- Evaluate whether an unsafe query should be rejected or transformed.
- Apply and evaluate the selected protection strategy.

**Security objective:** Prevent sensitive attributes from being inferred through otherwise permitted queries.

### 4. Aggregate Inference Protection

This part demonstrates how statistical queries can expose individual information even when direct access to underlying records is restricted.

**Key concepts:**
- Aggregate queries using `AVG` and `COUNT`.
- Comparing aggregate results for overlapping groups.
- Demonstrating how an individual's salary can be inferred from averages.
- Applying K-anonymity-based restrictions to small groups.
- Evaluating the effectiveness of the applied protection.

For a group containing \(n\) employees, let \(A\) be the group's average salary and \(B\) the average salary of the other \(n-1\) employees. The excluded employee's salary can be inferred using:

\[
Salary_{\text{target}}=nA-(n-1)B
\]

This illustrates why aggregate access alone does not guarantee privacy.

**Security objective:** Reduce the risk of disclosing individual information through statistical queries.

> **Note:** K-anonymity thresholds alone do not prevent every aggregate inference attack. Overlapping queries and differencing attacks may still reveal sensitive values, so protection must be evaluated against the specific attack scenario.

## Database Design

The project uses separate tables for different demonstrations.

| Table | Purpose |
|---|---|
| `dbo.Employees` | Employee records used for access-control and salary-related demonstrations. |
| `dbo.EmployeeFD` | Functional dependency demonstration involving employee IDs, departments, job titles, grades, and bonuses. |
| `dbo.Grades` | Grade records used for restricted aggregate-query demonstrations. |

The functional dependency demonstration uses a separate table because its required attributes differ from those of the original employee salary dataset.

## How to Run the Project

### Prerequisites

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- Appropriate permissions to create databases, users, roles, tables, and views

### Execution Steps

1. Clone or download this repository.
2. Open SQL Server Management Studio and connect to your SQL Server instance.
3. Execute the scripts in `01_Database_Setup/` to create the project database and required tables.
4. Execute the scripts in `02_DAC/` to configure DAC users, roles, permissions, and views.
5. Execute the scripts in `03_RBAC/` to configure roles and permissions.
6. Execute the scripts in `04_Functional_Dependencies/` to demonstrate inference and the selected protection strategy.
7. Execute the scripts in `05_Aggregate_Inference/` to reproduce the aggregate inference scenario and apply the protection.

**Execution notes:**
- Follow the execution order when scripts depend on objects created by earlier scripts.
- Use an authorized administrative connection for database setup and security configuration.
- Review scripts before execution, especially those that create logins or change permissions.

## Key Security Concepts

- Discretionary Access Control (DAC)
- Role-Based Access Control (RBAC)
- Principle of Least Privilege
- SQL Server `GRANT`, `REVOKE`, and `DENY`
- Database roles and role membership
- Views and indirect access
- Functional dependencies and attribute closure
- Statistical inference and differencing attacks
- K-anonymity-based query restrictions

## Learning Outcomes

Through this project, we explored how to:

- Design database permissions around user responsibilities.
- Separate administrative privileges from general access.
- Understand effective database permissions and role membership.
- Identify information leakage caused by attribute relationships.
- Understand why aggregate queries can reveal individual records.
- Apply and evaluate practical database inference controls.
- Organize SQL Server security scripts into a collaborative GitHub repository.

## Contributors

- **Mohamed Hany Hamouda**
- **Mahmoud Gad**
- **Marwan Alaa Sadek**
- **Ahmed Wael**

## Disclaimer

This project was developed for educational purposes. The implemented controls demonstrate selected database security scenarios and should not be interpreted as a complete production security architecture.

## Author

**ENG. Mohamed Hany Hamouda**

Computer Science Student — Data Science Major

- GitHub: [M-H26](https://github.com/M-H26)

