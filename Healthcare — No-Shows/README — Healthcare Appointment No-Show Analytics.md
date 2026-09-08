# Healthcare Appointment No-Show Analytics

## Reducing Appointment Absenteeism in a Public Healthcare Network

## Project Overview

Missed medical appointments represent more than an operational inconvenience. In public healthcare systems, every unattended appointment can mean an unused clinical slot while other patients remain on waiting lists.

This project analyzes medical appointment data to identify patterns associated with patient no-shows and support more effective appointment management strategies.

The objective is not simply to describe who missed an appointment, but to answer a broader business question:

> **How can a public healthcare network use scheduling data to identify absenteeism patterns and support actions that reduce lost appointment capacity?**

The project combines **data profiling, data quality, SQL analytics, dimensional modeling, KPI development and Power BI** to transform raw appointment records into actionable information for healthcare management.

---

## Business Context

Appointment absenteeism is a recurring challenge in healthcare systems.

When a patient does not attend a scheduled consultation:

- clinical capacity is underutilized;
- another patient may lose the opportunity to receive care;
- waiting lists can remain unnecessarily long;
- administrative resources are spent managing unused appointments;
- healthcare managers have less visibility into where scheduling inefficiencies occur.

For this project, the scenario is modeled as a request from a **public healthcare management team** seeking to understand where appointment losses are concentrated and which characteristics are associated with higher no-show rates.

The analytical solution should help managers identify opportunities to improve:

- appointment scheduling;
- patient communication;
- capacity utilization;
- prioritization of interventions;
- monitoring of absenteeism indicators.

---

# Business Problem

The healthcare network has identified a relevant number of missed medical appointments but does not yet have a structured analytical view explaining where and under which circumstances these absences occur.

Management needs to understand:

- where appointment no-shows are concentrated;
- whether scheduling lead time is associated with absenteeism;
- whether specific patient profiles present different attendance patterns;
- whether absenteeism varies across neighborhoods or days of the week;
- how communication mechanisms such as SMS relate to attendance;
- which areas could be prioritized for operational interventions.

---

# Main Analytical Question

> **Which factors are associated with medical appointment no-shows, and how can healthcare managers use this information to improve appointment utilization?**

This project focuses on **association and operational patterns**, rather than claiming causal relationships between variables and patient attendance.

---

# Business Questions

The analysis will address five main areas.

## 1. Attendance

- What is the overall no-show rate?
- How many scheduled appointments were attended?
- How many appointment slots were lost due to no-shows?
- How does absenteeism evolve across the available period?

## 2. Scheduling

- Does the number of days between scheduling and the appointment affect the no-show rate?
- Are same-day appointments associated with different attendance behavior?
- Are there weekdays with higher absenteeism?
- Do appointments with longer waiting periods present higher no-show rates?

## 3. Patient Profile

- Does attendance behavior vary by age group?
- Are there differences by gender?
- Are chronic conditions associated with different attendance patterns?
- Does participation in social assistance programs show different patterns?

## 4. Communication

- Do patients who received an SMS show different attendance behavior?
- Does SMS behavior vary according to appointment lead time?
- Could communication strategies be prioritized for specific appointment profiles?

## 5. Geographic Distribution

- Which neighborhoods have the highest number of missed appointments?
- Which neighborhoods have the highest no-show rates?
- Are high no-show rates associated with sufficiently large appointment volumes?
- Where could operational interventions potentially have the greatest impact?

---

# Dataset

The project uses the **Medical Appointment No Shows** dataset, containing medical appointment records from Brazil.

The original dataset contains:

- **110,527 appointment records**
- **14 original variables**

Main attributes include:

| Field | Description |
|---|---|
| `PatientId` | Patient identifier |
| `AppointmentID` | Appointment identifier |
| `Gender` | Patient gender |
| `ScheduledDay` | Date and time when the appointment was scheduled |
| `AppointmentDay` | Date of the medical appointment |
| `Age` | Patient age |
| `Neighbourhood` | Location associated with the appointment |
| `Scholarship` | Participation in a social assistance program |
| `Hipertension` | Hypertension indicator |
| `Diabetes` | Diabetes indicator |
| `Alcoholism` | Alcoholism indicator |
| `Handcap` | Disability-related indicator |
| `SMS_received` | Whether the patient received an SMS |
| `No-show` | Whether the patient missed the appointment |

