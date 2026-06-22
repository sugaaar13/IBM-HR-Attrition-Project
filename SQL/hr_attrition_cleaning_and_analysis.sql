-- STEP 0: SANITY CHECK
SELECT
    COUNT(*)                       AS total_rows,
    COUNT(DISTINCT EmployeeNumber) AS unique_employees
FROM dbo.HR_Att;


-- STEP 1: NULL CHECK
SELECT
    SUM(CASE WHEN EmployeeNumber            IS NULL THEN 1 ELSE 0 END) AS null_employee_number,
    SUM(CASE WHEN Age                       IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN Department                IS NULL THEN 1 ELSE 0 END) AS null_department,
    SUM(CASE WHEN JobRole                   IS NULL THEN 1 ELSE 0 END) AS null_job_role,
    SUM(CASE WHEN MonthlyIncome             IS NULL THEN 1 ELSE 0 END) AS null_monthly_income,
    SUM(CASE WHEN Attrition                 IS NULL THEN 1 ELSE 0 END) AS null_attrition,
    SUM(CASE WHEN OverTime                  IS NULL THEN 1 ELSE 0 END) AS null_overtime,
    SUM(CASE WHEN JobSatisfaction           IS NULL THEN 1 ELSE 0 END) AS null_job_satisfaction,
    SUM(CASE WHEN WorkLifeBalance           IS NULL THEN 1 ELSE 0 END) AS null_work_life_balance,
    SUM(CASE WHEN YearsAtCompany            IS NULL THEN 1 ELSE 0 END) AS null_years_at_company,
    SUM(CASE WHEN YearsSinceLastPromotion   IS NULL THEN 1 ELSE 0 END) AS null_years_since_promotion,
    SUM(CASE WHEN DistanceFromHome          IS NULL THEN 1 ELSE 0 END) AS null_distance_from_home
FROM dbo.HR_Att;


-- STEP 2: BUILD CLEANED TABLE
DROP TABLE IF EXISTS dbo.HR_Attrition_Cleaned;

SELECT
    EmployeeNumber,
    Age,
    Gender,
    MaritalStatus,
    Department,
    JobRole,
    JobLevel,
    BusinessTravel,
    Education,
    EducationField,
    MonthlyIncome,
    PercentSalaryHike,
    StockOptionLevel,
    OverTime,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    YearsAtCompany,
    YearsInCurrentRole,
    YearsSinceLastPromotion,
    DistanceFromHome,
    Attrition,
    CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS AttritionFlag,
    CASE
        WHEN YearsAtCompany <= 2  THEN '0-2 yrs'
        WHEN YearsAtCompany <= 5  THEN '3-5 yrs'
        WHEN YearsAtCompany <= 10 THEN '6-10 yrs'
        ELSE                           '10+ yrs'
    END AS TenureBucket,
    CASE
        WHEN Age < 30              THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 40 THEN '30-40'
        WHEN Age BETWEEN 41 AND 50 THEN '41-50'
        ELSE                            '50+'
    END AS AgeGroup,
    CASE
        WHEN DistanceFromHome > 15 THEN 'Far (>15 km)'
        ELSE                            'Near (<=15 km)'
    END AS DistanceGroup,
    CASE
        WHEN MonthlyIncome < 3000  THEN 'Low Income'
        WHEN MonthlyIncome <= 7000 THEN 'Mid Income'
        ELSE                            'High Income'
    END AS IncomeLevel
INTO dbo.HR_Attrition_Cleaned
FROM dbo.HR_Att;


-- STEP 3: VERIFY CLEANED TABLE
SELECT COUNT(*) AS total_rows_cleaned FROM dbo.HR_Attrition_Cleaned;

SELECT TOP 10
    EmployeeNumber, Department, Attrition, AttritionFlag,
    TenureBucket, AgeGroup, DistanceGroup, IncomeLevel
FROM dbo.HR_Attrition_Cleaned;

SELECT
    SUM(CASE WHEN AttritionFlag IS NULL THEN 1 ELSE 0 END) AS null_attrition_flag,
    SUM(CASE WHEN TenureBucket  IS NULL THEN 1 ELSE 0 END) AS null_tenure_bucket,
    SUM(CASE WHEN AgeGroup      IS NULL THEN 1 ELSE 0 END) AS null_age_group,
    SUM(CASE WHEN DistanceGroup IS NULL THEN 1 ELSE 0 END) AS null_distance_group,
    SUM(CASE WHEN IncomeLevel   IS NULL THEN 1 ELSE 0 END) AS null_income_level
FROM dbo.HR_Attrition_Cleaned;


-- STEP 4: BUSINESS QUESTIONS

