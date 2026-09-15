# Data Dictionary — Healthcare Appointment No-Show Analytics

## 1. Purpose

This document defines the analytical data model used in the **Healthcare Appointment No-Show Analytics** project.

The dimensional model follows a **Star Schema** structure centered on appointment events.

### Grain

> **One row in `FactAppointment` represents one scheduled medical appointment.**

The model contains one fact table and three main dimensions:

- `FactAppointment`
- `DimPatient`
- `DimNeighbourhood`
- `DimDate`

The model is designed to support analyses of appointment volume, no-show behaviour, scheduling lead time, SMS reminders, patient recurrence and neighbourhood socioeconomic context.

---

# 2. FactAppointment

## Description

`FactAppointment` is the central fact table.

Each row represents one scheduled appointment and contains:

- foreign keys connecting the appointment to its dimensions;
- attributes specific to that appointment;
- derived analytical variables;
- measures used in reporting and KPI calculations.

| Field | SQL Type | Role | Source | Rule / Description |
|---|---|---|---|---|
| `AppointmentID` | `BIGINT` | Fact identifier / business key | `AppointmentID` | Original appointment identifier. Expected to uniquely identify each scheduled appointment. |
| `PatientKey` | `INT` | Foreign Key | `DimPatient` | Surrogate key linking the appointment to the patient dimension. |
| `NeighbourhoodKey` | `INT` | Foreign Key | `DimNeighbourhood` | Surrogate key linking the appointment to the neighbourhood dimension. |
| `ScheduledDateKey` | `INT` | Foreign Key | `ScheduledDay` | Date when the appointment was scheduled, transformed to `YYYYMMDD`. Links to `DimDate`. |
| `AppointmentDateKey` | `INT` | Foreign Key | `AppointmentDay` | Scheduled appointment date, transformed to `YYYYMMDD`. Links to `DimDate`. |
| `Age` | `INT` | Fact attribute | `Age` | Patient age recorded for the appointment. Stored at fact level because age may vary across appointments over time. |
| `AgeGroup` | `VARCHAR(20)` | Derived fact attribute | `Age` | Analytical age-range classification derived from `Age`. |
| `SMSReceived` | `BIT` | Fact attribute | `SMS_received` | Indicates whether an SMS reminder was recorded for the appointment. `0 = No`, `1 = Yes`. |
| `WaitingDays` | `INT` | Derived measure | `ScheduledDay`, `AppointmentDay` | Calendar-day difference between normalized appointment date and normalized scheduling date. |
| `WaitingGroup` | `VARCHAR(20)` | Derived fact attribute | `WaitingDays` | Lead-time category: `Same day`, `1-2 days`, `3-7 days`, `8-14 days`, `15-30 days`, `31-60 days`, `61+ days`. |
| `ObservedVisitType` | `VARCHAR(30)` | Derived fact attribute | `PatientId`, appointment sequence | Recurrence proxy: `First observed appointment` or `Repeat observed appointment`. This is not a confirmed clinical first visit/follow-up classification. |
| `NoShowFlag` | `BIT` | Outcome measure | `No-show` | Binary analytical variable. `1 = patient missed appointment`, `0 = patient attended`. |
| `AppointmentCount` | `INT` | Additive measure | Generated | Constant value `1` for every fact row. Supports appointment-count aggregation. |

---

# 3. DimPatient

## Description

`DimPatient` stores reusable descriptive information about the patient.

Only relatively stable patient attributes are included here. Appointment-specific attributes, such as age at the time of the appointment, remain in `FactAppointment`.

| Field | SQL Type | Role | Source | Rule / Description |
|---|---|---|---|---|
| `PatientKey` | `INT` | Primary Key | Generated | Surrogate key generated in the analytical model. |
| `PatientId` | `BIGINT` | Business Key | `PatientId` | Original patient identifier from the source dataset. |
| `Gender` | `CHAR(1)` | Dimension attribute | `Gender` | Gender value recorded in the source dataset. |

### Notes

- `PatientKey` is the model key used in relationships.
- `PatientId` is retained as the original business identifier.
- `Age` is intentionally excluded because it is tied to the appointment context rather than treated as a permanently stable patient attribute.

---

# 4. DimNeighbourhood

## Description

`DimNeighbourhood` stores neighbourhood information and socioeconomic context.

This dimension integrates:

- neighbourhood information from the healthcare appointment dataset;
- neighbourhood-level socioeconomic indicators from IBGE Census data.

| Field | SQL Type | Role | Source | Rule / Description |
|---|---|---|---|---|
| `NeighbourhoodKey` | `INT` | Primary Key | Generated | Surrogate key generated for each analytical neighbourhood. |
| `NeighbourhoodName` | `VARCHAR(100)` | Dimension attribute | Healthcare dataset | Standardized neighbourhood name used for analysis. |
| `NeighbourhoodCode` | `VARCHAR(20)` | Dimension attribute | IBGE | Official IBGE neighbourhood code when a valid match is available. |
| `IncomeMean` | `DECIMAL(12,2)` | Dimension attribute | IBGE `V06004` | Nominal average monthly income of household reference persons with income. |
| `IncomeMedian` | `DECIMAL(12,2)` | Dimension attribute | IBGE `V06006` | Nominal median monthly income of household reference persons with income. Primary socioeconomic indicator used in the project. |
| `ResponsiblePersons` | `INT` | Dimension attribute | IBGE `V06001` | Number of household reference persons in occupied permanent private households. |
| `Residents` | `INT` | Dimension attribute | IBGE `V06002` | Number of residents in occupied permanent private households. |
| `IncomeGroup` | `VARCHAR(30)` | Derived dimension attribute | `IncomeMedian` | Quartile-based socioeconomic classification: `Lower income`, `Lower-middle income`, `Upper-middle income`, `Higher income`. |

