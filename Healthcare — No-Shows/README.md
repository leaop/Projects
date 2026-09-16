# Healthcare Appointment No-Show Analytics

## Reducing Appointment Absenteeism in a Public Healthcare Network

This project analyzes **110,521 valid medical appointment records** to identify operational patterns associated with patient no-shows and support actions that can reduce lost healthcare capacity.

The solution covers the complete analytics lifecycle:

> **Business Problem → Data Quality → Python Analysis → External Data Enrichment → Dimensional Modeling → Azure SQL → KPI / Consumption Layer → Streamlit Dashboard → Decision Support**

---

## Business Problem

Missed medical appointments represent more than an operational inconvenience. In a public healthcare network, an unattended appointment can mean an unused clinical slot while other patients remain on waiting lists.

The main business question is:

> **Which factors are associated with medical appointment no-shows, and how can healthcare managers use this information to improve appointment utilization?**

The project focuses on **associations and operational patterns**, not causal claims.

---

## Business Questions

The analysis addresses six operational questions:

1. **Where are appointment losses concentrated?**
2. **How is scheduling lead time associated with no-show behaviour?**
3. **Do weekday patterns vary across appointment and neighbourhood contexts?**
4. **Is SMS communication associated with better attendance?**
5. **How many appointment slots could potentially be recovered under hypothetical reductions in absenteeism?**
6. **Which appointment groups could receive prioritized communication?**

---

## Dataset

The project uses the **Medical Appointment No Shows** dataset containing appointment records from Brazil.

### Original dataset

- **110,527 appointment records**
- **14 original variables**

Main attributes include:

| Field | Description |
|---|---|
| `PatientId` | Patient identifier |
| `AppointmentID` | Appointment identifier |
| `Gender` | Patient gender |
| `ScheduledDay` | Date and time when the appointment was scheduled |
| `AppointmentDay` | Scheduled appointment date |
| `Age` | Patient age |
| `Neighbourhood` | Neighbourhood associated with the appointment |
| `Scholarship` | Social assistance indicator |
| `Hipertension` | Hypertension indicator |
| `Diabetes` | Diabetes indicator |
| `Alcoholism` | Alcoholism indicator |
| `Handcap` | Disability-related indicator |
| `SMS_received` | Whether an SMS reminder was recorded |
| `No-show` | Whether the patient missed the appointment |

### Clean analytical dataset

After data quality treatment, the analytical dataset contains:

- **110,521 valid appointment records**
- **22,314 no-shows**
- **20.19% overall no-show rate**

Six invalid records were excluded from the analytical layer:

- one record with invalid negative age;
- five records with genuinely negative scheduling lead time after date normalization.

The raw source is preserved separately from the cleaned analytical layer.

---

## External Data Enrichment — IBGE Census 2022

Neighbourhood-level socioeconomic context was added using official **IBGE Census 2022 neighbourhood aggregates for Vitória, Espírito Santo**.

The enrichment includes:

- average income of household reference persons;
- median income of household reference persons;
- number of responsible persons;
- number of residents;
- derived neighbourhood income group.

### Matching result

- **78 of 80 neighbourhoods matched**
- only **7 appointment records** remained without socioeconomic enrichment

Unmatched appointments were retained with null socioeconomic attributes rather than imputed.

> **Important:** income is measured at neighbourhood level and must not be interpreted as individual patient income.

---

## Data Quality and Feature Engineering

Key analytical transformations include:

### No-show flag

```text
No-show = Yes → NoShowFlag = 1
No-show = No  → NoShowFlag = 0
```

### Scheduling lead time

The initial calculation was corrected to compare **normalized calendar dates** rather than a timestamp against midnight:

```python
waiting_days = (
    AppointmentDay.normalize()
    - ScheduledDay.normalize()
).days
```

This prevents valid same-day appointments from being incorrectly classified as negative lead-time records.

### Lead-time groups

```text
Same day
1-2 days
3-7 days
8-14 days
15-30 days
31-60 days
61+ days
```

### Observed recurrence proxy

The dataset does not contain an official first-visit / follow-up field.

Appointments were therefore classified as:

```text
First observed appointment
Repeat observed appointment
```

based on the sequence in which each `PatientId` appears in the available data.

This is an **analytical recurrence proxy**, not a confirmed clinical follow-up classification.

---

# Main Analytical Findings

## 1. Scheduling lead time is the strongest operational signal

Observed no-show rates increase substantially as scheduling lead time grows:

| Lead Time | No-Show Rate |
|---|---:|
| Same day | 4.6% |
| 1–2 days | 22.7% |
| 3–7 days | 25.0% |
| 8–14 days | 30.5% |
| 15–30 days | 32.6% |
| 31–60 days | 34.2% |
| 61+ days | 28.4% |

The relationship is strong but not perfectly monotonic.

This supports prioritizing longer-wait appointments for operational interventions such as reminders, wait-list replacement and shorter booking windows.

## 2. Weekday is a secondary factor