The original dataset will be preserved in the **raw layer**. Cleaning and analytical transformations will be performed separately to maintain traceability.

---

# Analytical Approach

The project follows an end-to-end analytics workflow:

```text
Business Problem
        ↓
Raw Data
        ↓
Data Profiling
        ↓
Data Quality
        ↓
Data Cleaning
        ↓
Feature Engineering
        ↓
Data Modeling
        ↓
SQL Analytics
        ↓
KPI Layer
        ↓
Power BI
        ↓
Insights & Recommendations
```

This structure is designed to demonstrate not only visualization skills, but the complete process required to transform raw data into governed analytical information.

---

# Project Stages

## 1. Business Understanding

Define the management problem, analytical questions, expected indicators and decision-making context.

## 2. Data Profiling

Evaluate:

- data types;
- missing values;
- duplicates;
- cardinality;
- distributions;
- inconsistent values;
- potential integrity problems.

## 3. Data Quality

Formal data quality rules will be defined and evaluated.

Examples:

### DQ-001 — Appointment ID Uniqueness

`AppointmentID` should uniquely identify an appointment.

### DQ-002 — Patient ID Completeness

`PatientId` should not be null.

### DQ-003 — Valid Age

Patient age should fall within a plausible analytical range.

### DQ-004 — Scheduling Consistency

Appointment dates should be logically consistent with scheduling dates.

### DQ-005 — Valid Domains

Categorical and indicator fields should contain only expected values.

### DQ-006 — Attendance Status

`No-show` should contain only valid attendance classifications.

Rather than silently correcting problems, detected quality issues will be documented together with the treatment applied.

---

# Feature Engineering

New analytical variables will be generated from the original dataset.

Examples include:

```text
lead_time_days
age_group
appointment_weekday
scheduled_weekday
appointment_month
same_day_flag
chronic_condition_flag
no_show_flag
```

One of the main derived variables will be:

```text
lead_time_days =
appointment_date - scheduled_date
```

This allows the analysis to investigate whether the waiting period between scheduling and care is associated with patient attendance.

---

# Key Performance Indicators

The primary KPI will be:

## No-Show Rate

```text
No-Show Rate =
No-Show Appointments / Total Appointments
```

Additional indicators include:

- Total Appointments
- Attended Appointments
- No-Show Appointments
- No-Show Rate
- Average Lead Time
- Median Lead Time
- Same-Day Appointment Rate
- SMS Coverage Rate
- No-Show Rate by Age Group
- No-Show Rate by Weekday
- No-Show Rate by Neighborhood

---

# Potential Recoverable Appointments

The project will also introduce a scenario-based management indicator:

## Potential Recoverable Appointments

```text
Potential Recoverable Appointments =
No-Show Appointments × Target Reduction Rate
```

Example:

If a healthcare network records:

```text
10,000 missed appointments
```

and establishes a hypothetical target of reducing absenteeism by:

```text
20%
```

the scenario would represent:

```text
2,000 potentially recoverable appointment slots
```

This metric is intended for **planning and scenario analysis**. It does not represent a causal prediction that all identified appointments can actually be recovered.

---

# Data Model

The analytical layer will evolve toward a dimensional structure suitable for BI analysis.

A potential model includes:

```text
                DimDate
                   |
                   |
DimPatient — FactAppointment — DimLocation
                   |
                   |
            DimAppointment
```

The final model will be defined after data profiling and grain validation.

The central analytical grain is expected to represent:

> **One scheduled medical appointment per record.**

---

# Technology Stack

## Python

Used for:

- data profiling;
- data cleaning;
- data quality validation;
- feature engineering;
- exploratory analysis.

Main libraries:

```text
Python
Pandas
NumPy
Matplotlib
```

## SQL

Used for:

- analytical transformations;
- dimensional structures;
- reusable views;
- KPI calculations;
- business-oriented queries.

## Power BI

Used for:

