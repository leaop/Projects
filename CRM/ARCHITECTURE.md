# Architecture

## End-to-end flow

```text
Source CRM Access Data
        |
        v
EDA / Profiling
        |
        v
Explanatory Analysis
        |
        v
Governance Rule Design
        |
        +------ Data Quality Framework
        +------ Metadata & Catalog
        +------ Privacy Engineering
        +------ Lineage & Traceability
        |
        v
Stewardship & Governance Operating Model
        |
        v
Analytical Star Schema
        |
        v
Power BI Governance Monitoring
        |
        v
AI Governance Extension
```

## Access governance decision model

```text
Access Request
      |
      v
Explicit Permission?
   |       |
  No      Yes
   |       |
 BLOCK     v
      Role × Action Baseline
           |
      Contextual Risk
           |
     LOW / MEDIUM / HIGH / CRITICAL
           |
     ALLOW / REVIEW / BLOCK
```

## Analytical model

The primary grain is one CRM access event per row in `fact_access_event`.

Primary dimensions:
- Role
- CRM Action
- Device
- Data Sensitivity
- Governance Rule
- Contextual Risk
- Hour
- Region
- Lead Source

The privacy-safe customer dimension is modeled separately because the access-event dataset has no governed customer foreign key.

## Design principle

The project favors explicit, explainable, auditable rules over opaque decision logic. Machine learning is used in Stage 02 only as an explanatory tool rather than as the final governance authority.