Monday-to-Friday no-show rates remain within a relatively narrow range:

- Monday: **20.6%**
- Tuesday: **20.1%**
- Wednesday: **19.7%**
- Thursday: **19.3%**
- Friday: **21.2%**

Saturday has a higher observed rate but only **39 appointments**, so it is not treated as operationally stable.

Weekday therefore appears to be much weaker than scheduling lead time.

## 3. Neighbourhood income provides context, but the association is weak

The Pearson correlation between neighbourhood median income and no-show rate is approximately:

```text
-0.21
```

Higher-income neighbourhoods tend to show somewhat lower absenteeism, but the relationship is weak.

The higher-income group shows the lowest observed no-show rate at approximately **18.5%**, while the remaining income groups are closer to **20–21%**.

This should be treated as **area-level context**, not individual socioeconomic causation.

## 4. Repeat observed appointments show slightly higher absenteeism

| Observed Visit Type | No-Show Rate |
|---|---:|
| First observed appointment | 19.5% |
| Repeat observed appointment | 21.0% |

The difference is small and cannot be interpreted as evidence about confirmed clinical follow-up behaviour.

## 5. The crude SMS comparison is misleading without lead-time context

At aggregate level:

- **No SMS:** 16.7% no-show
- **SMS received:** 27.6% no-show

However, SMS recipients had much longer scheduling lead times:

- No SMS: mean wait approximately **6.0 days**
- SMS received: mean wait approximately **19.0 days**

Within comparable lead-time groups, SMS recipients consistently show lower no-show rates:

| Lead Time | No SMS | SMS Received |
|---|---:|---:|
| 3–7 days | 26.6% | 23.8% |
| 8–14 days | 33.8% | 28.1% |
| 15–30 days | 36.9% | 29.8% |
| 31–60 days | 38.4% | 31.5% |
| 61+ days | 33.9% | 25.5% |

The results support a **conditional association**, not a causal effect of SMS.

## 6. Potentially recoverable appointment capacity

With **22,314 no-shows**:

| Hypothetical Reduction | Potentially Recoverable Slots |
|---|---:|
| 10% | ~2,231 |
| 20% | ~4,463 |
| 30% | ~6,694 |

These values represent **potential recoverable capacity**, not guaranteed additional care delivery.

---

# Dimensional Model

The SQL analytical layer uses a **Star Schema** with the grain:

> **One row in `FactAppointment` = one scheduled medical appointment**

```text
                    DimPatient
                        |
                        |
DimDate -------- FactAppointment -------- DimNeighbourhood
   \                    /
    \                  /
     ---- DimDate -----
   Scheduled / Appointment roles
```

### Fact table

`FactAppointment`

```text
AppointmentID
PatientKey
NeighbourhoodKey
ScheduledDateKey
AppointmentDateKey
Age
AgeGroup
SMSReceived
WaitingDays
WaitingGroup
ObservedVisitType
NoShowFlag
AppointmentCount
```

### Dimensions

`DimPatient`

```text
PatientKey
PatientId
Gender
```

`DimNeighbourhood`

```text
NeighbourhoodKey
NeighbourhoodName
IncomeMean
IncomeMedian
ResponsiblePersons
Residents
IncomeGroup
```

`DimDate`

```text
DateKey
Date
Year
Quarter
MonthNumber
MonthName
Day
WeekdayNumber
WeekdayName
IsWeekend
```

`DimDate` is used as a **role-playing dimension** for both scheduling date and appointment date.

Full definitions are documented in [`data_dictionary.md`](data_dictionary.md).

---

# Data Pipeline

```text
Raw Healthcare Dataset
        ↓
Python Data Profiling
        ↓
Data Quality Treatment
        ↓
Feature Engineering
        ↓
IBGE Socioeconomic Enrichment
        ↓
Clean Analytical Dataset
        ↓
stg_appointments.csv
        ↓
Azure SQL Staging
        ↓
DimPatient
DimNeighbourhood
DimDate
        ↓
FactAppointment
        ↓
Business Views
        ↓
SQL KPI / Business Queries
        ↓
Streamlit Dashboard
```

---

# Azure SQL Analytical Layer

The project uses **Azure SQL Database** as the analytical database.

### Staging layer

```text
stg_Appointments
```

### Consumption views

```text
vw_NoShowOverview
vw_NoShowByNeighbourhood
vw_NoShowByWaitingGroup
vw_NoShowBySMS
vw_CommunicationPriority
```

This separates the dimensional model from the consumption layer and allows dashboards or analysts to query simplified business-oriented structures.

---

# SQL Validation

The dimensional model was validated for:

- fact row count;
- appointment uniqueness;
- orphan foreign keys;
- patient relationships;
- neighbourhood relationships;
- scheduling date relationships;
- appointment date relationships;
- business KPI reconciliation.

Final validated metrics:

```text
Appointments: 110,521
No-Shows: 22,314
No-Show Rate: 20.19%
```