### Notes

- Income information is measured at **neighbourhood level**, not individual patient level.
- These variables provide contextual socioeconomic information and should not be interpreted as individual income.
- Unmatched neighbourhoods are retained in the analytical dataset with null socioeconomic attributes rather than being imputed.

---

# 5. DimDate

## Description

`DimDate` is the calendar dimension used to support time-based analysis.

The same dimension is used in two different roles:

- scheduling date;
- appointment date.

This is a **role-playing dimension**.

| Field | SQL Type | Role | Source | Rule / Description |
|---|---|---|---|---|
| `DateKey` | `INT` | Primary Key | Generated | Integer date key in `YYYYMMDD` format. |
| `Date` | `DATE` | Dimension attribute | Calendar | Full calendar date. |
| `Year` | `SMALLINT` | Dimension attribute | `Date` | Calendar year. |
| `Quarter` | `TINYINT` | Dimension attribute | `Date` | Calendar quarter, values 1–4. |
| `MonthNumber` | `TINYINT` | Dimension attribute | `Date` | Calendar month number, values 1–12. |
| `MonthName` | `VARCHAR(20)` | Dimension attribute | `Date` | Calendar month name. |
| `Day` | `TINYINT` | Dimension attribute | `Date` | Day of month. |
| `WeekdayNumber` | `TINYINT` | Dimension attribute | `Date` | Ordered weekday number used for sorting. |
| `WeekdayName` | `VARCHAR(20)` | Dimension attribute | `Date` | Name of weekday, such as Monday or Tuesday. |
| `IsWeekend` | `BIT` | Dimension attribute | `Date` | `1` for Saturday/Sunday, otherwise `0`. |

### Role-Playing Relationships

`FactAppointment` references `DimDate` twice:

- `FactAppointment.ScheduledDateKey` → `DimDate.DateKey`
- `FactAppointment.AppointmentDateKey` → `DimDate.DateKey`

This allows the same calendar structure to answer different business questions without creating duplicate date dimensions.

---

# 6. Relationships

| Fact Table Field | Dimension Field | Relationship |
|---|---|---|
| `FactAppointment.PatientKey` | `DimPatient.PatientKey` | Many-to-one |
| `FactAppointment.NeighbourhoodKey` | `DimNeighbourhood.NeighbourhoodKey` | Many-to-one |
| `FactAppointment.ScheduledDateKey` | `DimDate.DateKey` | Many-to-one |
| `FactAppointment.AppointmentDateKey` | `DimDate.DateKey` | Many-to-one |

The intended analytical model follows a classic star-schema pattern:

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

---

# 7. Key Analytical Definitions

## No-Show Flag

```text
No-show = "Yes" -> NoShowFlag = 1
No-show = "No"  -> NoShowFlag = 0
```

## Waiting Days

`WaitingDays` is calculated using calendar dates after removing the time component:

```text
WaitingDays =
Normalized Appointment Date
-
Normalized Scheduled Date
```

This avoids incorrectly classifying same-day appointments as negative waiting-time records.

## Waiting Groups

| WaitingDays | WaitingGroup |
|---|---|
| `0` | `Same day` |
| `1–2` | `1-2 days` |
| `3–7` | `3-7 days` |
| `8–14` | `8-14 days` |
| `15–30` | `15-30 days` |
| `31–60` | `31-60 days` |
| `61+` | `61+ days` |

## Observed Visit Type

Appointments are ordered for each patient using:

1. `PatientId`
2. `AppointmentDay`
3. `ScheduledDay`
4. `AppointmentID`

Classification:

```text
ObservedSequence = 1
-> First observed appointment

ObservedSequence > 1
-> Repeat observed appointment
```

This is an analytical recurrence proxy only. It does not confirm that a repeated appointment is a clinical follow-up.

---

# 8. Data Quality Rules

The dimensional model should be populated only from the cleaned analytical dataset.

Current data-quality rules include:

- remove records with `Age < 0`;
- remove records with `WaitingDays < 0`;
- preserve valid appointment rows even when neighbourhood socioeconomic enrichment is unavailable;
- retain raw source data separately from cleaned analytical data;
- validate the healthcare-to-neighbourhood merge as many appointments to one neighbourhood.

---

# 9. Modeling Principles

The model follows these principles:

- **Fact grain:** one row per scheduled appointment.
- **Dimensions represent reusable business context**, not individual spreadsheet columns.
- **Surrogate keys** are used to connect fact and dimension tables.
- **Business keys** from source systems are preserved where useful for traceability.
- Derived variables used repeatedly in analysis are explicitly documented.
- Socioeconomic variables remain neighbourhood-level context and are not interpreted as patient-level attributes.
- The model avoids unnecessary dimensions where a field is more naturally an attribute of the appointment event.

---

# 10. Status

This data dictionary represents the current approved conceptual design.

It will be validated against the SQL implementation. If implementation decisions change during table creation or data loading, this document should be updated so that the final documentation remains synchronized with the actual analytical model.