-- Q1: Attrition rate by department & job role
SELECT
    Department,
    JobRole,
    COUNT(*)                                         AS total_employees,
    SUM(AttritionFlag)                               AS employees_left,
    ROUND(SUM(AttritionFlag) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM dbo.HR_Attrition_Cleaned
GROUP BY Department, JobRole
HAVING COUNT(*) >= 10
ORDER BY attrition_rate_pct DESC;

-- Q2: Overtime vs attrition
SELECT
    OverTime,
    COUNT(*)                                         AS total_employees,
    SUM(AttritionFlag)                               AS employees_left,
    ROUND(SUM(AttritionFlag) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM dbo.HR_Attrition_Cleaned
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;

-- Q3: Income gap stayed vs left by department
SELECT
    Department,
    Attrition,
    COUNT(*)                                              AS employee_count,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)), 0)           AS avg_monthly_income,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)) * 12, 0)      AS avg_annual_income
FROM dbo.HR_Attrition_Cleaned
GROUP BY Department, Attrition
ORDER BY Department, Attrition;

-- Q4: Job satisfaction & tenure vs attrition
SELECT
    JobSatisfaction,
    TenureBucket,
    COUNT(*)                                         AS total_employees,
    SUM(AttritionFlag)                               AS employees_left,
    ROUND(SUM(AttritionFlag) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM dbo.HR_Attrition_Cleaned
GROUP BY JobSatisfaction, TenureBucket
ORDER BY attrition_rate_pct DESC;

-- Q5: At-risk segments by age, travel & distance
SELECT
    AgeGroup,
    BusinessTravel,
    DistanceGroup,
    COUNT(*)                                         AS total_employees,
    SUM(AttritionFlag)                               AS employees_left,
    ROUND(SUM(AttritionFlag) * 100.0 / COUNT(*), 1) AS attrition_rate_pct
FROM dbo.HR_Attrition_Cleaned
GROUP BY AgeGroup, BusinessTravel, DistanceGroup
HAVING COUNT(*) >= 5
ORDER BY attrition_rate_pct DESC;


-- STEP 5: RISK SCORE
DROP TABLE IF EXISTS dbo.HR_Attrition_RiskScored;

SELECT
    *,
    (
        CASE WHEN OverTime                = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN JobSatisfaction        <= 2     THEN 1 ELSE 0 END +
        CASE WHEN WorkLifeBalance        <= 2     THEN 1 ELSE 0 END +
        CASE WHEN YearsSinceLastPromotion >= 4    THEN 1 ELSE 0 END +
        CASE WHEN DistanceFromHome       > 15     THEN 1 ELSE 0 END
    ) AS RiskScore,
    CASE
        WHEN
            (
                CASE WHEN OverTime                = 'Yes' THEN 1 ELSE 0 END +
                CASE WHEN JobSatisfaction        <= 2     THEN 1 ELSE 0 END +
                CASE WHEN WorkLifeBalance        <= 2     THEN 1 ELSE 0 END +
                CASE WHEN YearsSinceLastPromotion >= 4    THEN 1 ELSE 0 END +
                CASE WHEN DistanceFromHome       > 15     THEN 1 ELSE 0 END
            ) >= 4 THEN 'High Risk'
        WHEN
            (
                CASE WHEN OverTime                = 'Yes' THEN 1 ELSE 0 END +
                CASE WHEN JobSatisfaction        <= 2     THEN 1 ELSE 0 END +
                CASE WHEN WorkLifeBalance        <= 2     THEN 1 ELSE 0 END +
                CASE WHEN YearsSinceLastPromotion >= 4    THEN 1 ELSE 0 END +
                CASE WHEN DistanceFromHome       > 15     THEN 1 ELSE 0 END
            ) >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS RiskTier
INTO dbo.HR_Attrition_RiskScored
FROM dbo.HR_Attrition_Cleaned;

-- RISK SCORE VALIDATION
SELECT
    RiskTier,
    COUNT(*)                                         AS total_employees,
    SUM(AttritionFlag)                               AS actually_left,
    ROUND(SUM(AttritionFlag) * 100.0 / COUNT(*), 1) AS actual_attrition_rate_pct
FROM dbo.HR_Attrition_RiskScored
GROUP BY RiskTier
ORDER BY actual_attrition_rate_pct DESC;


-- STEP 6: COST OF ATTRITION
SELECT
    Department,
    COUNT(*)                                              AS total_employees,
    SUM(AttritionFlag)                                    AS employees_left,
    ROUND(AVG(CAST(MonthlyIncome AS FLOAT)) * 12, 0)      AS avg_annual_salary,
    ROUND(
        SUM(AttritionFlag) * AVG(CAST(MonthlyIncome AS FLOAT)) * 12 * 0.5,
        0
    )                                                     AS estimated_replacement_cost_usd
FROM dbo.HR_Attrition_Cleaned
GROUP BY Department
ORDER BY estimated_replacement_cost_usd DESC;


-- STEP 7: EXPORT FOR TABLEAU
SELECT * FROM dbo.HR_Attrition_RiskScored
ORDER BY EmployeeNumber;