- executive dashboard;
- KPI monitoring;
- geographic and demographic analysis;
- scheduling analysis;
- operational storytelling.

## GitHub

Used for:

- version control;
- technical documentation;
- project presentation;
- reproducibility.

---

# Expected Dashboard

The Power BI solution is expected to contain approximately four analytical views.

## Executive Overview

Management-level indicators:

- Total Appointments
- No-Shows
- No-Show Rate
- Average Lead Time
- Potential Recoverable Appointments

## Scheduling Analysis

Analysis of:

- lead time;
- appointment weekday;
- same-day appointments;
- scheduling patterns.

## Patient Analysis

Analysis by:

- age group;
- gender;
- selected health characteristics;
- SMS communication.

## Geographic Analysis

Analysis by:

- neighborhood;
- appointment volume;
- absolute number of no-shows;
- no-show rate.

---

# Data Governance Perspective

Although this is primarily a Data Analytics and BI project, governance concepts are incorporated into the analytical workflow.

The project will document:

- data quality rules;
- transformation logic;
- business definitions;
- KPI definitions;
- dataset grain;
- analytical assumptions;
- data dictionary;
- traceability between raw and processed data.

This provides a foundation for later portfolio projects focused more deeply on **Data Governance and AI-Ready Data Governance**.

---

# Important Analytical Principle

Correlation or association should not automatically be interpreted as causation.

For example:

If patients receiving SMS messages present a different no-show rate, the analysis should not immediately conclude that SMS caused the difference.

Other factors may influence the result, including:

- appointment lead time;
- communication eligibility rules;
- scheduling processes;
- patient characteristics.

Findings will therefore be presented as **analytical evidence supporting investigation and operational decisions**, rather than causal claims.

---

# Repository Structure

```text
healthcare-no-show-analytics/

├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_data_quality.ipynb
│   └── 03_data_preparation.ipynb
│
├── sql/
│   ├── create_tables.sql
│   ├── analytical_queries.sql
│   └── views.sql
│
├── powerbi/
│   └── healthcare_no_show.pbix
│
├── docs/
│   ├── business_requirements.md
│   ├── data_dictionary.md
│   ├── data_quality_rules.md
│   ├── kpi_dictionary.md
│   └── data_model.md
│
├── images/
│
├── README.md
└── requirements.txt
```

---

# Expected Deliverables

At the end of the project, the repository should include:

- cleaned analytical dataset;
- data profiling notebook;
- data quality assessment;
- documented data quality rules;
- dimensional data model;
- SQL analytical queries;
- KPI dictionary;
- Power BI dashboard;
- business insights;
- recommendations;
- data dictionary;
- complete project documentation.

---

# Skills Demonstrated

### Data Analytics

- Exploratory Data Analysis
- Data Cleaning
- Feature Engineering
- Analytical Reasoning

### SQL

- Aggregations
- Joins
- CTEs
- Analytical Queries
- Views

### Data Modeling

- Grain Definition
- Fact Tables
- Dimensions
- Star Schema

### Data Quality

- Completeness
- Uniqueness
- Validity
- Consistency
- Business Rule Validation

### Business Intelligence

- KPI Development
- Power BI
- Dashboard Design
- Business Storytelling

### Data Governance

- Data Dictionary
- KPI Dictionary
- Business Definitions
- Data Quality Rules
- Documentation
- Traceability

---

# Expected Business Outcome

The final analytical solution should allow a healthcare manager to move from:

> **“We have too many missed appointments.”**

to questions such as:

> **“Where are appointment losses concentrated?”**

> **“Which scheduling patterns show higher absenteeism?”**

> **“Which groups should we investigate or prioritize?”**

> **“Where could interventions potentially recover more appointment capacity?”**

The goal is to transform appointment data into information that can support more efficient use of healthcare resources.

---

## Portfolio Positioning

This project demonstrates the ability to work across the complete analytics lifecycle:

> **Business Problem → Data Quality → Data Modeling → Analytics → KPIs → Visualization → Decision Support**

Rather than presenting only a dashboard, the project emphasizes the reliability, structure and business meaning of the information behind the dashboard.