The SQL results reconcile with the Python analytical layer.

---

# Streamlit Dashboard

The final dashboard is implemented in **Streamlit** and connects directly to Azure SQL.

The dashboard contains three analytical areas:

### Executive Overview

- total appointments;
- total no-shows;
- no-show rate;
- average waiting time;
- main operational findings;
- neighbourhood no-show volume.

### Operational Drivers

- no-show rate by scheduling lead time;
- neighbourhood no-show rate;
- minimum-volume filtering;
- socioeconomic context.

### Communication & Recovery

- SMS comparison;
- recoverable capacity scenarios;
- priority communication segments;
- methodological warnings.

### Running locally

```bash
python -m streamlit run streamlit/app.py
```

Database credentials are stored outside the source code using Streamlit secrets and environment variables.

> `secrets.toml` and `.env` are excluded from version control.

---

# Dashboard Screenshots

Add the final screenshots to an `images/` folder and reference them here.

```markdown
![Executive Overview](images/executive_overview.png)

![Operational Drivers](images/operational_drivers.png)

![Communication and Recovery](images/communication_recovery.png)
```

---

# Technology Stack

### Python

- Pandas
- NumPy
- Matplotlib
- SQLAlchemy
- pyodbc
- python-dotenv

### SQL / Azure SQL

- staging
- dimensional modeling
- surrogate keys
- PK / FK relationships
- calendar dimension
- business views
- KPI calculations
- validation queries
- business queries

### Streamlit

- executive dashboard
- KPI monitoring
- operational storytelling
- communication prioritization
- scenario analysis

### GitHub

- version control
- project documentation
- reproducibility
- portfolio presentation

---

# Data Governance Perspective

Governance concepts are incorporated throughout the project.

The solution documents:

- data quality rules;
- transformation logic;
- source-to-target traceability;
- dataset grain;
- analytical assumptions;
- KPI definitions;
- dimensional structure;
- data dictionary;
- business definitions;
- external enrichment limitations;
- secure credential handling.

---

# Analytical Limitations

- the analysis is observational and does not establish causality;
- neighbourhood income is area-level context, not individual patient income;
- employment status, education, transportation access and stated reasons for absence are unavailable;
- `ObservedVisitType` is a recurrence proxy and not a confirmed clinical follow-up variable;
- SMS eligibility rules are unknown;
- diagnosis, clinical severity, specialty and treatment outcome are unavailable;
- potentially recoverable slots are scenario estimates, not guaranteed additional appointments.

---

# Repository Structure

```text
Healthcare — No-Shows/
│
├── streamlit/
│   ├── app.py
│   └── .streamlit/
│       └── secrets.toml          # local only / ignored by Git
│
├── healthcare_no_show_analysis_final.ipynb
├── load_staging_to_sql.ipynb
│
├── Healthcare_no_shows.csv
├── stg_appointments.csv          # local export / ignored by Git
│
├── Healthcare_sql.sql
├── Create_staging.sql
├── load_dimensions.sql
├── load_fact.sql
├── validation.sql
├── Create_views.sql
├── business_queries.sql
│
├── data_dictionary.md
├── .env                          # local only / ignored by Git
├── .gitignore
└── README.md
```

---

# Skills Demonstrated

### Data Analytics

- Exploratory Data Analysis
- Data Cleaning
- Feature Engineering
- Analytical Reasoning
- External Data Enrichment

### SQL

- Aggregations
- Joins
- CTEs
- Views
- Staging Layers
- Dimensional Loads
- Validation Queries
- Business Queries

### Data Modeling

- Grain Definition
- Fact Tables
- Dimensions
- Surrogate Keys
- Primary / Foreign Keys
- Role-Playing Dimensions
- Star Schema

### Data Quality

- Completeness
- Uniqueness
- Validity
- Consistency
- Business Rule Validation
- Source-to-target reconciliation

### Business Intelligence

- KPI Development
- Dashboard Design
- Streamlit
- Operational Storytelling
- Scenario Analysis

### Data Governance

- Data Dictionary
- Business Definitions
- Data Quality Rules
- Documentation
- Traceability
- Analytical Limitations
- Credential Separation

---

# Business Recommendations

1. **Prioritize reminders for longer lead-time appointments.**
2. **Test expanded SMS coverage within comparable lead-time groups.**
3. **Use targeted rather than uniform communication strategies.**
4. **Consider short-notice wait-list or cancellation-replacement mechanisms.**
5. **Evaluate interventions through a controlled pilot before scaling.**

The project supports prioritization and experimentation rather than deterministic predictions of patient attendance.

---

# Portfolio Positioning

This project demonstrates the ability to work across the complete analytics lifecycle:

> **Business Problem → Data Quality → Data Enrichment → Data Modeling → Azure SQL → Analytics → KPIs → Streamlit → Decision Support**

Rather than presenting only a dashboard, the project emphasizes the **reliability, structure, traceability and business meaning** of the information behind it.
