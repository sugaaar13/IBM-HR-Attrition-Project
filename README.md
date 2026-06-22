[README.md](https://github.com/user-attachments/files/29227019/README.md)
# Employee Attrition & Retention Risk Analysis
### IBM HR Analytics | Excel · SQL Server · Tableau

---

## 📌 Project Overview

Employee attrition is one of the most costly and preventable problems a company faces. This project analyzes IBM's HR dataset of **1,470 employees** to answer three questions that any HR director or business leader would actually care about:

1. **Where** is attrition risk concentrated across the organization?
2. **What** factors are driving employees to leave?
3. **How much** is it costing the business in replacement costs?

This project demonstrates the full data analyst workflow — from raw CSV inspection in Excel, to structured cleaning and analysis in SQL Server, to an interactive business dashboard in Tableau Public.

---

## 🔗 Quick Links

| Resource | Link |
|---|---|
| 📊 Live Interactive Dashboard | [View on Tableau Public](#) |
| 📁 Dataset Source | [IBM HR Analytics — Kaggle](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) |
---

## 📊 Key Findings

> **237 out of 1,470 employees left — a 16.1% attrition rate costing an estimated $9.2M in replacement costs.**

### 1. Overtime Is the Strongest Single Predictor of Attrition
Employees who work overtime leave at a rate of **30.5%** compared to only **10.4%** for non-overtime employees — nearly **3x higher**. This is the single most actionable finding in the entire dataset: workload management directly impacts retention.

### 2. Sales Department Has the Highest Attrition Risk
The Sales department leads all departments with a **20.6% attrition rate**, followed by Human Resources at **19.0%** and Research & Development at **13.8%**. Within Sales, the Sales Representative role is the most critical at **39.8%** — meaning nearly 4 in every 10 Sales Representatives eventually leave.

| Department | Attrition Rate |
|---|---|
| Sales | 20.6% |
| Human Resources | 19.0% |
| Research & Development | 13.8% |

### 3. Top 5 Highest-Risk Job Roles

| Job Role | Attrition Rate |
|---|---|
| Sales Representative | 39.8% |
| Laboratory Technician | 23.9% |
| Human Resources | 23.1% |
| Sales Executive | 17.5% |
| Research Scientist | 16.1% |

### 4. The Risk Scoring Model Works
A rule-based risk scoring model was built using 5 known attrition risk factors (overtime, low job satisfaction, poor work-life balance, long time since last promotion, and long commute distance). When validated against actual outcomes in the data, the model correctly separates high-risk employees from low-risk ones:

| Risk Tier | Actual Attrition Rate |
|---|---|
| 🔴 High Risk | 38.7% |
| 🟡 Medium Risk | 22.6% |
| 🟢 Low Risk | 10.7% |

High-risk employees leave at nearly **4x the rate** of low-risk employees — confirming the scoring logic is meaningful and not arbitrary.

### 5. The Financial Cost Is Significant
Using a conservative 50% of annual salary as the replacement cost benchmark (SHRM standard), the estimated total cost of the 237 employees who left is approximately **$9,247,168**. A 5% reduction in attrition across the organization would save roughly **$462,000 per year**.

---

## 💡 Recommendations

Based on the analysis, here are three concrete actions HR leadership could take:

**1. Audit Overtime Policy in Sales and R&D**
Overtime is the strongest predictor of attrition in this dataset. An immediate review of workload distribution — particularly for Sales Representatives and Laboratory Technicians — could meaningfully reduce attrition in the two highest-risk roles.

**2. Prioritize Promotion Reviews for Long-Tenured Employees**
Employees who have not been promoted in 4 or more years show significantly elevated risk scores. A structured promotion review cycle targeting this segment is a low-cost intervention with potentially high retention impact.

**3. Introduce Targeted Retention Programs for High-Risk Tier**
The 38.7% actual attrition rate in the High-Risk tier — compared to 10.7% in Low-Risk — suggests that proactive engagement (stay interviews, flexible work arrangements, compensation reviews) targeted specifically at high-risk employees could have a measurable ROI.

---

## 🛠️ Tools & Methodology

| Phase | Tool | Purpose |
|---|---|---|
| Data Inspection | Microsoft Excel | Initial scan, duplicate check, PivotTable validation |
| Data Cleaning & Analysis | SQL Server (T-SQL) | Cleaning, transformation, business questions, risk scoring |
| Visualization | Tableau Public | Interactive dashboard with live cost calculator |
| Version Control | GitHub | Project documentation and file management |

### Methodology Summary

**Phase 1 — Excel**
Opened the raw CSV, scanned all 9 categorical columns for typos and unexpected values using filter dropdowns and PivotTable unique-value counts, verified no duplicate EmployeeNumbers, added a binary AttritionFlag column, and built a quick Department × Attrition PivotTable as a sanity check benchmark for the SQL phase.

**Phase 2 — SQL Server**
Imported the raw CSV into SQL Server and built a structured cleaning pipeline across 7 steps: null checks across 12 key columns, creation of a cleaned working table with 5 derived columns (AttritionFlag, TenureBucket, AgeGroup, DistanceGroup, IncomeLevel), 5 core business questions answered via GROUP BY aggregations, a rule-based risk scoring model with 5 weighted risk factors, validation of the risk model against actual attrition outcomes, and an estimated cost-of-attrition calculation by department.

**Phase 3 — Tableau**
Built an interactive dashboard with 8 sheets: 5 KPI cards (including a live cost-of-attrition calculator with a parameter slider), a bar chart for attrition by department and job role, a heatmap for satisfaction versus tenure, a dual-axis chart for income gap analysis, a treemap for risk tier distribution, and a risk score validation chart.

---

## 📁 Repository Structure

```
ibm-hr-attrition-analysis/
│
├── README.md
│
├── data/
│   ├── raw/
│   │   └── HR_Employee_Attrition_Raw.csv
│   │
│   └── cleaned/
│       ├── 01_null_check.csv
│       ├── 02_hr_attrition_cleaned_preview.csv
│       ├── 03_q1_attrition_by_dept_role.csv
│       ├── 04_q2_overtime_vs_attrition.csv
│       ├── 05_q3_income_gap.csv
│       ├── 06_q4_satisfaction_tenure.csv
│       ├── 07_q5_at_risk_segments.csv
│       ├── 08_risk_score_validation.csv
│       └── 09_cost_of_attrition.csv
│
├── excel/
│   └── 01_initial_inspection.xlsx
│
├── sql/
│   └── hr_attrition_cleaning_and_analysis.sql
│
├── tableau/
│   └── attrition_dashboard.twbx
│
└── images/
    └── dashboard_screenshot.png
```

---

## 📋 Dataset Information

| Attribute | Detail |
|---|---|
| Source | IBM HR Analytics Employee Attrition & Performance |
| Platform | Kaggle |
| Rows | 1,470 employees |
| Columns | 35 attributes |
| Target Variable | Attrition (Yes / No) |
| Data Type | Cross-sectional HR records |

**Key columns used in this analysis:**

| Column | Description |
|---|---|
| Attrition | Whether the employee left (Yes/No) |
| Department | Employee's department |
| JobRole | Employee's job title |
| MonthlyIncome | Monthly salary in USD |
| OverTime | Whether the employee works overtime |
| JobSatisfaction | Satisfaction rating (1-4 scale) |
| WorkLifeBalance | Work-life balance rating (1-4 scale) |
| YearsAtCompany | Total years at the company |
| YearsSinceLastPromotion | Years since last promotion |
| DistanceFromHome | Distance from home to office (km) |

---

## ⚙️ How to Reproduce

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) → save to `data/raw/`
2. Import the raw CSV into SQL Server via SSMS (Tasks → Import Flat File)
3. Run `sql/hr_attrition_cleaning_and_analysis.sql` step by step in SSMS
4. Export the final query result (`SELECT * FROM HR_Attrition_RiskScored`) as CSV
5. Open Tableau Public → connect to the exported CSV
6. Refer to the dashboard file in `tableau/attrition_dashboard.twbx`

---

## 👤 About

**[sugarano okto forbiah tamba]**
Data Science Student — ULBI Bandung

Actively building a job-ready portfolio in data analytics with a focus on business-driven insights using Excel, SQL, and Tableau.

